# Reestruturação do Repositório de Configuração — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformar `my-claude-code-config` num artefato instalável por script, com documentação navegável e garantia automatizada de que nenhum segredo ou referência interna vaze.

**Architecture:** Um sanitizador em shell é a peça central — `sync.sh` (local → repositório) e o CI consomem a mesma biblioteca e a mesma lista de padrões proibidos, de modo que não existe caminho pelo qual um segredo entre no repositório sem falhar o build. `install.sh` percorre o sentido oposto, fazendo merge campo a campo no `settings.json` do usuário em vez de sobrescrevê-lo. A documentação se divide em trilha ordenada (`docs/setup/`) e catálogo (`docs/reference/`), com cada assunto descrito em exatamente um arquivo.

**Tech Stack:** Bash 3.2 (padrão do macOS), `jq`, PowerShell 5.1, GitHub Actions (gitleaks, lychee, shellcheck), Python 3 apenas para o hook de prettier já existente.

**Spec:** `docs/superpowers/specs/2026-08-18-config-repo-design.md`

## Global Constraints

- **Bash 3.2.** macOS não traz Bash 4. Proibido: `declare -A`, `${var,,}`, `readarray`, `mapfile`.
- **Dependência externa única em runtime: `jq`.** Sem bats, sem Node para os testes. O harness de teste é shell puro dentro de `tests/`.
- **`gitleaks`, `shellcheck` e `lychee` só existem no CI.** `make check` local deve pular a etapa com aviso quando o binário não estiver presente, e nunca falhar por ausência.
- **Idioma da documentação: português do Brasil.** Nomes de arquivo sem acento.
- **A string `oliv-e` (em qualquer caixa) não pode existir em nenhum arquivo do repositório.** É item da lista de padrões proibidos e falha o CI.
- **Nenhum caminho absoluto de usuário** (`/Users/...`, `/home/...`) em arquivo versionado. Use `$HOME` ou placeholder.
- **`settings.local.json` não é lido, copiado nem referenciado por nenhum script.**
- **Cada arquivo de documentação: máximo ~300 linhas.** Acima disso, dividir.
- **Todo script shell começa com `#!/usr/bin/env bash` e `set -euo pipefail`.**
- Identificadores de modelo Claude **nunca** são escritos de memória. Consultar a skill `claude-api` antes de escrever `docs/reference/modelos.md`.

## Estrutura de arquivos

| Arquivo | Responsabilidade |
|---|---|
| `scripts/lib/sanitize.sh` | Única fonte das regras de sanitização e da lista de padrões proibidos. Consumido por `sync.sh`, `check-drift.sh` e `make check`. |
| `scripts/lib/patterns.txt` | Padrões proibidos, um por linha, em formato ERE. Lido pelo sanitizador e pelo CI. |
| `scripts/sync.sh` | Local → repositório. Aplica denylist de artefato, sanitiza, verifica, escreve. |
| `scripts/check-drift.sh` | Somente leitura. Reporta divergência entre local e repositório. |
| `scripts/install.sh` / `.ps1` | Repositório → local. Merge idempotente, backup, relatório de ação manual. |
| `config/*.template.json` | Configuração sanitizada, pronta para merge. Gerada, nunca editada à mão. |
| `config/hooks/prettier-hook.py` | Hook `PostToolUse` referenciado pelo template. Hoje vive só na máquina do autor. |
| `tests/run.sh` + `tests/test_*.sh` | Harness e casos. Um arquivo de teste por componente. |
| `docs/setup/NN-*.md` | Trilha ordenada de onboarding. |
| `docs/reference/*.md` | Catálogo. Fonte única por assunto. |
| `docs/concepts/*.md` | O porquê. |

---

### Task 1: Guard-rails e harness de teste

Guard-rail antes de qualquer arquivo de configuração entrar no repositório. Esta task não move nenhum dado — cria a rede.

**Files:**
- Create: `LICENSE`, `.gitignore`, `Makefile`, `.github/workflows/ci.yml`
- Create: `scripts/lib/patterns.txt`, `.gitleaks.toml`
- Create: `tests/run.sh`, `tests/lib/assert.sh`, `tests/test_guardrails.sh`

**Interfaces:**
- Consumes: nada
- Produces: `tests/lib/assert.sh` expondo `assert_file_exists`, `assert_contains`, `assert_not_contains`, `assert_eq`, `assert_exit_code`, e a variável `FAILURES`. Todas as tasks seguintes usam esse contrato. `tests/run.sh` exporta `REPO` (raiz absoluta do repositório) para os arquivos de teste. `scripts/lib/patterns.txt` é lido por `grep -E -f`.

- [ ] **Step 1: Escrever o harness de asserção**

`tests/lib/assert.sh`:

```bash
#!/usr/bin/env bash
# Helpers de asserção. Cada arquivo de teste deve terminar com `exit $FAILURES`.
: "${REPO:?REPO nao definido — rode via tests/run.sh}"

FAILURES=0

_pass() { printf '  ok    %s\n' "$1"; }
_fail() { printf '  FALHA %s\n' "$1"; FAILURES=$((FAILURES + 1)); }

assert_file_exists() {
  if [ -f "$1" ]; then _pass "existe: $1"; else _fail "nao existe: $1"; fi
}

assert_contains() {
  case "$1" in
    *"$2"*) _pass "contem: $2" ;;
    *)      _fail "nao contem: $2" ;;
  esac
}

assert_not_contains() {
  case "$1" in
    *"$2"*) _fail "contem (nao deveria): $2" ;;
    *)      _pass "ausente: $2" ;;
  esac
}

assert_eq() {
  if [ "$1" = "$2" ]; then _pass "igual: $2"; else _fail "esperado '$2', obtido '$1'"; fi
}

assert_exit_code() {
  want=$1; shift
  "$@" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then _pass "exit $want"; else _fail "exit esperado $want, obtido $got"; fi
}
```

- [ ] **Step 2: Escrever o runner**

`tests/run.sh`:

```bash
#!/usr/bin/env bash
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
export REPO

total=0
for t in "$REPO"/tests/test_*.sh; do
  [ -f "$t" ] || continue
  printf '\n== %s\n' "$(basename "$t")"
  bash "$t"
  total=$((total + $?))
done

printf '\n'
if [ "$total" -eq 0 ]; then
  echo "todos os testes passaram"
  exit 0
fi
echo "$total asserção(ões) falharam"
exit 1
```

- [ ] **Step 3: Escrever o teste que falha**

`tests/test_guardrails.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/LICENSE"
assert_file_exists "$REPO/.gitignore"
assert_file_exists "$REPO/Makefile"
assert_file_exists "$REPO/.github/workflows/ci.yml"
assert_file_exists "$REPO/scripts/lib/patterns.txt"
assert_file_exists "$REPO/.gitleaks.toml"

# As fixtures carregam valores falsos que casam com os padroes de proposito.
# Sem essa excecao, a rede de seguranca dispara nos proprios testes dela.
assert_contains "$(cat "$REPO/.gitleaks.toml" 2>/dev/null)" "tests/fixtures"

assert_contains "$(cat "$REPO/LICENSE" 2>/dev/null)" "MIT License"

# settings.local.json nunca pode ser versionado — contem credenciais.
assert_contains "$(cat "$REPO/.gitignore" 2>/dev/null)" "settings.local.json"

# A lista de padroes proibidos precisa cobrir os quatro vetores conhecidos.
patterns="$(cat "$REPO/scripts/lib/patterns.txt" 2>/dev/null)"
assert_contains "$patterns" "ghp_"
assert_contains "$patterns" "X-Metabase-Session"
assert_contains "$patterns" "MYSQL_PASSWORD"
assert_contains "$patterns" "PRIVATE KEY"

exit $FAILURES
```

- [ ] **Step 4: Rodar e confirmar que falha**

Run: `chmod +x tests/run.sh && ./tests/run.sh`
Expected: FALHA em todas as asserções de `assert_file_exists` — nenhum dos arquivos existe ainda. Saída termina com `5 asserção(ões) falharam` ou número maior. Exit code 1.

- [ ] **Step 5: Criar LICENSE**

`LICENSE` — MIT, titular `Lucas Andrade`, ano `2026`. Texto canônico do MIT, sem alteração de cláusula.

- [ ] **Step 6: Criar .gitignore**

