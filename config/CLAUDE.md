# Instruções Globais

## Comunicação
- Português brasileiro, objetivo, sem emojis.
- Explique o porquê de decisões técnicas e trade-offs relevantes em poucas linhas; não repita o que o código já mostra.
- Antes de ação destrutiva ou em produção (`prd`, `prod`), confirme.

## Roteamento de modelo e subagentes
Objetivo: thread principal (Opus) para raciocínio, arquitetura e debug; trabalho mecânico em modelos mais baratos.

- **Pesquisa** (web, docs, "pesquise", "investigue", "descubra como"): dispare subagente com `model: "sonnet"` (`general-purpose` ou `Explore`). Volte só com a conclusão e as fontes.
- **Busca pontual no código** (onde está X, quem chama Y): subagente com `model: "haiku"`. Se já sei o arquivo, leio direto.
- **Revisão de PR**: command `/review` (roda em Sonnet). 2+ PRs → um `pr-reviewer` por PR em paralelo, numa única mensagem.
- **PR em repositório com regra de negócio sensível**: depois do `pr-reviewer`, dispare `domain-analyst` com o diff filtrado; consolide antes de postar.
- No brief do subagente, inclua sempre: `owner/repo`, número da PR/ticket e decisões intencionais que pareçam erro. Subagente não vê esta conversa.

## Gestão de contexto
- Uma tarefa por sessão. Ao concluir, sugira `/clear`.
- Frente longa (vários dias): manter documento de estado no repositório e apontar na memória; retomar lendo esse documento, não reexplorando.
- Leitura ampla (muitos arquivos, logs grandes, dumps) vai para subagente; trazer só o resumo.
- Prefira CLIs (`gh`, `gcloud`, `kubectl`, `psql`) via Bash a MCPs equivalentes.

## Código
- Legibilidade acima de concisão; siga o estilo do código ao redor.
- Leia o `CLAUDE.md` do repositório antes de editar; ele tem precedência sobre este.
- **TypeScript/React**: `strict`, tipos explícitos em props e retornos, hooks com dependências completas, Zod para entrada, TanStack Query para estado de servidor, Zustand para estado global.
- **.NET 8**: Clean Architecture (`API → Application → Domain → Infra.Data → Infra.IoC`), nullable habilitado, async com `CancellationToken`, EF Core com Fluent API e `AsNoTracking()` em leitura, Result pattern para fluxo de erro, xUnit + FluentAssertions.
- **Python**: type hints em funções públicas, pathlib, Pydantic/dataclasses, pytest.
- Não otimize sem evidência.

## Segurança (inegociável)
- Nunca commitar secrets, `.env` ou credenciais; use variáveis de ambiente ou um secret manager.
- Queries parametrizadas; validar entrada; dados pessoais e de saúde são sensíveis (LGPD) — não copiar para artefatos, issues, chats ou memória.
- Migrations já aplicadas em produção não são editadas.
- Não usar `--no-verify` em git hooks.

## Git
- Commits: `tipo: descrição` (feat, fix, refactor, docs, test, chore); corpo explica o porquê.
- Branches: `feature/`, `fix/`, `refactor/` a partir de `develop`.
- Commit, push e PR só quando eu pedir.

@RTK.md
