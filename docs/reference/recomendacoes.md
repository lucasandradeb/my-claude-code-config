# Recomendações: skills, MCPs e plugins

O que o mantenedor deste repositório usa no dia a dia, além do que o
`install.sh` já instala. Nada aqui é instalado automaticamente: cada item
depende de conta, credencial ou preferência pessoal, então a escolha é sua.

A lista não é opinião solta. Ela vem de 30 dias de uso medido (268 sessões),
contando chamadas reais de cada ferramenta nos transcripts. O número entre
parênteses é essa contagem. Itens sem contagem foram instalados mas não
aparecem nas chamadas, porque são acionados raramente ou pelo próprio
claude.ai.

Antes de instalar, lembre do custo: cada skill, MCP e plugin habilitado entra
no contexto de **toda** mensagem. Veja
[Economia de tokens](../concepts/economia-de-tokens.md). Instale o que você vai
usar, não o catálogo inteiro.

## Skills oficiais da Anthropic

A Anthropic publica um conjunto de skills em
[`anthropics/skills`](https://github.com/anthropics/skills). Elas **não são
copiadas** para este repositório: as skills de documento (`docx`, `pdf`,
`pptx`, `xlsx`) têm licença proprietária, e as demais são mantidas pela
Anthropic. Instalar pelo marketplace oficial garante a versão atual e respeita
as licenças.

```text
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
```

Se você usa uma conta do claude.ai, parte dessas skills pode já chegar
sincronizada pela conta. Confira a lista de skills da sessão antes de instalar,
para não carregar a mesma skill duas vezes.

### `document-skills`: as que o mantenedor mais recomenda

| Skill | Para que serve |
|---|---|
| `docx` | Criar e editar documentos Word preservando formatação |
| `pdf` | Ler, extrair, preencher formulários, juntar e dividir PDFs |
| `pptx` | Criar e editar apresentações PowerPoint |
| `xlsx` | Planilhas com fórmulas, formatação e análise de dados |

### `example-skills`: escolha as que fazem sentido

| Skill | Usa? | Para que serve |
|---|---|---|
| `skill-creator` | Sim | Criar e testar skills novas. Comece por ela antes de escrever a sua |
| `mcp-builder` | Sim | Guia para construir servidores MCP de qualidade |
| `doc-coauthoring` | Sim | Fluxo estruturado para escrever specs, propostas e documentos de decisão |
| `web-artifacts-builder` | Sim | Artifacts HTML mais elaborados (React, Tailwind, shadcn) |
| `canvas-design` | Sim | Peças visuais estáticas (pôster, PNG, PDF) |
| `theme-factory` | Sim | Aplicar temas visuais prontos a slides e documentos |
| `brand-guidelines` | Sim | Exemplo de skill de identidade visual; útil como modelo para a da sua empresa |
| `webapp-testing` | — | Testar apps web locais com Playwright |
| `internal-comms` | — | Comunicados internos (status, newsletters, FAQs) |
| `claude-api` | — | Referência da API do Claude e do SDK |
| `algorithmic-art`, `slack-gif-creator` | — | Arte generativa e GIFs para Slack |
| `frontend-design` | — | **Não instale** se já usa o plugin `frontend-design` habilitado no template: mesmo nome e mesma descrição, só o texto varia entre versões. As duas juntas competem pelo mesmo gatilho |

## Skills de plugins que realmente são usadas

Os plugins habilitados trazem dezenas de skills. Estas são as que apareceram
nas chamadas:

| Skill | Plugin | Uso medido |
|---|---|---|
| `/review` (command deste repositório) | — | (20) revisão de PR em Sonnet |
| `brainstorming` | `superpowers` | (6) explorar requisitos antes de construir |
| `writing-plans` | `superpowers` | (4) plano de implementação a partir de spec |
| `subagent-driven-development` | `superpowers` | (3) executar o plano com um subagente por task |
| `systematic-debugging` | `superpowers` | (2) investigar bug antes de propor correção |
| `caveman` | `caveman` | sempre ativo; respostas curtas reduzem tokens de saída |

Se você não usa o fluxo spec → plano → execução, o `superpowers` provavelmente
não compensa o contexto que ocupa. Ele injeta a própria introdução em toda
sessão.

## MCPs e conectores

O template só traz o MCP `github` (veja [MCP servers](mcp-servers.md)). Os
abaixo são **conectores do claude.ai**: você conecta uma vez em
claude.ai → Settings → Connectors e eles aparecem no Claude Code quando você
está logado na mesma conta. Não exigem configuração local nem token no
`~/.claude.json`.

| Conector | Uso medido | Para que serve |
|---|---|---|
| Atlassian (Jira/Confluence) | (281) | Criar e buscar issues, JQL, ler páginas do Confluence |
| Claude in Chrome | (162) | Automação do navegador: navegar, clicar, ler console e rede. Exige a extensão do Chrome |
| Todoist | (140) | Tarefas pessoais e planejamento |
| context7 (plugin) | (19) | Documentação atualizada de bibliotecas, em vez do conhecimento de treino |
| Sentry | (16) | Investigar erros de produção e eventos |
| GitHub (MCP do template) | (12) | PRs e issues; o `gh` via Bash cobre quase tudo com menos contexto |
| Vercel | (8) | Deploys, logs e projetos |
| Slack | (4) | Ler canais e threads, enviar mensagens |

Dois cuidados:

- **Conecte uma vez só.** Conectar o mesmo serviço duas vezes (aconteceu com o
  Atlassian) duplica dezenas de tools no contexto de toda sessão.
- **Desconecte o que não usa na CLI.** Gmail, Calendar e Drive estavam
  conectados com zero chamadas no Claude Code. Se você usa esses conectores só
  no app web, a lista de tools deles continua pesando no terminal.

## Plugins

A lista completa, com o status e o motivo de cada um, está em
[Plugins](plugins.md). O núcleo que o mantenedor recomenda manter:

- `superpowers`, se você trabalha com spec → plano → execução.
- `caveman`, para reduzir tokens de saída.
- `context7`, para documentação atualizada de bibliotecas.
- `frontend-design`, para qualquer trabalho de interface.
- `claude-md-management`, para manter o `CLAUDE.md` enxuto e atualizado.

Fora dos plugins, o hook do [RTK](../concepts/economia-de-tokens.md) no
`PreToolUse` do Bash é o que mais economiza tokens em operações de terminal.

## O que não recomendamos

Os MCPs e plugins que estavam instalados e não tiveram uso estão listados, com
o motivo, em [MCP servers → Removidos e por quê](mcp-servers.md#removidos-e-por-quê)
e na tabela de desabilitados em [Plugins](plugins.md).
