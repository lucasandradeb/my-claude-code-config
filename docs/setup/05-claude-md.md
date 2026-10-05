# 05 — CLAUDE.md

> Tempo estimado: 5 min

O instalador já copiou `config/CLAUDE.md` deste repositório para
`~/.claude/CLAUDE.md`. Não há passo manual de cópia — esta etapa é entender o
que esse arquivo faz e adaptá-lo ao seu contexto.

## O que o `CLAUDE.md` instalado faz

O Claude Code carrega esse arquivo automaticamente no início de toda conversa,
em qualquer projeto, e aplica as instruções nele contidas. Como ele entra no
contexto de **toda** mensagem, é propositalmente curto (~3,5 mil caracteres): a
versão anterior, com ~18 mil, trazia exemplos longos de TypeScript, Python e C#
que o modelo já conhece e que custavam tokens em toda sessão. O `CLAUDE.md` deste
repositório define:

- **Comunicação** — português brasileiro, objetivo, sem emojis; confirmar antes de
  ação destrutiva ou em produção.
- **Roteamento de modelo e subagentes** — thread principal em Opus para
  raciocínio; pesquisa em subagente Sonnet; busca pontual em subagente Haiku;
  revisão de PR via `/review` (Sonnet). Veja
  [`modelos.md`](../reference/modelos.md#roteamento-por-tarefa).
- **Gestão de contexto** — uma tarefa por sessão, documento de estado para frentes
  longas, leitura ampla delegada a subagentes, preferência por CLIs a MCPs
  equivalentes.
- **Código** — princípios curtos por stack (TypeScript/React, .NET, Python).
- **Segurança** — nunca commitar segredos, queries parametrizadas, dados sensíveis
  fora de artefatos e memória.
- **Git** — formato de commit, nomenclatura de branch, commit e push só sob pedido.

## Como confirmar que carregou

Numa conversa nova, pergunte:

```
Como você deve rotear pesquisa e busca pontual entre subagentes?
```

O Claude deve responder seguindo o conteúdo do `CLAUDE.md` — se a resposta não
menciona nada do arquivo, ele não foi carregado (veja a etapa de verificação
final desta trilha).

## Como adaptar ao seu contexto

O `CLAUDE.md` global vale para **todo** projeto que você abrir. Duas formas de
especializar:

1. **Editar o arquivo global** (`~/.claude/CLAUDE.md`) — para convenções que
   valem em qualquer repositório em que você trabalha (seu estilo de
   comunicação preferido, padrões de linguagem que você sempre segue).
2. **Criar um `CLAUDE.md` por projeto** — na raiz do repositório específico,
   versionado com o código. Ele se soma ao global, não o substitui: use-o para
   contexto que só faz sentido naquele projeto (mapa de serviços, portas
   locais, comandos específicos daquele repositório).

Um `CLAUDE.md` por projeto é revisado e versionado como qualquer outro arquivo
do time — mudanças nele passam por PR normal.

---

**Próximo:** [Skills, Agents e Commands](06-skills-agents-commands.md)