```gitignore
# Nunca versionar: contem credenciais em texto puro
settings.local.json
*.local.json
.env
*.bak
*.bak.*

# Artefatos de sistema
.DS_Store
Thumbs.db

# Saida de ferramenta
node_modules/
.cache/
```

- [ ] **Step 7: Criar a lista de padrões proibidos**

`scripts/lib/patterns.txt` — formato ERE, um por linha, comentários com `#`:

```
# Tokens do GitHub
ghp_[A-Za-z0-9]{20,}
github_pat_[A-Za-z0-9_]{20,}
# Chave da API Brave
BSA[A-Za-z0-9_-]{20,}
# Sessao do Metabase
X-Metabase-Session
# Variaveis de banco que carregavam valor real
MYSQL_PASSWORD
# Chave privada
-----BEGIN [A-Z ]*PRIVATE KEY-----
# Referencia interna que nao pode sair (decisao D1 do spec)
[Oo][Ll][Ii][Vv]-?[Ee]
# Caminho absoluto de usuario
/Users/[a-z]
/home/[a-z]
```

- [ ] **Step 7b: Criar a excecao para as fixtures**

`tests/fixtures/` contem valores falsos que casam com os padroes proibidos de
proposito — e o que os testes de sanitizacao consomem. Sem excecao explicita, a
varredura dispara nos proprios testes dela e o CI nunca fica verde.

`.gitleaks.toml`:

```toml
[extend]
useDefault = true

[[allowlists]]
description = "fixtures de teste: valores falsos, por design"
paths = ['''tests/fixtures/.*''']
```

- [ ] **Step 8: Criar o Makefile**

```makefile
.PHONY: help install sync check test

help:
	@echo "install  instala a configuracao em ~/.claude"
	@echo "sync     copia ~/.claude para o repositorio, sanitizando"
	@echo "check    roda testes, varredura de segredo, links e shellcheck"
	@echo "test     roda apenas os testes"

install:
	@./scripts/install.sh

sync:
	@./scripts/sync.sh

test:
	@./tests/run.sh

check: test
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks detect --source . --config .gitleaks.toml --no-banner; \
	else echo "aviso: gitleaks ausente, varredura pulada (o CI executa)"; fi
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh tests/lib/*.sh; \
	else echo "aviso: shellcheck ausente, analise pulada (o CI executa)"; fi
	@if command -v lychee >/dev/null 2>&1; then \
		lychee --offline README.md 'docs/**/*.md'; \
	else echo "aviso: lychee ausente, checagem de link pulada (o CI executa)"; fi
	@./scripts/check-drift.sh || true
```

Nota: o Makefile exige TAB de indentação, não espaço.

- [ ] **Step 9: Criar o workflow de CI**

`.github/workflows/ci.yml`:

```yaml
name: ci

on:
  push:
  pull_request:

jobs:
  secrets:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITLEAKS_CONFIG: .gitleaks.toml
      - name: padroes proibidos do repositorio
        run: |
          if grep -rInE -f scripts/lib/patterns.txt \
               --exclude-dir=.git --exclude-dir=fixtures \
               --exclude=patterns.txt . ; then
            echo "::error::padrao proibido encontrado"
            exit 1
          fi
          echo "nenhum padrao proibido encontrado"

  shell:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@master
        with:
          scandir: './scripts'

  links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: lycheeverse/lychee-action@v2
        with:
          args: --no-progress --verbose './**/*.md'
          fail: true

  tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get update && sudo apt-get install -y jq
      - run: ./tests/run.sh
```

- [ ] **Step 10: Rodar os testes e confirmar que passam**

Run: `./tests/run.sh`
Expected: PASS em todas as asserções. `todos os testes passaram`, exit 0.

- [ ] **Step 11: Commit**

```bash
git add LICENSE .gitignore Makefile .gitleaks.toml .github/ scripts/lib/patterns.txt tests/
git commit -m "chore: guard-rails de seguranca e harness de teste

A configuracao local carrega credenciais em texto puro. Como o
repositorio e compartilhado externamente e o historico do git preserva
erro de copia, a varredura precisa existir antes de qualquer arquivo de
configuracao ser movido para ca — nao depois.

A lista de padroes proibidos fica num arquivo unico, lido tanto pelo CI
quanto pelo sanitizador, para que as duas barreiras nunca divirjam."
```

---

### Task 2: Biblioteca de sanitização

**Files:**
- Create: `scripts/lib/sanitize.sh`
- Create: `tests/test_sanitize.sh`
- Create: `tests/fixtures/settings.dirty.json`, `tests/fixtures/mcp.dirty.json`

**Interfaces:**
- Consumes: `scripts/lib/patterns.txt` (Task 1)
- Produces: três funções, todas lendo caminho de arquivo em `$1` e escrevendo JSON em stdout, exceto `scan_secrets`:
  - `sanitize_settings <arquivo>` → stdout JSON
  - `sanitize_mcp <arquivo>` → stdout JSON
  - `scan_secrets <caminho>` → exit 0 se limpo, exit 1 se encontrou padrão proibido; imprime as ocorrências em stderr

  `sync.sh` (Task 5), `check-drift.sh` (Task 6) e os testes consomem essas três.

- [ ] **Step 1: Criar as fixtures**

`tests/fixtures/settings.dirty.json` — reproduz a forma do arquivo real, com valores falsos:

```json
{
  "env": {
    "MYSQL_PASSWORD": "senha-falsa-de-teste",
    "ANTHROPIC_MODEL": "claude-sonnet-4-6"
  },
  "permissions": {
    "allow": [
      "Bash(gh pr *)",
      "Bash(kubectl get:*)",
      "Bash(/bin/ls /Users/fulano/Projetos)",
      "Bash(curl -s -H 'X-Metabase-Session: aaaabbbbccccdddd' https://exemplo.interno/api)"
    ],
    "defaultMode": "auto"
  },
  "model": "opus[1m]",
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [ { "type": "command", "command": "rtk hook claude" } ] }
    ],
    "PostToolUse": [
      { "matcher": "Edit|Write", "hooks": [ { "type": "command", "command": "python3 /Users/fulano/.claude/prettier-hook.py" } ] }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash \"/Users/fulano/.claude/plugins/cache/caveman/caveman/ef6050c5e184/hooks/caveman-statusline.sh\""
  },
  "enabledPlugins": { "superpowers@claude-plugins-official": true },
  "effortLevel": "medium",
  "theme": "dark",
  "autoMode": { "environment": ["**Trusted repo**: /Users/fulano/projeto"] }
}
```

`tests/fixtures/mcp.dirty.json`:

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_aaaabbbbccccddddeeeeffff0000" }
  },
  "filesystem": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/fulano/Projetos"],
    "env": {}
  }
}
```

- [ ] **Step 2: Escrever o teste que falha**

`tests/test_sanitize.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"
. "$REPO/scripts/lib/sanitize.sh" 2>/dev/null || true

F="$REPO/tests/fixtures"

out="$(sanitize_settings "$F/settings.dirty.json" 2>/dev/null)"

# Remove o que vaza
assert_not_contains "$out" "MYSQL_PASSWORD"
assert_not_contains "$out" "X-Metabase-Session"
assert_not_contains "$out" "/Users/fulano"
assert_not_contains "$out" "autoMode"
assert_not_contains "$out" "statusLine"

# Preserva o que e generico
assert_contains "$out" "rtk hook claude"
assert_contains "$out" "enabledPlugins"
assert_contains "$out" "Bash(gh pr *)"
assert_contains "$out" "opus[1m]"

# O hook de prettier sobrevive, com caminho portatil
assert_contains "$out" "\$HOME/.claude/hooks/prettier-hook.py"

# Saida continua sendo JSON valido
assert_exit_code 0 sh -c "printf '%s' '$out' | jq -e . >/dev/null"

mcp="$(sanitize_mcp "$F/mcp.dirty.json" 2>/dev/null)"
assert_not_contains "$mcp" "ghp_"
assert_contains "$mcp" "\${GITHUB_PERSONAL_ACCESS_TOKEN}"
assert_not_contains "$mcp" "/Users/fulano"
assert_contains "$mcp" "\$WORKSPACE_DIR"

