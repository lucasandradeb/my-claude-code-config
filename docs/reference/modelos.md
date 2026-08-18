# Modelos

Identificadores de modelo mudam com frequência — os desta página foram confirmados
consultando a skill `claude-api` no momento em que este documento foi escrito, não
citados de memória. Se um identificador aqui parecer desatualizado, consulte a
skill de novo antes de confiar nele.

## Modelos atuais

| Modelo | Identificador | Quando escolher |
|---|---|---|
| Claude Opus 5 | `claude-opus-5` | Tarefas de raciocínio pesado, arquitetura, debugging complexo — o modelo mais capaz para uso geral. Padrão recomendado quando não há motivo para economizar. |
| Claude Sonnet 5 | `claude-sonnet-5` | Equilíbrio entre capacidade e custo — bom padrão para desenvolvimento do dia a dia, revisão de código, a maioria das tarefas de um subagente. |
| Claude Haiku 4.5 | `claude-haiku-4-5` | Tarefas simples e de alto volume: classificação, extração, subagentes com escopo estreito e bem definido, onde velocidade e custo importam mais que profundidade de raciocínio. |
| Claude Fable 5 | `claude-fable-5` | Uso restrito a quem precisa do modelo mais capaz disponível para trabalho de raciocínio e agentic de altíssimo horizonte. Fora do escopo do uso comum deste repositório. |

Também existem versões anteriores ainda em uso em alguns lugares (Opus 4.8, Opus
4.7, Opus 4.6, Sonnet 4.6) — se precisar de um identificador de modelo mais antigo
que não está nesta tabela, consulte a skill `claude-api` para o valor exato: não
adivinhe, e nunca acrescente sufixo de data ao identificador.

**Preços**: não estão nesta página. Um número fixo em documentação vence sozinho —
a página oficial de pricing não. Consulte sempre
[claude.com/pricing](https://claude.com/pricing) para os valores atuais por
modelo.

## `model` no settings vs. `ANTHROPIC_MODEL`

O `settings.json` (chave `model`, documentada em [`settings.md`](settings.md#model))
define o modelo padrão para sessões abertas normalmente pelo Claude Code. Ele
aceita tanto um alias curto (`"sonnet"`, `"opus"`, `"haiku"`) quanto um
identificador completo como os da tabela acima.

A variável de ambiente `ANTHROPIC_MODEL`, quando definida no shell, **prevalece
sobre** o valor de `model` em `settings.json`. Isso é útil para:

- Forçar um modelo específico numa sessão pontual sem editar o arquivo de
  configuração: `ANTHROPIC_MODEL=claude-haiku-4-5 claude`.
- Scripts e pipelines de CI que precisam de um modelo determinístico independente
  da configuração local de quem os executa.

Se nem `ANTHROPIC_MODEL` nem `model` estiverem definidos, o Claude Code usa seu
próprio modelo padrão interno. A ordem de precedência, do mais forte para o mais
fraco, é: `ANTHROPIC_MODEL` (ambiente) → `model` (`settings.json`) → padrão interno
do Claude Code.
