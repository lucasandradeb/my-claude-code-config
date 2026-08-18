#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/scripts/sync.sh"

# Ambiente controlado. sync.sh le CLAUDE_DIR/CLAUDE_JSON; sem semear um
# diretorio de teste, o resultado dependeria do ~/.claude real da maquina
# (o runner de CI e limpo e nao teria nenhum artefato denylisted a reportar).
TMP="$(mktemp -d)"
export CLAUDE_DIR="$TMP/.claude"
export CLAUDE_JSON="$TMP/.claude.json"
mkdir -p "$CLAUDE_DIR/agents"

# Um artefato denylisted (reportado como denylist, nunca copiado) e um
# artefato generico limpo (copiado).
echo "# agente interno" > "$CLAUDE_DIR/agents/jira-task.md"
echo "# agente generico de exemplo" > "$CLAUDE_DIR/agents/exemplo.md"

# settings.json e .claude.json minimos e limpos: sem eles o jq de sync.sh
# aborta sob set -e. Valores sanitizaveis, sem padrao proibido.
cat > "$CLAUDE_DIR/settings.json" <<'JSON'
{ "model": "opus", "enabledPlugins": {} }
JSON
cat > "$CLAUDE_JSON" <<'JSON'
{ "mcpServers": { "github": { "command": "npx", "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "placeholder" } } } }
JSON

# --dry-run nao pode alterar o repositorio
before="$(git -C "$REPO" status --porcelain)"
out="$(bash "$REPO/scripts/sync.sh" --dry-run 2>&1)"
after="$(git -C "$REPO" status --porcelain)"
assert_eq "$after" "$before"

# o relatorio precisa nomear a denylist aplicada
assert_contains "$out" "denylist"
assert_contains "$out" "jira-task"

# artefato interno nunca aparece como copiado; o generico sim
assert_not_contains "$out" "copiar   agents/jira-task.md"
assert_contains "$out" "copiar   agents/exemplo.md"

rm -rf "$TMP"
exit $FAILURES
