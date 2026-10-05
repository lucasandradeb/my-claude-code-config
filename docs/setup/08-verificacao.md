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
| Serena (LSP)    | NÃO CONFIGURADO | — (opcional)           |
| Slack           | NÃO CONFIGURADO | —                      |
```

## Lendo a tabela

| Status | O que significa | O que fazer |
|---|---|---|
| **OK** | O MCP respondeu como esperado | Nada — siga em frente |
| **FALHOU** | O MCP está configurado mas a chamada de teste deu erro | Leia o "Detalhe" — geralmente é token expirado ou credencial errada; revise a etapa [03 — MCP Servers](03-mcp-servers.md) |
| **NÃO CONFIGURADO** | O MCP não está no seu `mcpServers` | Normal se você optou por não configurar aquele server (ex: Slack, se seu time não usa) |

`/preflight` cobre GitHub, Atlassian/Jira, Serena e Slack. O template só traz o
server `github`; os demais só aparecem na tabela se você os adicionou. A linha do
Serena (LSP) depende do server do Serena, que é opcional (veja
[`mcp-servers.md`](../reference/mcp-servers.md#como-readicionar-um-server)) —
`NÃO CONFIGURADO` ali é esperado numa instalação padrão. Para confirmar o que está
carregado de fato, peça ao Claude para listar os MCP servers disponíveis, ou rode
`/context` para ver o custo de cada um.

## Checklist final

Além do `/preflight`, confirme rapidamente:

- **Plugins**: Command Palette → "Claude: List Installed Plugins" mostra os 10
  habilitados (etapa 04).
- **`CLAUDE.md`**: pergunte "como você deve rotear pesquisa e busca pontual entre
  subagentes?" e confira se a resposta segue o arquivo (etapa 05).
- **Memória**: pergunte algo que só está na sua pasta de memória do projeto e
  confirme que o Claude responde sem você repetir a informação (etapa 07).

Se tudo isso está verde, a instalação está completa.

## Se algo falhou

Qualquer FALHOU na tabela do `/preflight`, ou qualquer item do checklist que não
funcionou como esperado, tem uma seção dedicada em
[`troubleshooting.md`](../troubleshooting.md).
