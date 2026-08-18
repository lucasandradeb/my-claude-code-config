# Skills

Uma **skill** é um conjunto de instruções empacotado que o Claude carrega quando a
tarefa em questão combina com sua descrição — ou quando alguém invoca `/nome`
diretamente. Diferente de um command (veja [`commands.md`](commands.md)), uma
skill pode ser acionada automaticamente pelo próprio Claude ao reconhecer que a
situação se encaixa nela, sem que a pessoa precise digitar nada.

## Formato

Uma skill é um arquivo `SKILL.md` dentro de uma pasta com o nome da skill
(`skills/<nome-da-skill>/SKILL.md`), com frontmatter YAML:

```yaml
---
name: nome-da-skill
description: Quando usar esta skill — o Claude lê isto para decidir se aciona sozinho
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
disable-model-invocation: true
---
```

| Campo | Obrigatório | Efeito |
|---|---|---|
| `name` | sim | Identificador da skill; também o que vira `/nome` quando invocada manualmente |
| `description` | sim | Frase que o Claude usa para decidir **quando** acionar a skill sozinho. Precisa deixar claro o gatilho, não só o que a skill faz |
| `allowed-tools` | não | Restringe quais ferramentas a skill pode usar quando ativa. Omitir libera todas |
| `disable-model-invocation` | não | `true` impede o Claude de acionar a skill sozinho — só dispara com `/nome` explícito. Útil para skills com efeito colateral significativo (criar arquivos, reestruturar projeto) |

O corpo do arquivo, abaixo do frontmatter, é a instrução em si — o que o Claude
deve fazer quando a skill está ativa.

## Skill distribuída neste repositório

### `spec-driven`

Local: `skills/spec-driven/SKILL.md`.

Gatilho: `disable-model-invocation: true` — só ativa com `/spec-driven` explícito,
nunca sozinha. Transforma um requisito vago em uma spec estruturada (o que
construir e como saber que está correto) antes de partir para implementação.
Indicada para projetos novos ou features com escopo não trivial, onde "pronto"
precisa de uma definição objetiva antes de começar a codar.