# scan_secrets: 1 no arquivo sujo, 0 na saida limpa
assert_exit_code 1 scan_secrets "$F/settings.dirty.json"
printf '%s' "$out" > "$F/../tmp.clean.json"
assert_exit_code 0 scan_secrets "$F/../tmp.clean.json"
rm -f "$F/../tmp.clean.json"

exit $FAILURES
```

- [ ] **Step 3: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_sanitize.sh` falha em todas as asserções — `sanitize_settings` não existe, `$out` fica vazio.

- [ ] **Step 4: Implementar a biblioteca**

`scripts/lib/sanitize.sh`:

```bash
#!/usr/bin/env bash
# Regras de sanitizacao. Fonte unica: sync.sh, check-drift.sh e os testes
# consomem estas funcoes. Nenhum outro lugar deve reimplementar a logica.

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_FILE="${PATTERNS_FILE:-$_LIB_DIR/patterns.txt}"

# Remove de settings.json tudo que e especifico da maquina ou sigiloso.
# - env: removido por inteiro. Carrega senha e nomes de projeto de nuvem.
# - autoMode: descreve a maquina do autor.
# - statusLine: aponta para um caminho de plugin com hash de instalacao,
#   que nao existe em outra maquina. A documentacao explica como ativar.
# - permissions.allow: mantido apenas o que nao carrega caminho absoluto,
#   URL, credencial ou cadeia longa parecida com token.
# - hook de prettier: caminho reescrito para $HOME, portatil.
sanitize_settings() {
  jq '
    del(.env)
    | del(.autoMode)
    | del(.statusLine)
    | if (.permissions.allow? | type) == "array" then
        .permissions.allow |= map(select(
          (test("/Users/|/home/|https?://|password|secret|session|token"; "i") | not)
          and (test("[A-Za-z0-9_-]{24,}") | not)
        ))
      else . end
    | if (.hooks.PostToolUse? | type) == "array" then
        .hooks.PostToolUse |= map(
          .hooks |= map(
            if (.command? // "") | test("prettier-hook\\.py")
            then .command = "python3 $HOME/.claude/hooks/prettier-hook.py"
            else . end))
      else . end
  ' "$1"
}

# Substitui todo valor de env por referencia a variavel de ambiente e troca
# o diretorio de trabalho do autor por placeholder.
sanitize_mcp() {
  jq --arg home "$HOME" '
    with_entries(
      .value |= (
        (if (.env? | type) == "object"
         then .env |= with_entries(.value = "${" + .key + "}")
         else . end)
        | (if (.args? | type) == "array"
           then .args |= map(if type == "string" then gsub($home + "/[A-Za-z]+"; "$WORKSPACE_DIR") else . end)
           else . end)
      )
    )
  ' "$1"
}

# Retorna 1 se algum padrao proibido aparecer. Usado por sync.sh antes de
# escrever e por make check depois.
scan_secrets() {
  local target="$1"
  if grep -rInE -f "$PATTERNS_FILE" "$target" >&2; then
    return 1
  fi
  return 0
}
```

- [ ] **Step 5: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_sanitize.sh` PASS em todas as asserções.

- [ ] **Step 6: Commit**

```bash
git add scripts/lib/sanitize.sh tests/test_sanitize.sh tests/fixtures/
git commit -m "feat: biblioteca de sanitizacao de configuracao

Concentra numa funcao so a decisao do que pode sair da maquina. Sync,
checagem de divergencia e testes consomem daqui, de modo que afrouxar a
regra num lugar nao deixa o outro passar.

statusLine sai do template porque o comando aponta para um caminho de
plugin com hash de instalacao — valido so na maquina de origem. A
documentacao cobre a ativacao manual."
```

---

### Task 3: Templates de configuração

**Files:**
- Create: `config/settings.template.json`, `config/mcp-servers.template.json`
- Create: `config/hooks/prettier-hook.py`
- Create: `tests/test_templates.sh`

**Interfaces:**
- Consumes: `sanitize_settings`, `sanitize_mcp`, `scan_secrets` (Task 2)
- Produces: os dois templates. `install.sh` (Task 7) faz merge de `config/settings.template.json` no `~/.claude/settings.json` do usuário, e usa `config/mcp-servers.template.json` para popular `mcpServers` em `~/.claude.json`. `config/hooks/prettier-hook.py` é copiado para `~/.claude/hooks/prettier-hook.py` — caminho que o template referencia.

- [ ] **Step 1: Escrever o teste que falha**

`tests/test_templates.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"
. "$REPO/scripts/lib/sanitize.sh"

S="$REPO/config/settings.template.json"
M="$REPO/config/mcp-servers.template.json"

assert_file_exists "$S"
assert_file_exists "$M"
assert_file_exists "$REPO/config/hooks/prettier-hook.py"

assert_exit_code 0 jq -e . "$S"
assert_exit_code 0 jq -e . "$M"

# env precisa estar ausente ou vazio — nunca com chave dentro
assert_eq "$(jq -r '(.env // {}) | length' "$S")" "0"

# o que precisa sobreviver
assert_eq "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' "$S")" "rtk hook claude"
assert_eq "$(jq -r '.enabledPlugins | length' "$S")" "12"
assert_eq "$(jq -r 'has("statusLine")' "$S")" "false"
assert_eq "$(jq -r 'has("autoMode")' "$S")" "false"

# os 11 servers de MCP, todos com credencial como placeholder
assert_eq "$(jq -r 'length' "$M")" "11"
assert_eq "$(jq -r '.github.env.GITHUB_PERSONAL_ACCESS_TOKEN' "$M")" '${GITHUB_PERSONAL_ACCESS_TOKEN}'
assert_eq "$(jq -r '."brave-search".env.BRAVE_API_KEY' "$M")" '${BRAVE_API_KEY}'

assert_exit_code 0 scan_secrets "$REPO/config"

exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_templates.sh` falha — `config/` não existe.

- [ ] **Step 3: Gerar os templates a partir da configuração local**

```bash
mkdir -p config/hooks
. scripts/lib/sanitize.sh
sanitize_settings ~/.claude/settings.json > config/settings.template.json
jq '.mcpServers' ~/.claude.json | sanitize_mcp /dev/stdin > config/mcp-servers.template.json
cp ~/.claude/prettier-hook.py config/hooks/prettier-hook.py
```

- [ ] **Step 4: Inspecionar o resultado à mão**

Run: `jq . config/settings.template.json && jq . config/mcp-servers.template.json`

Confirme, lendo: nenhuma senha, nenhum nome de projeto de nuvem, nenhum caminho `/Users/`, nenhum token. Os 11 servers presentes: `filesystem`, `git`, `github`, `memory`, `sqlite`, `sequential-thinking`, `brave-search`, `fetch`, `serena`, `docker`, `supabase`.

Corrija à mão o que a sanitização automática não pegou. Dois casos conhecidos:
- `supabase.args` termina em `--access-token` sem valor — configuração incompleta na origem. Deixe como está no template e registre em `docs/reference/mcp-servers.md` que o argumento precisa de valor.
- `serena.args` contém o diretório de trabalho; confirme que virou `$WORKSPACE_DIR`.

- [ ] **Step 5: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_templates.sh` PASS.

- [ ] **Step 6: Commit**

```bash
git add config/
git commit -m "feat: templates sanitizados de settings e MCP servers

Gerados pela biblioteca de sanitizacao, nunca editados a mao — editar
manualmente reabre a porta que a Task 2 fechou.

O hook de prettier passa a viver no repositorio. Ate agora o settings
apontava para um arquivo que so existia na maquina do autor, entao quem
copiasse a configuracao ganhava um hook quebrado."
```

---

### Task 4: Artefatos sob denylist

**Files:**
- Create: `scripts/lib/denylist.txt`
- Create: `skills/spec-driven/SKILL.md` (copiado de `~/.claude/skills/spec-driven/`)
- Create: `commands/review.md` (copiado de `~/.claude/commands/`)
- Create: `config/CLAUDE.md`, `config/RTK.md`
- Modify: `agents/pr-reviewer.md`, `commands/preflight.md` (sincronizar com a versão local, sanitizados)
- Delete: `CLAUDE.md` (raiz — move para `config/`)
- Create: `tests/test_artefatos.sh`

**Interfaces:**
- Consumes: `scan_secrets` (Task 2)
- Produces: `scripts/lib/denylist.txt` — um nome de artefato por linha, lido por `sync.sh` (Task 5) e `check-drift.sh` (Task 6) com `grep -Fxq`.

