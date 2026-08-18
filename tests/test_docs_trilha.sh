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
