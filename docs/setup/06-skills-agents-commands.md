# 06 — Skills, Agents e Commands

> Tempo estimado: 5 min

O instalador já copiou tudo que existe nas pastas `skills/`, `agents/` e
`commands/` deste repositório para `~/.claude/skills/`, `~/.claude/agents/` e
`~/.claude/commands/`. Esta etapa é entender a diferença entre os três e como
usar cada um — os catálogos completos estão nas referências abaixo.

## A diferença entre os três

| | Dispara quando | Exemplo |
|---|---|---|
| **Command** | Alguém digita `/nome` explicitamente — nunca sozinho | `/preflight` |
| **Skill** | O Claude reconhece que a tarefa combina com a descrição, ou alguém invoca `/nome` | Revisão de PR, planejamento de feature |
| **Agent** | O Claude principal dispara como subagente, geralmente para paralelizar | Revisar 3 PRs ao mesmo tempo |

Um command é controle explícito seu; uma skill pode ser acionada pelo próprio
Claude; um agent é uma instância separada com seu próprio contexto, usada para
paralelismo ou para isolar uma tarefa que não precisa ver o histórico da
conversa principal.

## O que foi instalado

- **Commands** — veja [`docs/reference/commands.md`](../reference/commands.md)
  para a lista completa. O mais importante para esta trilha é `/preflight`,
  usado na última etapa.
- **Skills** — veja [`docs/reference/skills.md`](../reference/skills.md) para
  o catálogo e quando cada uma dispara automaticamente.
- **Agents** — veja [`docs/reference/agents.md`](../reference/agents.md) para
  os subagentes distribuídos e o que precisa constar no brief de cada um.

## Como usar

**Command**: digite `/` numa conversa para ver a lista, ou digite o nome direto
(ex: `/preflight`).

**Skill**: normalmente não precisa fazer nada — descreva a tarefa e o Claude
carrega a skill relevante sozinho. Para forçar uma skill específica, use `/nome`
como faria com um command.

**Agent**: peça em linguagem natural o que precisa ser paralelizado (ex: "revisa
as PRs 42 e 43 pra mim") — o Claude principal decide disparar os subagentes
certos com base no que está descrito em `docs/reference/agents.md`.

---

**Próximo:** [Memória](07-memoria.md)