- [ ] **Step 1: Criar a denylist**

`scripts/lib/denylist.txt`:

```
# Artefatos que nunca saem da maquina local (decisao D1 do spec).
# Um nome por linha, sem barra. Comparado com o basename do arquivo ou
# do diretorio da skill.
jira-task
olive-design-system
clinical-metrics-analyst
health-data-security-reviewer
```

- [ ] **Step 2: Escrever o teste que falha**

`tests/test_artefatos.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"
. "$REPO/scripts/lib/sanitize.sh"

assert_file_exists "$REPO/scripts/lib/denylist.txt"
assert_file_exists "$REPO/skills/spec-driven/SKILL.md"
assert_file_exists "$REPO/commands/review.md"
assert_file_exists "$REPO/commands/preflight.md"
assert_file_exists "$REPO/agents/pr-reviewer.md"
assert_file_exists "$REPO/agents/domain-analyst.md"
assert_file_exists "$REPO/config/CLAUDE.md"
assert_file_exists "$REPO/config/RTK.md"

# CLAUDE.md saiu da raiz
if [ -f "$REPO/CLAUDE.md" ]; then
  _fail "CLAUDE.md ainda na raiz — deve estar em config/"
else
  _pass "CLAUDE.md movido para config/"
fi

# Nenhum artefato da denylist vazou
while IFS= read -r name; do
  case "$name" in ''|\#*) continue ;; esac
  if find "$REPO/skills" "$REPO/agents" "$REPO/commands" -name "*$name*" 2>/dev/null | grep -q .; then
    _fail "artefato da denylist presente: $name"
  else
    _pass "denylist respeitada: $name"
  fi
done < "$REPO/scripts/lib/denylist.txt"

# CLAUDE.md nao pode mais referenciar RTK.md por caminho de raiz
assert_contains "$(cat "$REPO/config/CLAUDE.md")" "RTK.md"

assert_exit_code 0 scan_secrets "$REPO/skills"
assert_exit_code 0 scan_secrets "$REPO/agents"
assert_exit_code 0 scan_secrets "$REPO/commands"
assert_exit_code 0 scan_secrets "$REPO/config"

exit $FAILURES
```

- [ ] **Step 3: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_artefatos.sh` falha nos arquivos ausentes e em `CLAUDE.md ainda na raiz`.

- [ ] **Step 4: Copiar e sanitizar os artefatos**

```bash
mkdir -p skills config
cp -R ~/.claude/skills/spec-driven skills/
cp ~/.claude/commands/review.md commands/review.md
cp ~/.claude/commands/preflight.md commands/preflight.md
cp ~/.claude/agents/pr-reviewer.md agents/pr-reviewer.md
cp ~/.claude/RTK.md config/RTK.md
git mv CLAUDE.md config/CLAUDE.md
```

- [ ] **Step 5: Remover as referências internas à mão**

Rode `grep -rInE -f scripts/lib/patterns.txt skills agents commands config` e corrija cada ocorrência. Alvos conhecidos:

- `agents/pr-reviewer.md` — a versão local diz "revisor de código experiente da **Empresa**"; remova o nome da empresa mantendo o resto do prompt.
- `commands/preflight.md` e `commands/review.md` — remova menção a repositório ou ambiente interno; troque exemplo de `owner/repo` por `owner/repo` genérico.
- `config/CLAUDE.md` — remova por inteiro as seções "Contexto: Plataforma ..." e "Subagent Dispatch" caso a versão local seja copiada. A versão que está em `config/` (vinda da raiz) já é genérica; confirme com o grep.
- `config/CLAUDE.md` — a diretiva `@RTK.md` continua válida, porque `install.sh` deposita os dois arquivos lado a lado em `~/.claude/`.

- [ ] **Step 6: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_artefatos.sh` PASS.

- [ ] **Step 7: Commit**

```bash
git add -A skills agents commands config scripts/lib/denylist.txt tests/test_artefatos.sh
git commit -m "feat: artefatos sincronizados sob lista de exclusao

Traz a skill spec-driven, o command /review e o RTK.md, que existiam so
na maquina local — o CLAUDE.md ja fazia @RTK.md, entao quem clonava
recebia uma referencia quebrada.

CLAUDE.md sai da raiz para config/, junto dos demais arquivos que o
Claude consome. A raiz passa a conter so o que humano le.

A lista de exclusao vira arquivo em vez de convencao, para que o sync
nao dependa de alguem lembrar quais artefatos sao internos."
```

---

### Task 5: `sync.sh`

**Files:**
- Create: `scripts/sync.sh`
- Create: `tests/test_sync.sh`

**Interfaces:**
- Consumes: `sanitize_settings`, `sanitize_mcp`, `scan_secrets` (Task 2); `scripts/lib/denylist.txt` (Task 4)
- Produces: `scripts/sync.sh`, aceitando a flag `--dry-run` (relata sem escrever). Sem flag, escreve. Sai com 1 sem escrever nada se a verificação de segredo falhar.

- [ ] **Step 1: Escrever o teste que falha**

`tests/test_sync.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/scripts/sync.sh"

# --dry-run nao pode alterar o repositorio
before="$(git -C "$REPO" status --porcelain)"
out="$(bash "$REPO/scripts/sync.sh" --dry-run 2>&1)"
after="$(git -C "$REPO" status --porcelain)"
assert_eq "$after" "$before"

# o relatorio precisa nomear a denylist aplicada
assert_contains "$out" "denylist"

# nenhum artefato interno pode aparecer como copiado
assert_not_contains "$out" "copiar   skills/jira-task"

exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_sync.sh` falha — `scripts/sync.sh` não existe.

- [ ] **Step 3: Implementar**

`scripts/sync.sh`:

```bash
#!/usr/bin/env bash
# Copia a configuracao local para o repositorio, sanitizando.
# Direcao unica: local -> repositorio. Nunca o contrario (decisao D5).
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
. "$REPO/scripts/lib/sanitize.sh"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
DENYLIST="$REPO/scripts/lib/denylist.txt"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

report() { printf '  %-8s %s\n' "$1" "$2"; }

# 0 = permitido, 1 = na denylist
allowed() {
  local base="$1" line
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; esac
    [ "$base" = "$line" ] && return 1
  done < "$DENYLIST"
  return 0
}

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

echo "sync: $CLAUDE_DIR -> $REPO"
echo

# --- artefatos ---
for kind in skills agents commands; do
  [ -d "$CLAUDE_DIR/$kind" ] || continue
  mkdir -p "$STAGE/$kind"
  for item in "$CLAUDE_DIR/$kind"/*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    base="${base%.md}"
    if allowed "$base"; then
      cp -R "$item" "$STAGE/$kind/"
      report "copiar" "$kind/$(basename "$item")"
    else
      report "denylist" "$kind/$(basename "$item") — artefato interno, ignorado"
    fi
  done
done

# --- configuracao ---
mkdir -p "$STAGE/config"
sanitize_settings "$CLAUDE_DIR/settings.json" > "$STAGE/config/settings.template.json"
report "sanitizar" "config/settings.template.json"

jq '.mcpServers' "$CLAUDE_JSON" > "$STAGE/mcp.raw.json"
sanitize_mcp "$STAGE/mcp.raw.json" > "$STAGE/config/mcp-servers.template.json"
rm -f "$STAGE/mcp.raw.json"
report "sanitizar" "config/mcp-servers.template.json"

[ -f "$CLAUDE_DIR/prettier-hook.py" ] && {
  mkdir -p "$STAGE/config/hooks"
  cp "$CLAUDE_DIR/prettier-hook.py" "$STAGE/config/hooks/"
  report "copiar" "config/hooks/prettier-hook.py"
}

# --- verificacao antes de escrever ---
echo
if ! scan_secrets "$STAGE"; then
  echo "ABORTADO: padrao proibido encontrado na area de preparacao." >&2
  echo "Nada foi escrito no repositorio. Corrija a origem e rode de novo." >&2
  exit 1
fi
report "ok" "verificacao de segredo passou"

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "--dry-run: nada escrito."
  exit 0
fi

for kind in skills agents commands config; do
  [ -d "$STAGE/$kind" ] || continue
  cp -R "$STAGE/$kind/." "$REPO/$kind/"
done

echo
echo "sync concluido. Revise com: git diff"
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_sync.sh` PASS.

