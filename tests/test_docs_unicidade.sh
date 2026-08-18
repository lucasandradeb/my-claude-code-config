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
