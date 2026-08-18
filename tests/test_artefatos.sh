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
