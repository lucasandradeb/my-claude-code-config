---
name: spec-driven
description: Use when starting a new project or feature and the user explicitly invokes /spec-driven. Sets up spec-driven development structure and guides creating the first specification document. Manual trigger only.
disable-model-invocation: true
allowed-tools: Read, Grep, Glob, Edit, Write, Bash
---

# Spec-Driven Development Setup

## Overview

Spec-driven development transforma requisitos vagos em artefatos estruturados que o Claude pode usar para verificar o proprio trabalho. O ciclo e: escrever spec → implementar → validar contra criterios de aceite.

**Principio central:** Uma boa spec nao descreve apenas "o que construir", mas tambem "como saber que esta correto".

## Quando Usar

- Novo projeto iniciando do zero
- Nova feature com escopo nao trivial
- Qualquer entrega onde "feito" precisa de definicao objetiva

## Passo 1 — Setup da Estrutura

Se o projeto nao tem a estrutura abaixo, criá-la agora:

```
projeto/
├─ CLAUDE.md                     # convencoes permanentes (stack, build, lint, test)
├─ docs/
│  └─ specs/
│     └─ .gitkeep
└─ .claude/
   └─ settings.json
```

```bash
mkdir -p docs/specs .claude
touch docs/specs/.gitkeep
```

Se CLAUDE.md nao existir, perguntar ao usuario:
- Stack principal e versoes
- Comando de build/test/lint
- Padroes de PR e commit
- Restricoes de arquitetura

## Passo 2 — Criar a Spec

Criar `docs/specs/<nome-da-feature>.md` com o template abaixo.

Preencher cada secao com o usuario antes de qualquer codigo.

```markdown
# [Nome da Feature]

## Problema
<!-- O que esta quebrado ou faltando? Por que isso importa? -->

## Objetivo
<!-- Uma frase: o que deve ser verdade apos a implementacao? -->

## Escopo

### Incluido
- 

### Excluido (fora de escopo)
- 

## Requisitos Funcionais
<!-- O que o sistema DEVE fazer -->
1. 

## Requisitos Nao Funcionais
<!-- Performance, seguranca, compatibilidade -->
- 

## Criterios de Aceite
<!-- Condicoes objetivas e verificaveis. Cada item deve ser true/false. -->
- [ ] 
- [ ] 

## Validacao
<!-- Comandos exatos para verificar cada criterio de aceite -->
```bash
# exemplo:
npm test -- --testPathPattern=feature-x
curl -X POST http://localhost:3000/endpoint -d '{"key":"value"}'
```

## Arquivos Impactados
<!-- Lista preliminar de arquivos/modulos afetados -->
- 

## Dependencias e Riscos
- 
```

## Passo 3 — Implementar a Partir da Spec

Com a spec preenchida, o fluxo de implementacao e:

1. Ler a spec completa
2. Mapear arquivos impactados (confirmar lista)
3. Apresentar plano curto (3-5 bullets) antes de editar qualquer arquivo
4. Implementar em incrementos pequenos, commitando logicamente
5. Executar os comandos de validacao da spec
6. Comparar resultado com cada criterio de aceite
7. Gerar resumo final:
   - criterios atendidos
   - pendencias
   - riscos identificados
   - testes executados

**Nao iniciar implementacao sem spec aprovada pelo usuario.**

## Passo 4 — Revisao Contra a Spec

Apos implementacao, verificar:

| Criterio de Aceite | Status | Evidencia |
|--------------------|--------|-----------|
| (copiar da spec)   | OK/FAIL| (output do teste) |

Se qualquer criterio falhar: abrir item de pendencia, nao marcar como concluido.

## Estrutura Madura (Projetos em Crescimento)

Quando o projeto tiver multiplas features, adicionar skills locais em `.claude/skills/`:

```
.claude/skills/
├─ implement-from-spec/SKILL.md   # implementacao guiada por spec
├─ review-against-spec/SKILL.md   # revisao final contra criterios
└─ open-pr-with-checklist/SKILL.md
```

Isso separa o metodo (skills) do trabalho corrente (specs em docs/specs/).

## Erros Comuns

| Erro | Correcao |
|------|----------|
| Criterios de aceite vagos ("funciona corretamente") | Reescrever como condicao booleana verificavel |
| Spec sem comando de validacao | Adicionar antes de comecar a codar |
| Comecar a codar antes da spec estar completa | Parar, terminar a spec, obter aprovacao |
| Spec descrevendo implementacao, nao comportamento | Focar no "o que", nao no "como" |
| CLAUDE.md vazio ou ausente | Preencher convencoes do projeto antes da primeira spec |
