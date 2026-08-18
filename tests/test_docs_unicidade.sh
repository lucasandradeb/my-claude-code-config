#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

for f in mcp-servers plugins skills agents commands settings modelos; do
  assert_file_exists "$REPO/docs/reference/$f.md"
done

# A lista de plugins tinha tres copias divergentes. Agora e uma so:
# o nome do marketplace so pode aparecer em docs/reference/plugins.md.
hits="$(grep -rl 'claude-plugins-official' "$REPO/docs" 2>/dev/null | grep -v '/superpowers/' | grep -v 'reference/plugins.md' | wc -l | tr -d ' ')"
assert_eq "$hits" "0"

# Nenhum arquivo de referencia pode passar de 300 linhas.
for f in "$REPO/docs/reference"/*.md; do
  n="$(wc -l < "$f" | tr -d ' ')"
  if [ "$n" -gt 300 ]; then _fail "$(basename "$f"): $n linhas (max 300)"; else _pass "$(basename "$f"): $n linhas"; fi
done

for f in o-que-e-claude-code mcp-vs-plugin economia-de-tokens memoria; do
  assert_file_exists "$REPO/docs/concepts/$f.md"
done

assert_file_exists "$REPO/docs/troubleshooting.md"
assert_file_exists "$REPO/CONTRIBUTING.md"
# CONTRIBUTING precisa ensinar o fluxo de sync, senao o repo volta a divergir
assert_contains "$(cat "$REPO/CONTRIBUTING.md" 2>/dev/null)" "make sync"
assert_contains "$(cat "$REPO/CONTRIBUTING.md" 2>/dev/null)" "make check"

exit $FAILURES