- [ ] **Step 5: Verificar manualmente com dry-run**

Run: `./scripts/sync.sh --dry-run`
Expected: linhas `denylist` para os quatro artefatos internos, `copiar` para os demais, `ok verificacao de segredo passou`, e `git status` inalterado.

- [ ] **Step 6: Commit**

```bash
git add scripts/sync.sh tests/test_sync.sh
git commit -m "feat: sync de configuracao local para o repositorio

Escreve numa area de preparacao, verifica, e so entao copia. A ordem
importa: verificar depois de escrever deixaria o segredo no diretorio de
trabalho, a um 'git add -A' de distancia do historico.

settings.local.json nao aparece na lista de origem — nao e sanitizado
nem ignorado, simplesmente nao existe para este script."
```

---

### Task 6: `check-drift.sh`

**Files:**
- Create: `scripts/check-drift.sh`
- Create: `tests/test_drift.sh`

**Interfaces:**
- Consumes: `scripts/lib/denylist.txt` (Task 4)
- Produces: `scripts/check-drift.sh`. Somente leitura. Exit 0 se alinhado, exit 1 se divergente. Nunca escreve.

- [ ] **Step 1: Escrever o teste que falha**

`tests/test_drift.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/scripts/check-drift.sh"

before="$(git -C "$REPO" status --porcelain)"
bash "$REPO/scripts/check-drift.sh" >/dev/null 2>&1 || true
after="$(git -C "$REPO" status --porcelain)"
assert_eq "$after" "$before"

# artefato interno nunca pode ser reportado como divergencia
out="$(bash "$REPO/scripts/check-drift.sh" 2>&1 || true)"
assert_not_contains "$out" "jira-task"
assert_not_contains "$out" "clinical-metrics-analyst"

exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_drift.sh` falha — script ausente.

- [ ] **Step 3: Implementar**

`scripts/check-drift.sh`:

```bash
#!/usr/bin/env bash
# Reporta divergencia entre a configuracao local e o repositorio.
# Somente leitura — nunca escreve. O CI nao consegue rodar isto, porque
# nao enxerga a maquina do mantenedor.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DENYLIST="$REPO/scripts/lib/denylist.txt"
DIFFS=0

allowed() {
  local base="$1" line
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; esac
    [ "$base" = "$line" ] && return 1
  done < "$DENYLIST"
  return 0
}

echo "drift: $CLAUDE_DIR <-> $REPO"
echo

for kind in skills agents commands; do
  for item in "$CLAUDE_DIR/$kind"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    allowed "${name%.md}" || continue
    if [ ! -e "$REPO/$kind/$name" ]; then
      printf '  so local    %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    elif ! diff -rq "$item" "$REPO/$kind/$name" >/dev/null 2>&1; then
      printf '  divergente  %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    fi
  done
  for item in "$REPO/$kind"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    if [ ! -e "$CLAUDE_DIR/$kind/$name" ]; then
      printf '  so no repo  %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    fi
  done
done

echo
if [ "$DIFFS" -eq 0 ]; then
  echo "alinhado."
  exit 0
fi
echo "$DIFFS divergencia(s). Rode 'make sync' para trazer o local para ca."
exit 1
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_drift.sh` PASS.

- [ ] **Step 5: Commit**

```bash
git add scripts/check-drift.sh tests/test_drift.sh
git commit -m "feat: relatorio de divergencia entre local e repositorio

Somente leitura, e de proposito. Reconciliacao automatica escolheria um
lado sem saber qual esta certo; o relatorio devolve a escolha a quem tem
o contexto."
```

---

### Task 7: `install.sh`

**Files:**
- Create: `scripts/install.sh`
- Create: `tests/test_install.sh`

**Interfaces:**
- Consumes: `config/settings.template.json`, `config/mcp-servers.template.json`, `config/hooks/prettier-hook.py` (Task 3); `skills/`, `agents/`, `commands/`, `config/CLAUDE.md`, `config/RTK.md` (Task 4)
- Produces: `scripts/install.sh`, respeitando `CLAUDE_DIR` e `CLAUDE_JSON` como variáveis de ambiente para permitir teste em diretório temporário. Nunca sobrescreve `settings.json`; faz merge campo a campo. Exit 0 em sucesso, exit 1 se `jq` faltar.

- [ ] **Step 1: Escrever o teste que falha**

`tests/test_install.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/scripts/install.sh"

TMP="$(mktemp -d)"
export CLAUDE_DIR="$TMP/.claude"
export CLAUDE_JSON="$TMP/.claude.json"
mkdir -p "$CLAUDE_DIR"

# Configuracao preexistente e customizada — nao pode ser perdida
cat > "$CLAUDE_DIR/settings.json" <<'JSON'
{ "theme": "light", "env": { "MINHA_VAR": "valor-do-usuario" } }
JSON
echo '{"mcpServers":{}}' > "$CLAUDE_JSON"

bash "$REPO/scripts/install.sh" >/dev/null 2>&1

# customizacao preservada
assert_eq "$(jq -r '.env.MINHA_VAR' "$CLAUDE_DIR/settings.json")" "valor-do-usuario"
assert_eq "$(jq -r '.theme' "$CLAUDE_DIR/settings.json")" "light"
# template aplicado
assert_eq "$(jq -r '.hooks.PreToolUse[0].hooks[0].command' "$CLAUDE_DIR/settings.json")" "rtk hook claude"
# backup criado
assert_exit_code 0 sh -c "ls '$CLAUDE_DIR'/settings.json.bak.* >/dev/null 2>&1"
# artefatos copiados
assert_file_exists "$CLAUDE_DIR/commands/review.md"
assert_file_exists "$CLAUDE_DIR/hooks/prettier-hook.py"
assert_file_exists "$CLAUDE_DIR/CLAUDE.md"
assert_file_exists "$CLAUDE_DIR/RTK.md"
# nenhuma credencial escrita
assert_eq "$(jq -r '.mcpServers.github.env.GITHUB_PERSONAL_ACCESS_TOKEN' "$CLAUDE_JSON")" '${GITHUB_PERSONAL_ACCESS_TOKEN}'

# idempotencia: segunda execucao produz o mesmo estado
h1="$(jq -S . "$CLAUDE_DIR/settings.json" | shasum)"
bash "$REPO/scripts/install.sh" >/dev/null 2>&1
h2="$(jq -S . "$CLAUDE_DIR/settings.json" | shasum)"
assert_eq "$h2" "$h1"

rm -rf "$TMP"
exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_install.sh` falha — script ausente.

- [ ] **Step 3: Implementar**

`scripts/install.sh`:

```bash
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
if [ ! -f "$CLAUDE_JSON" ]; then
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
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_install.sh` PASS, inclusive a asserção de idempotência.

- [ ] **Step 5: Verificar o merge que preserva o usuário**

O teste já cobre, mas confirme lendo a saída de:
`CLAUDE_DIR=$(mktemp -d) CLAUDE_JSON=$(mktemp) ./scripts/install.sh`
Expected: o formato de relatório do spec §5.3, terminando em `ACAO MANUAL`.

- [ ] **Step 6: Commit**

```bash
git add scripts/install.sh tests/test_install.sh
git commit -m "feat: instalador idempotente com merge

Copiar settings.json por cima destruiria a configuracao de quem ja usa a
ferramenta. O merge coloca o template primeiro e o arquivo do usuario
depois, entao valor existente vence — instalar nunca e uma regressao.

Backup datado antes de qualquer escrita, porque merge de JSON e a classe
de operacao onde 'reverter' precisa ser trivial."
```

---

### Task 8: `install.ps1`

**Files:**
- Create: `scripts/install.ps1`
- Modify: `tests/test_install.sh` (adiciona verificação de paridade)

**Interfaces:**
- Consumes: os mesmos templates da Task 3
- Produces: `scripts/install.ps1` com o mesmo contrato de saída de `install.sh`. Usa `ConvertFrom-Json`/`ConvertTo-Json` nativos; não exige `jq` no Windows.

- [ ] **Step 1: Escrever a verificação de paridade**

Acrescente ao final de `tests/test_install.sh`, antes de `exit $FAILURES`:

