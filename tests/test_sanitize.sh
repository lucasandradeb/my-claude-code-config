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

# Regressao: PATTERNS_FILE ausente nao pode reportar "limpo" (fail-closed)
( PATTERNS_FILE="$REPO/tests/fixtures/nao-existe-patterns.txt" scan_secrets "$F/settings.dirty.json" )
assert_eq "$?" "2"

exit $FAILURES
