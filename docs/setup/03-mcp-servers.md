# 03 — MCP Servers

> Tempo estimado: 10 min

**Esta é a única etapa manual de toda a trilha.** O instalador copia e mescla
tudo o que dá para automatizar; credenciais, por definição, não — ninguém além
de você deve gerar seu token do GitHub ou sua chave da Brave.

Para o catálogo completo dos 11 servers e o que cada um faz, veja
[`docs/reference/mcp-servers.md`](../reference/mcp-servers.md). Esta página cobre
só o que exige ação sua.

## O que precisa de credencial

Dos 11 servers, dois pedem uma credencial:

| Server | Variável de ambiente | Obrigatório? |
|---|---|---|
| `github` | `GITHUB_PERSONAL_ACCESS_TOKEN` | Sim — sem ele, o MCP `github` não sobe |
| `brave-search` | `BRAVE_API_KEY` | Opcional — remova a seção `brave-search` do seu `mcpServers` se não quiser configurar |

## Obtendo o Personal Access Token do GitHub

1. Acesse https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Dê um nome descritivo (ex: "Claude Code MCP")
4. Selecione os scopes:
   - `repo` (acesso completo a repositórios)
   - `read:org` (ler informações da organização)
   - `user` (ler informações do usuário)
5. Clique em "Generate token"
6. **Copie o token imediatamente** — você não verá de novo
7. Adicione-o à configuração (veja abaixo onde colocar)

## Obtendo a chave da Brave Search API

1. Acesse https://brave.com/search/api/
2. Crie uma conta ou faça login
3. Siga o processo de obtenção de API key
4. Copie a chave

## Onde colocar cada credencial

O arquivo mesclado pelo instalador é `~/.claude.json`, na chave `mcpServers`.
Edite a seção do server correspondente e substitua o valor vazio:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "cole-seu-token-aqui"
      }
    },
    "brave-search": {
      "env": {
        "BRAVE_API_KEY": "cole-sua-chave-aqui"
      }
    }
  }
}
```

**Nunca commite esse arquivo com credenciais preenchidas** — ele é local, fora do
repositório versionado.

## Apontando `$WORKSPACE_DIR`

Quatro servers (`filesystem`, `git`, `sqlite`, `serena`) recebem um diretório de
trabalho como argumento. O template traz o placeholder `$WORKSPACE_DIR` — troque
pelo caminho absoluto do projeto que você vai abrir com o Claude Code:

```json
{
  "mcpServers": {
    "filesystem": {
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/caminho/para/seu/projeto"]
    }
  }
}
```

Se você trabalha em múltiplos projetos, repita a instalação (ou ajuste
manualmente) apontando para cada um — o valor não é compartilhado
automaticamente entre projetos.

## Confirmar que funcionou

Reinicie o VSCode e, numa conversa nova, peça:

```
Liste todos os MCP servers disponíveis e suas ferramentas
```

Você deve ver `github` e `brave-search` na lista, sem erro de autenticação. A
verificação completa de todos os 11 servers acontece na etapa final desta
trilha, com `/preflight`.

---

**Próximo:** [Plugins](04-plugins.md)
