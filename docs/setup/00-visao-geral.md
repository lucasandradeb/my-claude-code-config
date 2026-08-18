# 00 — Visão geral

> Tempo estimado: 3 min

Esta trilha leva você de uma máquina limpa até um `/preflight` verde: Claude Code
instalado, MCP servers conectados, plugins carregados, `CLAUDE.md` no lugar,
skills/agents/commands copiados e memória configurada.

## O que você ganha ao final

- **Claude Code** rodando no VSCode, autenticado com sua conta Anthropic.
- **11 MCP servers** — acesso a arquivos, git, GitHub, busca na web, análise
  semântica de código e mais. Só um deles exige uma etapa manual (credenciais).
- **12 plugins** — comportamentos especializados: TDD, revisão de PR, design de
  frontend, modo de economia de tokens, entre outros.
- **`CLAUDE.md` global** — instruções persistentes que valem em qualquer projeto.
- **Skills, agents e commands** — fluxos de trabalho prontos, incluindo o
  `/preflight` que fecha esta trilha.
- **Memória por projeto** — o Claude lembra decisões e convenções entre sessões.

## O que é instalado, tecnicamente

Um script (`scripts/install.sh` ou `scripts/install.ps1`) copia os artefatos deste
repositório para `~/.claude/` e faz merge das configurações — nunca sobrescreve o
que você já tem. Duas coisas ficam de fora do script porque exigem uma decisão sua:
credenciais de MCP servers (etapa 03) e ajuste do `CLAUDE.md` ao seu contexto
(etapa 05).

## Tempo total

Cerca de 30 minutos, a maior parte em downloads e no cadastro de credenciais.

## Antes de começar

Se você nunca usou Claude Code, vale entender o que é antes de instalar — veja
[`docs/concepts/o-que-e-claude-code.md`](../concepts/o-que-e-claude-code.md).

---

**Próximo:** [Pré-requisitos](01-pre-requisitos.md)
