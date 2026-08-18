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

n="$(wc -l < "$REPO/README.md" | tr -d ' ')"
if [ "$n" -le 200 ]; then _pass "README: $n linhas"; else _fail "README: $n linhas (max 200)"; fi

# Os monoliticos foram fatiados e nao podem sobreviver
for f in GUIA_CONFIGURACAO_TIME.md EXEMPLO_CONFIGURACAO.md; do
  if [ -f "$REPO/$f" ]; then _fail "$f ainda existe — conteudo migrou para docs/"; else _pass "$f removido"; fi
done

# O README precisa apontar para a trilha e para o catalogo
readme="$(cat "$REPO/README.md")"
assert_contains "$readme" "docs/setup/00-visao-geral.md"
assert_contains "$readme" "docs/reference/"
assert_contains "$readme" "LICENSE"

# Versionamento e responsabilidade da tag git, nao de rodape por arquivo.
# (docs/superpowers/ e .superpowers/ guardam o historico de planejamento,
# que cita o proprio rodape como instrucao de tarefa — nao e um rodape
# real sobrevivendo)
hits_rodape="$(grep -rl 'Última atualização' --include='*.md' "$REPO" 2>/dev/null | grep -v 'superpowers/' | wc -l | tr -d ' ')"
if [ "$hits_rodape" -gt 0 ]; then
  _fail "rodape de versao por arquivo ainda existe"
else
  _pass "versionamento unificado em tag git"
fi

exit $FAILURES
