#!/usr/bin/env bash
# Instala a configuracao em ~/.claude. Idempotente.
# Nunca sobrescreve settings.json — faz merge campo a campo, e o valor do
# usuario vence em caso de conflito.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
STAMP="$(date +%Y%m%d%H%M%S)"

report() { printf '  %-9s %-34s %s\n' "$1" "$2" "${3:-}"; }

if ! command -v jq >/dev/null 2>&1; then
  echo "erro: jq nao encontrado. Instale antes de continuar:" >&2
  echo "  macOS:  brew install jq" >&2
  echo "  Debian: sudo apt-get install jq" >&2
  exit 1
fi

mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"
echo

# --- settings.json ---
SETTINGS="$CLAUDE_DIR/settings.json"
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak.$STAMP"
  report "backup" "settings.json" "-> settings.json.bak.$STAMP"
else
  echo '{}' > "$SETTINGS"
  report "criar" "settings.json" "[novo]"
fi

# O valor existente do usuario prevalece: template primeiro, usuario depois.
# `*` faz merge recursivo em jq.
merged="$(jq -s '.[0] * .[1]' "$REPO/config/settings.template.json" "$SETTINGS")"
printf '%s\n' "$merged" > "$SETTINGS"
report "merge" "settings.json" "customizacoes preservadas"

# --- mcpServers ---
if [ ! -s "$CLAUDE_JSON" ]; then
  echo '{}' > "$CLAUDE_JSON"
fi
merged_mcp="$(jq -s '.[0] as $cfg | .[1] as $tpl
  | $cfg | .mcpServers = ($tpl * ($cfg.mcpServers // {}))' \
  "$CLAUDE_JSON" "$REPO/config/mcp-servers.template.json")"
printf '%s\n' "$merged_mcp" > "$CLAUDE_JSON"
report "merge" "mcpServers (11)" ""

# --- artefatos ---
cp "$REPO/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"; report "copiar" "CLAUDE.md" ""
cp "$REPO/config/RTK.md"    "$CLAUDE_DIR/RTK.md";    report "copiar" "RTK.md" ""
cp "$REPO/config/hooks/prettier-hook.py" "$CLAUDE_DIR/hooks/prettier-hook.py"
chmod +x "$CLAUDE_DIR/hooks/prettier-hook.py"
report "copiar" "hooks/prettier-hook.py" ""

for kind in skills agents commands; do
  for item in "$REPO/$kind"/*; do
    [ -e "$item" ] || continue
    cp -R "$item" "$CLAUDE_DIR/$kind/"
    report "copiar" "$kind/$(basename "$item")" ""
  done
done

# --- acoes manuais ---
echo
echo "  ACAO MANUAL:"
missing=0
for var in GITHUB_PERSONAL_ACCESS_TOKEN BRAVE_API_KEY; do
  eval "val=\${$var:-}"
  if [ -z "$val" ]; then
    echo "    - $var nao definido"
    missing=$((missing + 1))
  fi
done
[ "$missing" -eq 0 ] && echo "    - nenhuma"
echo "    ver docs/setup/03-mcp-servers.md"
echo
echo "  Proximo passo: abra o Claude Code e rode /preflight"
