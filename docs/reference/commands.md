# Commands

Um **command** é um arquivo `.md` que vira um atalho de barra (`/nome`) no chat do
Claude Code. Ao contrário de uma skill (veja [`skills.md`](skills.md)), um command
só dispara quando alguém digita `/nome` explicitamente — o Claude nunca aciona um
command sozinho. É a ferramenta certa para um fluxo que a pessoa quer controlar
quando invocar, não algo que deveria acontecer implicitamente.

## Formato

Arquivo `.md` em `commands/`, com frontmatter YAML:

```yaml
---
description: O que o command faz — aparece na lista de comandos disponíveis
allowed-tools: lista de ferramentas permitidas quando o command roda
disable-model-invocation: false
---

Instrução clara do que o Claude deve fazer quando o command for ativado.
```

`allowed-tools` restringe o escopo do command às ferramentas realmente necessárias
— por exemplo, um command que só lê PRs não precisa de permissão de escrita em
arquivo.

## Commands distribuídos neste repositório

### `/preflight`

Local: `commands/preflight.md`.

Testa se os MCPs que a sessão vai usar (GitHub, Jira/Atlassian, Serena, Slack)
estão autenticados e funcionando, e reporta o status em tabela. Use no início de
qualquer sessão longa que dependa desses MCPs — evita descobrir um token expirado
no meio do trabalho, depois de já ter investido tempo nele.

### `/review`

Local: `commands/review.md`.

Faz code review completo de uma pull request: busca o diff, verifica testes,
identifica problemas e posta comentários. Já paraleliza internamente, então é a
ferramenta certa para revisar **uma** PR — para 2 ou mais PRs ao mesmo tempo, use
o agente `pr-reviewer` (veja [`agents.md`](agents.md#pr-reviewer)), que dispara uma
instância por PR em paralelo. Segue um estilo de comunicação específico: tom
informal e didático, nunca imperativo, sempre em português brasileiro.

## Command ou Agent?

| | Command `/review` | Agent `pr-reviewer` |
|---|---|---|
| Quantas PRs | 1 | 2 ou mais |
| Paralelismo | Já é paralelo internamente | Múltiplas PRs em paralelo, um agente por PR |
| Quem aciona | A pessoa, digitando `/review` | O Claude, automaticamente, ao ver 2+ PRs |

## Como criar um command próprio

Salve um arquivo `.md` em `commands/`, seguindo o formato acima. O nome do arquivo
(sem `.md`) é o nome do atalho — `commands/meu-command.md` vira `/meu-command`.
