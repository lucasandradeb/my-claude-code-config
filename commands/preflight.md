---
description: Verifica autenticação e disponibilidade dos MCPs antes de começar sessão com ferramentas externas
allowed-tools: mcp__github__list_issues, mcp__claude_ai_Atlassian_Rovo__atlassianUserInfo, mcp__claude_ai_Slack__authenticate, mcp__plugin_serena_serena__check_onboarding_performed
---

# Preflight — Verificação de MCPs

Rode um teste simples em cada MCP que a sessão vai precisar e reporte o status.

## Verificações

1. **GitHub** → liste 1 issue de qualquer repo público (valida autenticação do GitHub MCP)
2. **Atlassian/Jira** → chame `atlassianUserInfo` (valida acesso ao Rovo/Jira)
3. **Serena** → chame `check_onboarding_performed` (valida que o LSP está ativo)
4. **Slack** → tente autenticar (valida token Slack se MCP estiver configurado)

## Formato de saída

Reporte em tabela:

| MCP | Status | Detalhe |
|-----|--------|---------|
| GitHub | OK / FALHOU | mensagem de erro se houver |
| Atlassian/Jira | OK / FALHOU | mensagem de erro se houver |
| Serena (LSP) | OK / FALHOU | mensagem de erro se houver |
| Slack | OK / FALHOU / NÃO CONFIGURADO | — |

Se qualquer um falhar, avise imediatamente antes de continuar. Não prossiga em trabalho que dependa de um MCP com falha — o usuário precisa renovar o token primeiro.

## Quando usar

No início de sessões que vão:
- Criar ou comentar issues/PRs no GitHub
- Consultar ou atualizar tickets no Jira
- Navegar código com análise semântica (Serena)
- Buscar mensagens no Slack
