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
