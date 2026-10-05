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
assert_eq "$(jq -r '.enabledPlugins | length' "$S")" "16"
assert_eq "$(jq -r 'has("statusLine")' "$S")" "false"
assert_eq "$(jq -r 'has("autoMode")' "$S")" "false"

# MCP enxuto: so o github sobrevive (os demais nao tinham uso ou duplicavam
# tools nativas; MCP interno sai pela denylist), credencial como placeholder
assert_eq "$(jq -r 'length' "$M")" "1"
assert_eq "$(jq -r '.github.env.GITHUB_PERSONAL_ACCESS_TOKEN' "$M")" '${GITHUB_PERSONAL_ACCESS_TOKEN}'

assert_exit_code 0 scan_secrets "$REPO/config"

exit $FAILURES
