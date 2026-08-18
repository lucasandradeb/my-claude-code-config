# my-claude-code-config

Configuração pessoal do Claude Code — plugins, MCP servers, skills, agents,
commands e memória — empacotada como repositório instalável.

## Início rápido

```bash
git clone <url-deste-repositorio>
./scripts/install.sh   # instala em ~/.claude, sem sobrescrever o que já existe
/preflight              # verifica autenticação e disponibilidade dos MCPs
```

## O que vem junto

| Item | Quantidade | Referência |
|---|---|---|
| Plugins | 12 | [`docs/reference/plugins.md`](docs/reference/plugins.md) |
| MCP servers | 11 | [`docs/reference/mcp-servers.md`](docs/reference/mcp-servers.md) |
| Skills | 1 | [`docs/reference/skills.md`](docs/reference/skills.md) |
| Agents | 2 | [`docs/reference/agents.md`](docs/reference/agents.md) |
| Commands | 2 | [`docs/reference/commands.md`](docs/reference/commands.md) |
| `CLAUDE.md` | — | [`docs/setup/05-claude-md.md`](docs/setup/05-claude-md.md) |
| RTK (Rust Token Killer) | — | [`docs/concepts/economia-de-tokens.md`](docs/concepts/economia-de-tokens.md) |

## Documentação

| Trilha (leia em ordem) | Catálogo (consulte sob demanda) | Conceitos |
|---|---|---|
| [00 · Visão geral](docs/setup/00-visao-geral.md) | [MCP servers](docs/reference/mcp-servers.md) | [O que é Claude Code](docs/concepts/o-que-e-claude-code.md) |
| [01 · Pré-requisitos](docs/setup/01-pre-requisitos.md) | [Plugins](docs/reference/plugins.md) | [MCP vs. plugin](docs/concepts/mcp-vs-plugin.md) |
| [02 · Instalação](docs/setup/02-instalacao.md) | [Skills](docs/reference/skills.md) | [Economia de tokens](docs/concepts/economia-de-tokens.md) |
| [03 · MCP servers](docs/setup/03-mcp-servers.md) | [Agents](docs/reference/agents.md) | [Memória](docs/concepts/memoria.md) |
| [04 · Plugins](docs/setup/04-plugins.md) | [Commands](docs/reference/commands.md) | |
| [05 · CLAUDE.md](docs/setup/05-claude-md.md) | [Modelos](docs/reference/modelos.md) | |
| [06 · Skills, agents, commands](docs/setup/06-skills-agents-commands.md) | [Settings](docs/reference/settings.md) | |
| [07 · Memória](docs/setup/07-memoria.md) | | |
| [08 · Verificação](docs/setup/08-verificacao.md) | | |

[Solução de problemas](docs/troubleshooting.md) reúne os erros mais comuns de instalação e sincronização.

## Manutenção

```bash
make sync    # copia ~/.claude/ para este repositorio, sanitizando segredos
make check   # roda testes, varredura de segredo, links e shellcheck
```

Veja [`CONTRIBUTING.md`](CONTRIBUTING.md) para o fluxo completo de contribuição.

## Licença

MIT — veja [`LICENSE`](LICENSE).