```bash
# Paridade Unix/Windows: o script PowerShell precisa cobrir os mesmos
# passos. Sem PowerShell no CI, verificamos os marcadores.
ps1="$(cat "$REPO/scripts/install.ps1" 2>/dev/null)"
assert_contains "$ps1" "settings.json.bak"
assert_contains "$ps1" "ACAO MANUAL"
assert_contains "$ps1" "GITHUB_PERSONAL_ACCESS_TOKEN"
assert_contains "$ps1" "BRAVE_API_KEY"
assert_contains "$ps1" "prettier-hook.py"
assert_contains "$ps1" "RTK.md"
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: as seis novas asserções falham — `install.ps1` não existe.

- [ ] **Step 3: Implementar**

`scripts/install.ps1`:

```powershell
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
```

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_install.sh` PASS, incluindo as seis asserções de paridade.

- [ ] **Step 5: Commit**

```bash
git add scripts/install.ps1 tests/test_install.sh
git commit -m "feat: instalador para Windows

Mesmo contrato de saida do install.sh, sem exigir jq — PowerShell ja
traz ConvertFrom-Json. Exigir uma dependencia extra so no Windows
transformaria o time em dois grupos com instrucoes diferentes.

O teste verifica paridade por marcador, ja que o CI nao roda PowerShell."
```

---

### Task 9: `docs/reference/` — o catálogo

**Files:**
- Create: `docs/reference/{mcp-servers,plugins,skills,agents,commands,settings,modelos}.md`
- Create: `tests/test_docs_unicidade.sh`

**Interfaces:**
- Consumes: nada de código
- Produces: fonte única por assunto. Os arquivos de `docs/setup/` (Task 11) linkam para cá em vez de repetir conteúdo.

- [ ] **Step 1: Escrever o teste de unicidade que falha**

`tests/test_docs_unicidade.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

for f in mcp-servers plugins skills agents commands settings modelos; do
  assert_file_exists "$REPO/docs/reference/$f.md"
done

# A lista de plugins tinha tres copias divergentes. Agora e uma so:
# o nome do marketplace so pode aparecer em docs/reference/plugins.md.
hits="$(grep -rl 'claude-plugins-official' "$REPO/docs" 2>/dev/null | grep -v 'reference/plugins.md' | wc -l | tr -d ' ')"
assert_eq "$hits" "0"

# Nenhum arquivo de referencia pode passar de 300 linhas.
for f in "$REPO/docs/reference"/*.md; do
  n="$(wc -l < "$f" | tr -d ' ')"
  if [ "$n" -gt 300 ]; then _fail "$(basename "$f"): $n linhas (max 300)"; else _pass "$(basename "$f"): $n linhas"; fi
done

exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_docs_unicidade.sh` falha nos sete arquivos ausentes.

- [ ] **Step 3: Escrever `docs/reference/plugins.md`**

Fonte: `README.md:439-754`, `GUIA_CONFIGURACAO_TIME.md:238-289`, `EXEMPLO_CONFIGURACAO.md:142-289`. Consolide as três cópias divergentes numa só, resolvendo divergência a favor do que o `config/settings.template.json` realmente habilita.

Estrutura obrigatória: tabela com colunas `Plugin | Identificador | Para que serve | Quando usar`, uma linha por plugin, cobrindo os 12 de `enabledPlugins`: `superpowers`, `explanatory-output-style`, `context7`, `code-review`, `frontend-design`, `github`, `feature-dev`, `code-simplifier`, `serena`, `claude-md-management`, `claude-code-setup`, `caveman`. Depois da tabela, uma seção `## Instalação` e uma `## Plugin ou MCP server?` que linka para `docs/concepts/mcp-vs-plugin.md`.

- [ ] **Step 4: Escrever `docs/reference/mcp-servers.md`**

Fonte: `README.md:137-343`. Tabela com os 11 servers, uma linha cada: `filesystem`, `git`, `github`, `memory`, `sqlite`, `sequential-thinking`, `brave-search`, `fetch`, `serena`, `docker`, `supabase`. Colunas: `Server | Comando | Precisa de credencial? | Para que serve`.

Registre as duas pendências conhecidas numa seção `## Pendências conhecidas`:
- `supabase` traz `--access-token` sem valor; precisa ser completado ou o server não sobe.
- `filesystem`, `git`, `sqlite` e `serena` recebem um diretório de trabalho; no template ele é `$WORKSPACE_DIR` e cada pessoa aponta para o próprio.

- [ ] **Step 5: Escrever `docs/reference/settings.md`**

Fonte: `EXEMPLO_CONFIGURACAO.md`. Documente cada chave de `config/settings.template.json`: `hooks`, `enabledPlugins`, `extraKnownMarketplaces`, `permissions`, `model`, `effortLevel`, `theme`.

Seção obrigatória `## O que o template não traz, e por quê`:
- `env` — removido inteiro; explique que variável de ambiente com segredo não pertence a arquivo versionado e indique onde colocar.
- `statusLine` — removido porque o comando aponta para um caminho de plugin com hash de instalação, válido só na máquina de origem; explique como reativar pelo próprio plugin.
- `settings.local.json` — explique que existe, que o Claude Code o lê, e que ele nunca deve ser versionado.

- [ ] **Step 6: Escrever `docs/reference/modelos.md`**

**Antes de escrever, consulte a skill `claude-api`.** Identificadores de modelo não podem ser escritos de memória.

Conteúdo: tabela dos modelos atuais com quando escolher cada um. **Sem tabela de preço** — link para a página oficial de pricing (decisão D6 do spec). Explique a relação entre `model` no settings e a variável `ANTHROPIC_MODEL`, que prevalece sobre ele.

- [ ] **Step 7: Escrever `docs/reference/{skills,agents,commands}.md`**

Fonte: `README.md:755-879` e `GUIA:329-514`.

- `skills.md` — o que é uma skill, formato do frontmatter (`name`, `description`, `allowed-tools`, `disable-model-invocation`), e a skill que o repositório distribui: `spec-driven`.
- `agents.md` — o que é um subagente, por que tem contexto próprio, o que precisa constar no brief, e os dois que o repositório distribui: `pr-reviewer` e `domain-analyst` (template).
- `commands.md` — o que é um command, e os dois distribuídos: `/preflight` e `/review`.

- [ ] **Step 8: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_docs_unicidade.sh` PASS, inclusive `hits` igual a `0`.

- [ ] **Step 9: Commit**

```bash
git add docs/reference/ tests/test_docs_unicidade.sh
git commit -m "docs: catalogo de referencia com fonte unica por assunto

A lista de plugins existia em tres arquivos e as tres copias ja tinham
divergido. Consolidar resolve a divergencia atual; o teste de unicidade
impede a proxima.

A tabela de precos sai em vez de ser atualizada. Numero fixo em
documentacao e divida que vence sozinha — a pagina oficial nao."
```

---

### Task 10: `docs/concepts/` — o porquê

**Files:**
- Create: `docs/concepts/{o-que-e-claude-code,mcp-vs-plugin,economia-de-tokens,memoria}.md`
- Modify: `tests/test_docs_unicidade.sh`

**Interfaces:**
- Consumes: linka para `docs/reference/` (Task 9)
- Produces: as quatro explicações. `docs/setup/` (Task 11) linka para cá quando o leitor precisar do contexto.

- [ ] **Step 1: Estender o teste**

Acrescente antes de `exit $FAILURES` em `tests/test_docs_unicidade.sh`:

```bash
for f in o-que-e-claude-code mcp-vs-plugin economia-de-tokens memoria; do
  assert_file_exists "$REPO/docs/concepts/$f.md"
done
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: quatro novas falhas.

- [ ] **Step 3: Escrever os quatro documentos**

- `o-que-e-claude-code.md` — fonte `README.md:20-136`, menos a parte de modelos, que foi para `reference/modelos.md`.
- `mcp-vs-plugin.md` — fonte `README.md:323-343` e `README.md:739-754`. Responde a pergunta que o time faz na prática: quando escrever um MCP server e quando escrever um plugin, skill ou agent.
- `economia-de-tokens.md` — fonte `README.md:958-1139`. Inclua o RTK aqui, com link para `config/RTK.md`.
- `memoria.md` — fonte `README.md:344-438` e `memory/COMO_USAR.md`. Este último vira um resumo que aponta para cá, sem repetir.

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_docs_unicidade.sh` PASS.

- [ ] **Step 5: Commit**

```bash
git add docs/concepts/ memory/ tests/test_docs_unicidade.sh
git commit -m "docs: separa o porque do como

