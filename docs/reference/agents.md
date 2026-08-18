# Agents

Um **subagente** é uma instância separada do Claude que roda uma tarefa específica
com seu próprio contexto — não vê o histórico da conversa principal, só o que o
brief dele explicitar. O Claude principal age como orquestrador: dispara um ou
mais subagentes (em paralelo quando as tarefas são independentes), cada um resolve
a sua parte, e o orquestrador consolida os resultados.

## Por que contexto próprio importa

Contexto separado é o que permite paralelismo real — três subagentes revisando três
PRs diferentes não competem pela mesma janela de contexto nem se confundem com o
progresso um do outro. O custo é que cada subagente **não sabe nada** que não foi
passado explicitamente: sem acesso à conversa que o disparou, sem memória de
disparos anteriores (a menos que seja uma continuação explícita do mesmo agente).

## O que precisa constar no brief

Um brief incompleto é a causa mais comum de um subagente fazer a coisa errada.
Sempre inclua:

- **O que fazer** — instrução específica, não "resolve isso pra mim"
- **Identificadores necessários** — número de PR, `owner/repo`, caminho de arquivo;
  o subagente não consegue adivinhar o que só existe na conversa principal
- **Contexto que não é derivável do código** — uma decisão arquitetural intencional
  que parece um bug, uma convenção do time que não está documentada
- **Formato de saída esperado**, quando relevante — texto livre, tabela, JSON

## Agents distribuídos neste repositório

### `pr-reviewer`

Local: `agents/pr-reviewer.md`.

Revisa uma PR do GitHub e posta os comentários inline. Projetado para ser
disparado **em paralelo**, um agente por PR — dispare vários numa única mensagem
quando houver 2 ou mais PRs para revisar, em vez de revisar em sequência na thread
principal. Requer no brief: número da PR e `owner/repo`. Verifica se a PR está
aberta, filtra mudanças mecânicas (formatação, rename), busca bugs reais e
problemas de segurança, e mantém tom didático e informal — nunca imperativo.

### `domain-analyst` (template)

Local: `agents/domain-analyst.md`.

Não é um agente pronto para uso — é um template para adaptar com conhecimento de
domínio específico do seu time (regras de negócio, invariantes críticos, tipos de
dados sensíveis). Edite as seções marcadas com `[ADAPTE]` antes de usar. Dispare
junto com `pr-reviewer` em PRs que tocam lógica crítica de negócio que exige
conhecimento especializado além de uma revisão genérica.

## Como criar um agent próprio

Arquivo `.md` em `agents/`, com frontmatter:

```yaml
---
name: nome-do-agente
description: O que ele faz — o Claude usa isto para decidir quando chamar
model: sonnet
---
```

Corpo do arquivo: contexto de domínio, inputs obrigatórios, processo passo a
passo, e formato de output esperado.
