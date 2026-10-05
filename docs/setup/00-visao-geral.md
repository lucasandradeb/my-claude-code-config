# 00 — Visão geral

> Tempo estimado: 3 min

Esta trilha leva você de uma máquina limpa até um `/preflight` verde: Claude Code
instalado, MCP servers conectados, plugins carregados, `CLAUDE.md` no lugar,
skills/agents/commands copiados e memória configurada.

## O que você ganha ao final

- **Claude Code** rodando no VSCode, autenticado com sua conta Anthropic.
- **1 MCP server** (`github`) — o único mantido de propósito: cada MCP custa
  tokens de contexto em toda sessão, então o template só traz o que é usado. Ele
  exige uma etapa manual (token do GitHub).
- **16 entradas de plugin** — 10 habilitadas (TDD, revisão de PR, design de
  frontend, modo de economia de tokens, entre outros) e 6 explicitamente
  desabilitadas por falta de uso ou duplicidade.
- **`CLAUDE.md` global enxuto** — instruções persistentes (~3,5 mil caracteres)
  que valem em qualquer projeto, incluindo o roteamento de modelo por tarefa.
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
