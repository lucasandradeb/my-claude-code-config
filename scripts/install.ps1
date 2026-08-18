# Instala a configuracao em $env:USERPROFILE\.claude. Idempotente.
# Mesmo contrato de saida do install.sh.
$ErrorActionPreference = 'Stop'

$Repo      = Split-Path -Parent $PSScriptRoot
$ClaudeDir = if ($env:CLAUDE_DIR)  { $env:CLAUDE_DIR }  else { Join-Path $env:USERPROFILE '.claude' }
$ClaudeJson= if ($env:CLAUDE_JSON) { $env:CLAUDE_JSON } else { Join-Path $env:USERPROFILE '.claude.json' }
$Stamp     = Get-Date -Format 'yyyyMMddHHmmss'

function Report($action, $target, $note = '') {
  '  {0,-9} {1,-34} {2}' -f $action, $target, $note | Write-Host
}

# Merge recursivo: os valores de $override vencem.
function Merge-Json($base, $override) {
  $result = $base.PSObject.Copy()
  foreach ($p in $override.PSObject.Properties) {
    if ($result.PSObject.Properties.Name -contains $p.Name -and
        $p.Value -is [PSCustomObject] -and
        $result.($p.Name) -is [PSCustomObject]) {
      $result.($p.Name) = Merge-Json $result.($p.Name) $p.Value
    } else {
      $result | Add-Member -Force -NotePropertyName $p.Name -NotePropertyValue $p.Value
    }
  }
  return $result
}

foreach ($d in @('hooks','skills','agents','commands')) {
  New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir $d) | Out-Null
}
Write-Host ''

# --- settings.json ---
$Settings = Join-Path $ClaudeDir 'settings.json'
if (Test-Path $Settings) {
  Copy-Item $Settings "$Settings.bak.$Stamp"
  Report 'backup' 'settings.json' "-> settings.json.bak.$Stamp"
} else {
  '{}' | Set-Content $Settings
  Report 'criar' 'settings.json' '[novo]'
}

$tpl  = Get-Content (Join-Path $Repo 'config\settings.template.json') -Raw | ConvertFrom-Json
$user = Get-Content $Settings -Raw | ConvertFrom-Json
(Merge-Json $tpl $user) | ConvertTo-Json -Depth 100 | Set-Content $Settings
Report 'merge' 'settings.json' 'customizacoes preservadas'

# --- mcpServers ---
if (-not (Test-Path $ClaudeJson)) { '{}' | Set-Content $ClaudeJson }
$cfg    = Get-Content $ClaudeJson -Raw | ConvertFrom-Json
$mcpTpl = Get-Content (Join-Path $Repo 'config\mcp-servers.template.json') -Raw | ConvertFrom-Json
$existing = if ($cfg.PSObject.Properties.Name -contains 'mcpServers') { $cfg.mcpServers } else { [PSCustomObject]@{} }
$cfg | Add-Member -Force -NotePropertyName 'mcpServers' -NotePropertyValue (Merge-Json $mcpTpl $existing)
$cfg | ConvertTo-Json -Depth 100 | Set-Content $ClaudeJson
Report 'merge' 'mcpServers (11)' ''

# --- artefatos ---
Copy-Item (Join-Path $Repo 'config\CLAUDE.md') (Join-Path $ClaudeDir 'CLAUDE.md') -Force
Report 'copiar' 'CLAUDE.md' ''
Copy-Item (Join-Path $Repo 'config\RTK.md') (Join-Path $ClaudeDir 'RTK.md') -Force
Report 'copiar' 'RTK.md' ''
Copy-Item (Join-Path $Repo 'config\hooks\prettier-hook.py') (Join-Path $ClaudeDir 'hooks\prettier-hook.py') -Force
Report 'copiar' 'hooks/prettier-hook.py' ''

foreach ($kind in @('skills','agents','commands')) {
  Get-ChildItem (Join-Path $Repo $kind) -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName (Join-Path $ClaudeDir $kind) -Recurse -Force
    Report 'copiar' "$kind/$($_.Name)" ''
  }
}

# --- acoes manuais ---
Write-Host ''
Write-Host '  ACAO MANUAL:'
$missing = 0
foreach ($v in @('GITHUB_PERSONAL_ACCESS_TOKEN','BRAVE_API_KEY')) {
  if (-not [Environment]::GetEnvironmentVariable($v)) {
    Write-Host "    - $v nao definido"; $missing++
  }
}
if ($missing -eq 0) { Write-Host '    - nenhuma' }
Write-Host '    ver docs/setup/03-mcp-servers.md'
Write-Host ''
Write-Host '  Proximo passo: abra o Claude Code e rode /preflight'
