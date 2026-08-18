# 08 — Verificação

> Tempo estimado: 5 min

Última etapa: confirmar que tudo o que as etapas 02 a 07 instalaram e
configuraram está de fato funcionando.

## Rodar o `/preflight`

Abra uma conversa no Claude Code e digite:

```
/preflight
```

Esse command testa a autenticação e disponibilidade dos MCPs que a maioria das
sessões usa e reporta o status em tabela:

```
| MCP             | Status | Detalhe                        |
|-----------------|--------|---------------------------------|
| GitHub          | OK     |                                 |
| Atlassian/Jira  | OK     |                                 |
| Serena (LSP)    | OK     |                                 |
| Slack           | NÃO CONFIGURADO | —                      |
```

## Lendo a tabela

| Status | O que significa | O que fazer |
|---|---|---|
| **OK** | O MCP respondeu como esperado | Nada — siga em frente |
| **FALHOU** | O MCP está configurado mas a chamada de teste deu erro | Leia o "Detalhe" — geralmente é token expirado ou credencial errada; revise a etapa [03 — MCP Servers](03-mcp-servers.md) |
| **NÃO CONFIGURADO** | O MCP não está no seu `mcpServers` | Normal se você optou por não configurar aquele server (ex: Slack, se seu time não usa) |

`/preflight` cobre GitHub, Atlassian/Jira, Serena e Slack — não os 11 servers do
catálogo completo. Para os demais (filesystem, memory, brave-search, etc.),
confirme manualmente como descrito na etapa 03: peça ao Claude para listar os
MCP servers disponíveis e suas ferramentas.

## Checklist final

Além do `/preflight`, confirme rapidamente:

- **Plugins**: Command Palette → "Claude: List Installed Plugins" mostra os 12
  (etapa 04).
- **`CLAUDE.md`**: pergunte "quais são suas diretrizes de desenvolvimento para
  TypeScript e React?" e confira se a resposta segue o arquivo (etapa 05).
- **Memória**: pergunte algo que só está na sua pasta de memória do projeto e
  confirme que o Claude responde sem você repetir a informação (etapa 07).

Se tudo isso está verde, a instalação está completa.

## Se algo falhou

Qualquer FALHOU na tabela do `/preflight`, ou qualquer item do checklist que não
funcionou como esperado, tem uma seção dedicada em
[`troubleshooting.md`](troubleshooting.md).
