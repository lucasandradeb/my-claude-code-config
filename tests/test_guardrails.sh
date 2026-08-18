#!/usr/bin/env bash
. "$REPO/tests/lib/assert.sh"

assert_file_exists "$REPO/LICENSE"
assert_file_exists "$REPO/.gitignore"
assert_file_exists "$REPO/Makefile"
assert_file_exists "$REPO/.github/workflows/ci.yml"
assert_file_exists "$REPO/scripts/lib/patterns.txt"
assert_file_exists "$REPO/.gitleaks.toml"

# As fixtures carregam valores falsos que casam com os padroes de proposito.
# Sem essa excecao, a rede de seguranca dispara nos proprios testes dela.
assert_contains "$(cat "$REPO/.gitleaks.toml" 2>/dev/null)" "tests/fixtures"

assert_contains "$(cat "$REPO/LICENSE" 2>/dev/null)" "MIT License"

# settings.local.json nunca pode ser versionado — contem credenciais.
assert_contains "$(cat "$REPO/.gitignore" 2>/dev/null)" "settings.local.json"

# A lista de padroes proibidos precisa cobrir os quatro vetores conhecidos.
patterns="$(cat "$REPO/scripts/lib/patterns.txt" 2>/dev/null)"
assert_contains "$patterns" "ghp_"
assert_contains "$patterns" "X-Metabase-Session"
assert_contains "$patterns" "MYSQL_PASSWORD"
assert_contains "$patterns" "PRIVATE KEY"

exit $FAILURES
