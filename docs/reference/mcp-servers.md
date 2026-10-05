# MCP Servers

**MCP (Model Context Protocol)** conecta o Claude Code a servidores que adicionam
**ferramentas** — acesso a arquivos, APIs, bancos de dados, busca na web. Isso é
diferente de um plugin, que muda comportamento sem adicionar ferramentas novas —
veja [`plugins.md`](plugins.md#plugin-ou-mcp-server).

Fonte única dos servers configurados em `config/mcp-servers.template.json`: hoje,
apenas um.

## Princípio: cada MCP tem custo fixo

Todo MCP server conectado injeta contexto em **toda** sessão, mesmo quando você
não o usa: nomes das ferramentas (adiadas), instruções do server e schemas quando
são carregados. Por isso o template só mantém o que tem uso real. Veja a medição
em [`economia-de-tokens.md`](../concepts/economia-de-tokens.md#lições-medidas-de-um-caso-real).

## O server mantido

| Server | Comando | Precisa de credencial? | Para que serve |
|---|---|---|---|
| `github` | `npx -y @modelcontextprotocol/server-github` | Sim — `GITHUB_PERSONAL_ACCESS_TOKEN` | PRs, issues, busca de código e branches via API do GitHub |

## Removidos e por quê

Em 30 dias de medição (268 sessões), estes servers não tiveram uso ou duplicavam
ferramentas nativas do Claude Code:

| Server removido | Motivo |
|---|---|
| `filesystem` | Duplica `Read`, `Write` e `Edit` nativos |
| `git` | Duplica git via `Bash` |
| `fetch` | Duplica `WebFetch` |
| `brave-search` | Duplica `WebSearch`; também dispensa a `BRAVE_API_KEY` |
| `memory` | Duplica a memória nativa por arquivos (veja [`memoria.md`](../concepts/memoria.md)) |
| `sequential-thinking` | O modelo já raciocina passo a passo por conta própria |
| `serena` | Sem uso medido; opcional (veja abaixo e [`plugins.md`](plugins.md)) |
| `docker` | Sem uso medido; o CLI `docker` via `Bash` cobre o caso |
| `sqlite` | Sem uso medido; o CLI `sqlite3` via `Bash` cobre o caso |
| `supabase` | Sem uso medido; exigia token com argumento incompleto no template |

## Como readicionar um server

Duas formas equivalentes.

**Pelo CLI** (confira `claude mcp add --help` para a sintaxe da sua versão):

```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena \
  serena start-mcp-server --context claude-code --project /caminho/do/projeto
```

**Editando `mcpServers` em `~/.claude.json`** — por exemplo, o Serena (análise
semântica de código: símbolos, referências, rename seguro):

```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": [
        "--from", "git+https://github.com/oraios/serena",
        "serena", "start-mcp-server",
        "--context", "claude-code",
        "--project", "/caminho/do/projeto"
      ]
    }
  }
}
```

Depois de adicionar, rode `/context` para ver quanto o novo server custa e decida
se vale manter. O plugin `serena` continua habilitado no template, mas sem o server
ele tem pouco efeito — veja [`plugins.md`](plugins.md).
