# 05 — CLAUDE.md

> Tempo estimado: 5 min

O instalador já copiou `config/CLAUDE.md` deste repositório para
`~/.claude/CLAUDE.md`. Não há passo manual de cópia — esta etapa é entender o
que esse arquivo faz e adaptá-lo ao seu contexto.

## O que o `CLAUDE.md` instalado faz

O Claude Code carrega esse arquivo automaticamente no início de toda conversa,
em qualquer projeto, e aplica as instruções nele contidas. O `CLAUDE.md` deste
repositório define:

- **Filosofia de trabalho** — explicação antes da ação, código legível antes de
  conciso, segurança nunca comprometida por velocidade.
- **Diretrizes por linguagem** — convenções de TypeScript/React, Python e C#
  usadas pelo time (estrutura de componentes, type hints, nomenclatura, etc.).
- **Segurança** — validação de entrada, tratamento de credenciais, vulnerabilidades
  comuns a evitar em qualquer linguagem.
- **Convenções de git** — formato de commit, nomenclatura de branch, o que uma
  PR precisa conter.
- **Insights educacionais** — formato usado para explicar trade-offs técnicos.

## Como confirmar que carregou

Numa conversa nova, pergunte:

```
Quais são suas diretrizes de desenvolvimento para TypeScript e React?
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