A trilha de instalacao fica curta quando a explicacao mora em outro
lugar. Quem so quer instalar segue reto; quem quer entender clica."
```

---

### Task 11: `docs/setup/` — a trilha

**Files:**
- Create: `docs/setup/00-visao-geral.md` até `08-verificacao.md`
- Create: `tests/test_docs_trilha.sh`

**Interfaces:**
- Consumes: `docs/reference/` (Task 9), `docs/concepts/` (Task 10), `scripts/install.sh` (Task 7)
- Produces: sequência navegável. Cada arquivo termina com link para o próximo; `08` termina com link para `troubleshooting.md`.

- [ ] **Step 1: Escrever o teste que falha**

`tests/test_docs_trilha.sh`:

```bash
#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

files="00-visao-geral 01-pre-requisitos 02-instalacao 03-mcp-servers 04-plugins 05-claude-md 06-skills-agents-commands 07-memoria 08-verificacao"
for f in $files; do
  assert_file_exists "$REPO/docs/setup/$f.md"
done

# Cada arquivo, menos o ultimo, precisa apontar para o proximo.
prev=""
for f in $files; do
  if [ -n "$prev" ]; then
    assert_contains "$(cat "$REPO/docs/setup/$prev.md" 2>/dev/null)" "$f.md"
  fi
  prev="$f"
done
assert_contains "$(cat "$REPO/docs/setup/08-verificacao.md" 2>/dev/null)" "troubleshooting.md"

# A trilha nao pode repetir o catalogo de plugins.
assert_not_contains "$(cat "$REPO/docs/setup/04-plugins.md" 2>/dev/null)" "claude-plugins-official"

exit $FAILURES
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: `test_docs_trilha.sh` falha nos nove arquivos ausentes.

- [ ] **Step 3: Escrever a trilha**

Cada arquivo abre com uma linha `> Tempo estimado: N min` e fecha com `**Próximo:** [título](NN-arquivo.md)`.

- `00-visao-geral.md` — o que o time ganha, o que será instalado, tempo total. Link para `docs/concepts/o-que-e-claude-code.md`.
- `01-pre-requisitos.md` — VSCode, extensão Claude Code, `jq`, Node, `git`. Comandos de instalação para macOS, Linux e Windows. Fonte: `GUIA:42-77`.
- `02-instalacao.md` — `git clone`, `./scripts/install.sh` ou `.\scripts\install.ps1`, leitura do relatório de saída. Fonte: `GUIA:290-328`, mais a seção de RTK, que é dependência do hook `PreToolUse`.
- `03-mcp-servers.md` — **única etapa manual.** Como obter o PAT do GitHub e a chave da Brave, onde colocar cada um, como apontar `$WORKSPACE_DIR`. Fonte: `GUIA:159-184`. Link para `docs/reference/mcp-servers.md`.
- `04-plugins.md` — confirmar que os 12 plugins do template carregaram. **Sem repetir a tabela**; link para `docs/reference/plugins.md`.
- `05-claude-md.md` — o que o `CLAUDE.md` instalado faz, como adaptar ao contexto próprio. Fonte: `GUIA:290-328`.
- `06-skills-agents-commands.md` — o que foi instalado e como usar. Link para os três arquivos de referência.
- `07-memoria.md` — criar `~/.claude/projects/<projeto>/memory/`, copiar os exemplos de `memory/exemplos/`. Fonte: `GUIA:515-602`.
- `08-verificacao.md` — rodar `/preflight`, ler a tabela de status, o que fazer com cada falha. Fonte: `GUIA:663-708`. Fecha com link para `troubleshooting.md`.

- [ ] **Step 4: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_docs_trilha.sh` PASS.

- [ ] **Step 5: Percorrer a trilha como leitor**

Leia `00` até `08` na ordem, seguindo cada instrução. Todo comando citado precisa existir; todo link precisa resolver. Anote e corrija qualquer ponto onde o leitor precisaria de informação que não está ali nem a um link de distância.

- [ ] **Step 6: Commit**

```bash
git add docs/setup/ tests/test_docs_trilha.sh
git commit -m "docs: trilha ordenada de onboarding

O repositorio tinha material completo e nenhuma ordem de leitura. Nove
arquivos numerados, cada um com uma etapa e um link para o seguinte,
transformam o mesmo conteudo em caminho.

A etapa 03 e a unica manual, e esta isolada de proposito: e onde entram
credenciais, o unico ponto que o instalador nao pode automatizar."
```

---

### Task 12: Troubleshooting e CONTRIBUTING

**Files:**
- Create: `docs/troubleshooting.md`, `CONTRIBUTING.md`
- Modify: `tests/test_docs_unicidade.sh`

**Interfaces:**
- Consumes: `scripts/sync.sh` (Task 5), `Makefile` (Task 1)
- Produces: nada consumido por outra task.

- [ ] **Step 1: Estender o teste**

Acrescente antes de `exit $FAILURES` em `tests/test_docs_unicidade.sh`:

```bash
assert_file_exists "$REPO/docs/troubleshooting.md"
assert_file_exists "$REPO/CONTRIBUTING.md"
# CONTRIBUTING precisa ensinar o fluxo de sync, senao o repo volta a divergir
assert_contains "$(cat "$REPO/CONTRIBUTING.md" 2>/dev/null)" "make sync"
assert_contains "$(cat "$REPO/CONTRIBUTING.md" 2>/dev/null)" "make check"
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: quatro novas falhas.

- [ ] **Step 3: Escrever `docs/troubleshooting.md`**

