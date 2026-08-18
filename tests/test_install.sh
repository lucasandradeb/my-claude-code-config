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
