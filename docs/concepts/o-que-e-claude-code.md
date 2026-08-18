# O que é Claude Code?

**Claude Code** é um assistente de programação AI desenvolvido pela Anthropic que
funciona como uma extensão do VSCode (também existe como CLI standalone). Pense
nele como um **colega de equipe especializado** que entende código, pode ler e
modificar arquivos, executar comandos, buscar informações online e muito mais.

## Principais características

- **Integração nativa com VSCode**: trabalha diretamente no seu editor
- **Execução de comandos**: pode rodar scripts, testes, git commands, etc.
- **Leitura e escrita de arquivos**: manipula código com precisão
- **Análise semântica**: entende a estrutura e relações do código
- **Extensível via MCP**: adiciona capacidades através de servidores especializados
  (veja [`docs/reference/mcp-servers.md`](../reference/mcp-servers.md))
- **Conversação contextual**: mantém contexto da conversa e do projeto

## Como funciona?

```
Você → Pergunta/Pedido → Claude Code → Analisa → Executa Ações → Responde
                                ↓
                          MCP Servers
                          (Filesystem, GitHub, etc.)
```

O Claude Code recebe suas instruções em linguagem natural, analisa o contexto do
projeto, usa ferramentas especializadas (MCP servers) e executa as ações
necessárias.

## Qual modelo ele usa?

Isso é uma escolha separada de "o que é Claude Code" — veja
[`docs/reference/modelos.md`](../reference/modelos.md) para a tabela de modelos
disponíveis (Opus, Sonnet, Haiku, Fable) e quando escolher cada um.

## Para ir além

- **MCP server ou plugin?** — veja
  [`docs/concepts/mcp-vs-plugin.md`](mcp-vs-plugin.md)
- **Como o Claude lembra de decisões entre conversas?** — veja
  [`docs/concepts/memoria.md`](memoria.md)
- **Como usar tokens com eficiência?** — veja
  [`docs/concepts/economia-de-tokens.md`](economia-de-tokens.md)