Fonte: `GUIA:709-790`. Formato: um `##` por sintoma, cada um com `**Sintoma** / **Causa** / **Correção**. Casos obrigatórios, os de `GUIA` mais os que este trabalho introduz:

- MCP server não aparece
- Plugin não carrega
- `CLAUDE.md` não é aplicado
- Erro de permissão no macOS
- Token do GitHub inválido
- `install.sh` falha com `jq: command not found`
- `install.sh` reporta conflito de campo em `settings.json`
- `sync.sh` aborta com padrão proibido encontrado
- CI falha no job `secrets` — o que fazer quando o segredo já foi commitado

- [ ] **Step 4: Escrever `CONTRIBUTING.md`**

Conteúdo: como propor mudança, o fluxo `alterar ~/.claude/ → make sync → make check → commit`, por que não se edita `config/*.template.json` à mão, como adicionar item à denylist, formato de commit (Conventional Commits, corpo explicando o porquê).

- [ ] **Step 5: Rodar e confirmar que passa**

Run: `./tests/run.sh`
Expected: `test_docs_unicidade.sh` PASS.

- [ ] **Step 6: Commit**

```bash
git add docs/troubleshooting.md CONTRIBUTING.md tests/test_docs_unicidade.sh
git commit -m "docs: troubleshooting e guia de contribuicao

Documenta o fluxo de sync porque a divergencia entre repositorio e
maquina local foi o defeito original — e ela volta se o processo ficar
so na cabeca de quem escreveu."
```

---

### Task 13: `README.md` como índice

**Files:**
- Modify: `README.md` (reescrito por completo)
- Delete: `GUIA_CONFIGURACAO_TIME.md`, `EXEMPLO_CONFIGURACAO.md`
- Modify: `tests/test_docs_unicidade.sh`

**Interfaces:**
- Consumes: toda a estrutura de `docs/` (Tasks 9–12)
- Produces: ponto de entrada do repositório.

- [ ] **Step 1: Estender o teste**

Acrescente antes de `exit $FAILURES` em `tests/test_docs_unicidade.sh`:

```bash
n="$(wc -l < "$REPO/README.md" | tr -d ' ')"
if [ "$n" -le 200 ]; then _pass "README: $n linhas"; else _fail "README: $n linhas (max 200)"; fi

# Os monoliticos foram fatiados e nao podem sobreviver
for f in GUIA_CONFIGURACAO_TIME.md EXEMPLO_CONFIGURACAO.md; do
  if [ -f "$REPO/$f" ]; then _fail "$f ainda existe — conteudo migrou para docs/"; else _pass "$f removido"; fi
done

# O README precisa apontar para a trilha e para o catalogo
readme="$(cat "$REPO/README.md")"
assert_contains "$readme" "docs/setup/00-visao-geral.md"
assert_contains "$readme" "docs/reference/"
assert_contains "$readme" "LICENSE"
```

- [ ] **Step 2: Rodar e confirmar que falha**

Run: `./tests/run.sh`
Expected: falha em `README: 1350 linhas` e nos dois arquivos que ainda existem.

- [ ] **Step 3: Reescrever o README**

Máximo 200 linhas, nesta ordem:

1. Título e uma frase sobre o que o repositório é.
2. `## Início rápido` — três comandos: `git clone`, `./scripts/install.sh`, `/preflight`.
3. `## O que vem junto` — tabela curta: 12 plugins, 11 MCP servers, 1 skill, 2 agents, 2 commands, `CLAUDE.md`, RTK. Uma linha cada, com link para a referência.
4. `## Documentação` — três colunas de links: trilha (`docs/setup/`), catálogo (`docs/reference/`), conceitos (`docs/concepts/`).
5. `## Manutenção` — `make sync`, `make check`, link para `CONTRIBUTING.md`.
6. `## Licença` — MIT, link para `LICENSE`.

Nada de conteúdo explicativo: tudo que explica vive em `docs/`.

- [ ] **Step 4: Remover os monolíticos**

```bash
git rm GUIA_CONFIGURACAO_TIME.md EXEMPLO_CONFIGURACAO.md
```

Antes de remover, confirme com `grep` que cada seção citada no mapa da §6 do spec tem destino escrito. Conteúdo sem destino é perda, não simplificação.

- [ ] **Step 5: Rodar a verificação completa**

Run: `make check`
Expected: testes passam; gitleaks, shellcheck e lychee passam ou avisam ausência; `check-drift.sh` reporta o estado atual.

- [ ] **Step 6: Confirmar que nenhum link quebrou**

Run: `grep -rohE '\]\([A-Za-z0-9_./-]+\.md\)' README.md docs/ CONTRIBUTING.md | tr -d '])(' | sort -u | while read -r f; do [ -e "$f" ] || [ -e "docs/$f" ] || echo "QUEBRADO: $f"; done`
Expected: nenhuma saída.

- [ ] **Step 6b: Unificar o versionamento**

O repositorio carregava quatro versoes independentes em rodapes de arquivo
(`README.md` 2.1.0, `GUIA` 1.1.0, `CLAUDE.md` 1.0.0, `EXEMPLO` 1.0.0), ja
divergentes entre si. Uma versao so, marcada por tag git (spec §6).

Remova o rodape `**Versão:**` / `**Última atualização:**` de todo arquivo
que ainda o tenha:

```bash
grep -rln 'Última atualização' --include='*.md' . || echo "nenhum rodape restante"
```

Edite cada arquivo encontrado removendo as duas linhas e o separador `---`
que as precede. Depois marque a versao:

```bash
git tag -a v3.0.0 -m "reestruturacao: repositorio instalavel, docs modulares"
```

Acrescente ao final de `tests/test_docs_unicidade.sh`, antes de `exit $FAILURES`:

```bash
# Versionamento e responsabilidade da tag git, nao de rodape por arquivo.
if grep -rq 'Última atualização' --include='*.md' "$REPO"; then
  _fail "rodape de versao por arquivo ainda existe"
else
  _pass "versionamento unificado em tag git"
fi
```

- [ ] **Step 7: Commit**

```bash
git add -A README.md GUIA_CONFIGURACAO_TIME.md EXEMPLO_CONFIGURACAO.md tests/test_docs_unicidade.sh
git commit -m "docs: README vira indice, monoliticos removidos

Mil e trezentas linhas na porta de entrada faziam o leitor decidir o que
ignorar antes de saber o que existe. O indice inverte isso: ele escolhe
o caminho, e o caminho tem o tamanho de uma sessao.

O teste de tamanho maximo existe para que a proxima adicao va para
docs/ em vez de voltar para ca."
```

---

### Task 14: Plano de melhorias pessoal

**Files:**
- Create: `~/.claude/MELHORIAS.md` (fora do repositório, decisão D4)

**Interfaces:**
- Consumes: nada
- Produces: nada. Task terminal.

- [ ] **Step 1: Confirmar que o arquivo fica fora do controle de versão**

Run: `git -C <repo> check-ignore -v ~/.claude/MELHORIAS.md; echo "caminho fora do repositorio"`
Expected: o caminho está em `~/.claude/`, fora da árvore do repositório. Nenhum comando de git deste plano o alcança.

- [ ] **Step 2: Escrever o documento**

`~/.claude/MELHORIAS.md`, com quatro seções de prioridade. Conteúdo obrigatório, com o item e a ação concreta:

**Crítico — credenciais expostas**
- Rotacionar a senha da conta Metabase. Está em texto puro numa regra de permissão de `~/.claude/settings.local.json`, dentro de um comando `curl`.
- Rotacionar o `GITHUB_PERSONAL_ACCESS_TOKEN` de `~/.claude.json`.
- Rotacionar a senha do MySQL de `env.MYSQL_PASSWORD` em `~/.claude/settings.json` e movê-la para fora do arquivo.
- Invalidar os quatro session tokens do Metabase presentes em `settings.local.json`.
- Limpar `settings.local.json`: 24 entradas, várias com credencial embutida e caminho absoluto. Regras de permissão devem ser padrões, não comandos literais com segredo.

**Alto — configuração contraditória**
- `env.ANTHROPIC_MODEL` está em `claude-sonnet-4-6` enquanto `model` está em `opus[1m]`. A variável de ambiente prevalece. Decidir qual vale e remover o outro. Consultar a skill `claude-api` para o identificador correto.

**Médio — higiene**
- Remover os documentos duplicados de `~/.claude/`: `MINHAS_CONFIGURACOES.md`, `README_CONFIGURACAO.md`, `GUIA_CONFIGURACAO_TIME.md`. O repositório passa a ser fonte única.
- `mcpServers.supabase` tem `--access-token` sem valor — o server não sobe. Completar ou remover.
- MCP servers sem uso observado no histórico: `sqlite`, `docker`, `fetch`, `supabase`. Cada server carregado consome contexto de definição de ferramenta em toda sessão. Avaliar remoção.

**Baixo — evolução**
- Hooks a avaliar: `SessionStart` para `check-drift`, `PreToolUse` para bloquear `git push --force` em branch protegida.
- Skills próprias a criar, a partir de tarefas repetidas no histórico.

- [ ] **Step 3: Verificação final do trabalho inteiro**

Run, a partir da raiz do repositório:

```bash
make check
grep -rInE -f scripts/lib/patterns.txt --exclude-dir=.git --exclude=patterns.txt . && echo "FALHOU: padrao proibido" || echo "ok: nenhum padrao proibido"
CLAUDE_DIR=$(mktemp -d) CLAUDE_JSON=$(mktemp) ./scripts/install.sh
```

Expected: testes passam; nenhum padrão proibido; instalação limpa termina em `ACAO MANUAL` e `Proximo passo`.

- [ ] **Step 4: Sem commit**

Este arquivo é deliberadamente não versionado. Não rode `git add`.

---

## Verificação de conclusão

O trabalho está pronto quando todos os itens abaixo forem verdadeiros — cada um mapeia para a §8 do spec:

- [ ] `make check` passa
- [ ] `./scripts/install.sh` rodado duas vezes em diretório limpo produz o mesmo estado, e a segunda execução não altera arquivo (coberto por `tests/test_install.sh`)
- [ ] `./scripts/install.sh` sobre `settings.json` customizado preserva as customizações (coberto por `tests/test_install.sh`)
- [ ] `grep -rInE -f scripts/lib/patterns.txt` no repositório não retorna nada
- [ ] A trilha `docs/setup/00` → `08` leva do zero ao `/preflight` verde sem fonte externa
- [ ] Cada plugin, MCP server, skill, agent e command aparece em exatamente um arquivo de documentação (coberto por `tests/test_docs_unicidade.sh`)
- [ ] `~/.claude/MELHORIAS.md` existe e está fora do controle de versão
- [ ] Nenhum arquivo carrega rodapé de versão própria; a versão vive na tag git
