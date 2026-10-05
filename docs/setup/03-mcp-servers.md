# 03 — MCP Servers

> Tempo estimado: 5 min

**Esta é a única etapa manual de toda a trilha.** O instalador copia e mescla
tudo o que dá para automatizar; credenciais, por definição, não — ninguém além
de você deve gerar seu token do GitHub.

O template traz **um** MCP server, o `github`. Os outros dez que existiam antes
foram removidos porque cada MCP custa tokens de contexto em toda sessão (nomes de
ferramentas e instruções do server) e esses não tinham uso medido ou duplicavam
ferramentas nativas do Claude Code. O catálogo e o motivo de cada remoção estão em
[`docs/reference/mcp-servers.md`](../reference/mcp-servers.md). Esta página cobre
só o que exige ação sua.

## O que precisa de credencial

| Server | Variável de ambiente | Obrigatório? |
|---|---|---|
| `github` | `GITHUB_PERSONAL_ACCESS_TOKEN` | Sim — sem ele, o MCP `github` não sobe |

É a única variável que o instalador checa.

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

## Onde colocar a credencial

O arquivo mesclado pelo instalador é `~/.claude.json`, na chave `mcpServers`.
Edite a seção do server e substitua o valor vazio:

```json
{
  "mcpServers": {
    "github": {
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "cole-seu-token-aqui"
      }
    }
  }
}
```

**Nunca commite esse arquivo com credenciais preenchidas** — ele é local, fora do
repositório versionado.

## Confirmar que funcionou

Reinicie o VSCode e, numa conversa nova, peça:

```
Liste todos os MCP servers disponíveis e suas ferramentas
```

Você deve ver `github` na lista, sem erro de autenticação. A verificação final
acontece na etapa 08, com `/preflight`.

## Quer outro server?

Adicione só o que você vai usar de fato — veja
[como readicionar um server](../reference/mcp-servers.md#como-readicionar-um-server).

---

**Próximo:** [Plugins](04-plugins.md)
