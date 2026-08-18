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
