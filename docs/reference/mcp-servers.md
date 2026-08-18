# MCP Servers

**MCP (Model Context Protocol)** conecta o Claude Code a servidores que adicionam
**ferramentas** — acesso a arquivos, APIs, bancos de dados, busca na web. Isso é
diferente de um plugin, que muda comportamento sem adicionar ferramentas novas —
veja [`plugins.md`](plugins.md#plugin-ou-mcp-server).

Fonte única dos 11 servers configurados em `config/mcp-servers.template.json`.

## Os 11 servers

| Server | Comando | Precisa de credencial? | Para que serve |
|---|---|---|---|
| `filesystem` | `npx -y @modelcontextprotocol/server-filesystem $WORKSPACE_DIR` | Não | Leitura/escrita de múltiplos arquivos, busca por padrão glob, operações atômicas de edição |
| `git` | `npx -y @modelcontextprotocol/server-git --repository $WORKSPACE_DIR` | Não | Operações git estruturadas sobre o repositório de trabalho |
| `github` | `npx -y @modelcontextprotocol/server-github` | Sim — `GITHUB_PERSONAL_ACCESS_TOKEN` | PRs, issues, busca de código e branches via API do GitHub |
| `memory` | `npx -y @modelcontextprotocol/server-memory` | Não | Knowledge graph persistente entre conversas (entidades, observações, relações) |
| `sqlite` | `npx -y @modelcontextprotocol/server-sqlite $WORKSPACE_DIR` | Não | Consultas e inspeção de bancos SQLite locais |
| `sequential-thinking` | `npx -y @modelcontextprotocol/server-sequential-thinking` | Não | Raciocínio estruturado passo a passo para problemas complexos |
| `brave-search` | `npx -y @modelcontextprotocol/server-brave-search` | Sim — `BRAVE_API_KEY` | Busca na web para informação além do knowledge cutoff do modelo |
| `fetch` | `npx -y @modelcontextprotocol/server-fetch` | Não | Busca o conteúdo de uma URL específica |
| `serena` | `uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context claude-code --project $WORKSPACE_DIR` | Não | Análise semântica de código: símbolos, referências, rename seguro |
| `docker` | `uvx docker-mcp` | Não (usa o daemon Docker local) | Gerenciamento de containers e stacks Docker Compose |
| `supabase` | `npx -y @supabase/mcp-server-supabase@latest --access-token` | Sim — token de acesso Supabase | Acesso a projetos e dados Supabase |

## Pendências conhecidas

- **`supabase`**: o template traz `--access-token` sem valor depois. O server não
  sobe enquanto esse argumento não for completado com um token real — cada pessoa
  precisa editar sua cópia local de `mcp-servers.template.json` (nunca commitar o
  token de volta).
- **`filesystem`, `git`, `sqlite` e `serena`** recebem um diretório de trabalho como
  argumento. No template esse valor é o placeholder `$WORKSPACE_DIR`; cada pessoa
  aponta para o caminho real do seu próprio projeto ao instalar.
