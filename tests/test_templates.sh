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
