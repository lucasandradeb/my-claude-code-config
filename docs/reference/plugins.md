# Plugins

Plugins modificam **como o Claude pensa e age**: adicionam skills, comportamentos e
fluxos de trabalho especializados. Isso é diferente de um MCP server, que adiciona
**ferramentas** (acesso a sistemas externos) sem mudar o comportamento do Claude —
veja [Plugin ou MCP server?](#plugin-ou-mcp-server) abaixo.

Esta é a fonte única da lista de plugins do repositório. Ela existia duplicada em
três arquivos (`README.md`, `GUIA_CONFIGURACAO_TIME.md`, `EXEMPLO_CONFIGURACAO.md`)
e as três cópias já haviam divergido entre si. A tabela abaixo reflete exatamente o
que `config/settings.template.json` habilita em `enabledPlugins`.

## Os 16 plugins (10 habilitados, 6 desabilitados)

O template tem 16 entradas em `enabledPlugins`. As desabilitadas ficam registradas
com `false` de propósito: o instalador não as reativa e quem lê o arquivo vê que a
ausência foi uma decisão, não um esquecimento.

### Habilitados

| Plugin | Identificador | Para que serve | Quando usar |
|---|---|---|---|
| `superpowers` | `superpowers@claude-plugins-official` | Framework central de skills de fluxo de trabalho: brainstorm, planejamento, TDD, debugging sistemático, verificação antes de concluir, dispatch de subagentes | Sempre ativo — estrutura qualquer tarefa de desenvolvimento não trivial |
| `context7` | `context7@claude-plugins-official` | Busca documentação atualizada de bibliotecas e frameworks direto na conversa | Ao trabalhar com libs que tiveram breaking changes recentes (Next.js, React, etc.) |
| `code-review` | `code-review@claude-plugins-official` | Revisão estruturada de PRs: segurança, performance, legibilidade, testes | Antes de mergear uma PR, via `/code-review` |
| `frontend-design` | `frontend-design@claude-plugins-official` | Gera interfaces frontend de alta qualidade, evitando a estética genérica de código gerado por IA | Ao criar componentes de UI |
| `github` | `github@claude-plugins-official` | Ensina fluxos de trabalho estruturados sobre PRs, issues e branches | Em qualquer workflow que envolva o GitHub MCP server |
| `serena` | `serena@claude-plugins-official` | Instrui o Claude a usar o Serena de forma eficiente (leitura e edição por símbolo, não por arquivo inteiro) | Opcional: sem o Serena MCP server o plugin tem pouco efeito (veja [`mcp-servers.md`](mcp-servers.md#como-readicionar-um-server)) |
| `claude-md-management` | `claude-md-management@claude-plugins-official` | Audita e atualiza arquivos `CLAUDE.md` com os aprendizados da sessão | Ao revisar ou melhorar a memória de longo prazo de um projeto |
| `caveman` | `caveman@caveman` | Modo de comunicação ultra-comprimido para economizar tokens de saída em sessões longas | Quando o custo de tokens importa mais que a verbosidade das respostas |
| `clangd-lsp` | `clangd-lsp@claude-plugins-official` | LSP de C/C++ (clangd): diagnósticos e navegação de código | Opcional — só para quem mexe com C/C++; desabilite se não for o seu caso |
| `vercel` | `vercel@claude-plugins-official` | Skills e integração com a plataforma Vercel (deploy, env, Next.js e afins) | Opcional e pesado (traz muitas skills); desabilite se você não usa Vercel |

### Desabilitados

| Plugin | Identificador | Motivo |
|---|---|---|
| `explanatory-output-style` | `explanatory-output-style@claude-code-plugins` | Conflita com o `caveman` e com o `CLAUDE.md`, e aumenta os tokens de saída (que custam cerca de 5x os de entrada). Um único estilo de saída por vez |
| `feature-dev` | `feature-dev@claude-plugins-official` | Zero uso medido em 30 dias |
| `code-simplifier` | `code-simplifier@claude-plugins-official` | Zero uso medido em 30 dias |
| `claude-code-setup` | `claude-code-setup@claude-plugins-official` | Zero uso medido em 30 dias; só serve ao configurar um projeto novo |
| `code-review` (cópia) | `code-review@claude-code-plugins` | Duplicata de `code-review@claude-plugins-official`: carregava as mesmas skills duas vezes |
| `frontend-design` (cópia) | `frontend-design@claude-code-plugins` | Duplicata de `frontend-design@claude-plugins-official`: carregava as mesmas skills duas vezes |

Para reativar qualquer um, troque `false` por `true` na entrada correspondente de
`enabledPlugins`.

Note que `caveman` vem de uma marketplace diferente de `claude-plugins-official` — a
marketplace `caveman` é declarada à parte em `extraKnownMarketplaces` (veja
[`settings.md`](settings.md#extraknownmarketplaces)).

## Instalação

Duas formas equivalentes:

**Via `settings.json`** (o que o template deste repositório usa) — cada plugin vira
uma chave em `enabledPlugins` (`true` habilita, `false` desabilita de forma explícita):

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
