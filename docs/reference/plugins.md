# Plugins

Plugins modificam **como o Claude pensa e age**: adicionam skills, comportamentos e
fluxos de trabalho especializados. Isso é diferente de um MCP server, que adiciona
**ferramentas** (acesso a sistemas externos) sem mudar o comportamento do Claude —
veja [Plugin ou MCP server?](#plugin-ou-mcp-server) abaixo.

Esta é a fonte única da lista de plugins do repositório. Ela existia duplicada em
três arquivos (`README.md`, `GUIA_CONFIGURACAO_TIME.md`, `EXEMPLO_CONFIGURACAO.md`)
e as três cópias já haviam divergido entre si. A tabela abaixo reflete exatamente o
que `config/settings.template.json` habilita em `enabledPlugins`.

## Os 12 plugins

| Plugin | Identificador | Para que serve | Quando usar |
|---|---|---|---|
| `superpowers` | `superpowers@claude-plugins-official` | Framework central de skills de fluxo de trabalho: brainstorm, planejamento, TDD, debugging sistemático, verificação antes de concluir, dispatch de subagentes | Sempre ativo — estrutura qualquer tarefa de desenvolvimento não trivial |
| `explanatory-output-style` | `explanatory-output-style@claude-code-plugins` | Modo educacional: explica decisões técnicas e trade-offs, adiciona blocos de insight após escrever código | Sempre ativo — útil para aprendizado e onboarding de devs menos experientes |
| `context7` | `context7@claude-plugins-official` | Busca documentação atualizada de bibliotecas e frameworks direto na conversa | Ao trabalhar com libs que tiveram breaking changes recentes (Next.js, React, etc.) |
| `code-review` | `code-review@claude-plugins-official` | Revisão estruturada de PRs: segurança, performance, legibilidade, testes | Antes de mergear uma PR, via `/code-review` |
| `frontend-design` | `frontend-design@claude-plugins-official` | Gera interfaces frontend de alta qualidade, evitando a estética genérica de código gerado por IA | Ao criar componentes de UI |
| `github` | `github@claude-plugins-official` | Ensina fluxos de trabalho estruturados sobre PRs, issues e branches | Em qualquer workflow que envolva o GitHub MCP server |
| `feature-dev` | `feature-dev@claude-plugins-official` | Guia desenvolvimento de features com exploração de codebase e desenho de arquitetura antes de implementar | Ao iniciar uma feature com escopo não trivial |
| `code-simplifier` | `code-simplifier@claude-plugins-official` | Revisa código recém-escrito buscando duplicação, abstração prematura e complexidade acidental | Após implementar, antes de commitar — via `/simplify` |
| `serena` | `serena@claude-plugins-official` | Instrui o Claude a usar o Serena MCP server de forma eficiente (leitura e edição por símbolo, não por arquivo inteiro) | Sempre ativo quando o Serena MCP server está configurado |
| `claude-md-management` | `claude-md-management@claude-plugins-official` | Audita e atualiza arquivos `CLAUDE.md` com os aprendizados da sessão | Ao revisar ou melhorar a memória de longo prazo de um projeto |
| `claude-code-setup` | `claude-code-setup@claude-plugins-official` | Analisa um codebase e recomenda hooks, agentes, skills e MCP servers adequados | Ao configurar o Claude Code num projeto novo |
| `caveman` | `caveman@caveman` | Modo de comunicação ultra-comprimido para economizar tokens em sessões longas | Quando o custo de tokens importa mais que a verbosidade das respostas |

Note que `explanatory-output-style` e `caveman` vêm de marketplaces diferentes de
`claude-plugins-official` — a marketplace `caveman` é declarada à parte em
`extraKnownMarketplaces` (veja [`settings.md`](settings.md#extraknownmarketplaces)).

## Instalação

Duas formas equivalentes:

**Via `settings.json`** (o que o template deste repositório usa) — cada plugin vira
uma chave em `enabledPlugins`:

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "caveman@caveman": true
  }
}
```

Um plugin fora do marketplace oficial (como `caveman`) precisa também de uma entrada
em `extraKnownMarketplaces` apontando para a fonte (repositório GitHub, por exemplo).

**Via Command Palette**, dentro do editor: `Cmd+Shift+P` / `Ctrl+Shift+P` →
"Claude: Install Plugin" → digite o identificador completo do plugin.

## Plugin ou MCP server?

Plugin muda **comportamento** (como o Claude pensa e age); MCP server adiciona
**ferramentas** (acesso a sistemas e dados externos). Os dois são independentes e
frequentemente se complementam — por exemplo, o plugin `github` ensina fluxos de
trabalho estruturados sobre as ferramentas que o MCP server `github` disponibiliza.

Ver a explicação completa em [`docs/concepts/mcp-vs-plugin.md`](../concepts/mcp-vs-plugin.md).
