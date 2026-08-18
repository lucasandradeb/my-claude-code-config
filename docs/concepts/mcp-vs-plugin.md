# MCP server ou plugin, skill, agent?

Pergunta prática que o time faz o tempo todo: "preciso disso, devo escrever um MCP
server ou basta um plugin/skill/agent?" A resposta depende de uma distinção só:
**ferramenta nova vs. comportamento novo.**

## A distinção central

| Aspecto | Plugin (ou skill/agent) | MCP server |
|---|---|---|
| **O que faz** | Modifica comportamento e adiciona skills | Adiciona ferramentas e capacidades externas |
| **Como funciona** | Altera instruções e fluxos internos | Conecta a serviços e APIs externos |
| **Exemplo** | `code-review` — ensina como revisar código | GitHub MCP — acesso à API do GitHub |
| **Ativação** | Configurado em `settings.json` | Configurado em `mcp.json` |
| **Persiste** | Em todas as conversas do projeto | Em todas as conversas do projeto |

**Analogia**:
- **Plugin/skill/agent** = mudar a "especialidade e metodologia" do Claude
- **MCP server** = dar novas "ferramentas e acessos" ao Claude

Se a pergunta é "o Claude precisa **acessar** algo que ele não alcança hoje" (um
banco de dados, uma API externa, um sistema de arquivos fora do workspace) —
é MCP server. Se a pergunta é "o Claude precisa **agir diferente** com as
ferramentas que já tem" (seguir um processo, aplicar um checklist, adotar um
tom) — é plugin, skill ou agent.

## Por que isso importa na prática: o efeito da análise semântica

O exemplo mais concreto do repositório é o Serena MCP server, que troca busca
textual por análise semântica de código:

### Sem MCP server (busca textual)
```
Você: "Encontre todos os usos da função processPayment"
Claude: Usa busca textual simples (grep)
  → Pode encontrar comentários, strings, etc.
  → Não entende escopo ou contexto
```

### Com Serena MCP (análise semântica)
```
Você: "Encontre todos os usos da função processPayment"
Claude: Usa análise semântica
  → Encontra apenas referências reais à função
  → Mostra contexto de cada uso
  → Pode mostrar call hierarchy
```

Nenhum plugin resolveria isso — a limitação não é de comportamento, é de
ferramenta: sem o MCP server, o Claude simplesmente não tem acesso à árvore de
símbolos do projeto.

## E entre plugin, skill e agent?

Uma vez decidido que o caso é de comportamento (não de ferramenta nova), a
escolha entre plugin, skill e agent depende de escopo:

- **Plugin** — pacote distribuível que agrupa skills, agents e configuração;
  unidade de instalação. Veja [`docs/reference/plugins.md`](../reference/plugins.md).
- **Skill** — instrução que o Claude carrega quando a tarefa combina com sua
  descrição, ou via `/nome` explícito; vive dentro de um plugin ou solta em
  `skills/`. Veja [`docs/reference/skills.md`](../reference/skills.md).
- **Agent** (subagente) — instância separada do Claude com contexto próprio,
  usada para paralelizar ou isolar uma tarefa específica (ex.: revisar várias
  PRs ao mesmo tempo). Veja [`docs/reference/agents.md`](../reference/agents.md).

A lista completa de plugins habilitados neste repositório e o que cada um faz
está em [`docs/reference/plugins.md`](../reference/plugins.md) — este documento
não repete essa tabela, só a lógica de decisão para chegar até ela.
