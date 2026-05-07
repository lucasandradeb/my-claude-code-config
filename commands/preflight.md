---
description: Verifica autenticação e disponibilidade dos MCPs antes de começar uma sessão com ferramentas externas
allowed-tools: mcp__github__list_issues, mcp__claude_ai_Atlassian_Rovo__atlassianUserInfo, mcp__plugin_serena_serena__check_onboarding_performed
---

# Preflight — Verificação de MCPs

Antes de iniciar uma sessão que depende de ferramentas externas, rode este preflight para confirmar que tudo está autenticado e operacional.

## O que este command faz

Testa cada MCP com uma chamada simples e reporta o status em tabela. Se qualquer ferramenta falhar, você é avisado antes de desperdiçar tempo em uma sessão que vai travar no meio.

## Verificações

1. **GitHub** → lista 1 issue de qualquer repo (valida autenticação)
2. **Atlassian/Jira** → chama `atlassianUserInfo` (valida acesso ao Rovo)
3. **Serena (LSP)** → chama `check_onboarding_performed` (valida que o language server está ativo)

Adapte esta lista conforme os MCPs que você usa no seu setup.

## Formato de saída

| MCP | Status | Detalhe |
|-----|--------|---------|
| GitHub | OK / FALHOU | mensagem de erro se houver |
| Atlassian/Jira | OK / FALHOU | mensagem de erro se houver |
| Serena (LSP) | OK / FALHOU | mensagem de erro se houver |

Se qualquer um falhar, **não prossiga** com o trabalho — renove o token ou corrija a configuração primeiro.

## Quando usar

No início de sessões que vão:
- Criar ou comentar issues/PRs no GitHub
- Consultar ou atualizar tickets no Jira/Linear
- Navegar código com análise semântica (Serena/LSP)

**Como ativar:** escreva `/preflight` no chat do Claude Code.
