.PHONY: help install sync check test

help:
	@echo "install  instala a configuracao em ~/.claude"
	@echo "sync     copia ~/.claude para o repositorio, sanitizando"
	@echo "check    roda testes, varredura de segredo, links e shellcheck"
	@echo "test     roda apenas os testes"

install:
	@./scripts/install.sh

sync:
	@./scripts/sync.sh

test:
	@./tests/run.sh

check: test
	@if command -v gitleaks >/dev/null 2>&1; then \
		gitleaks detect --source . --config .gitleaks.toml --no-banner; \
	else echo "aviso: gitleaks ausente, varredura pulada (o CI executa)"; fi
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/*.sh scripts/lib/*.sh tests/*.sh tests/lib/*.sh; \
	else echo "aviso: shellcheck ausente, analise pulada (o CI executa)"; fi
	@if command -v lychee >/dev/null 2>&1; then \
		lychee --offline README.md 'docs/**/*.md'; \
	else echo "aviso: lychee ausente, checagem de link pulada (o CI executa)"; fi
	@./scripts/check-drift.sh || true
