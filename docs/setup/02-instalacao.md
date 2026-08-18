# 02 — Instalação

> Tempo estimado: 5 min

## Passo 1: Clonar o repositório

```bash
git clone <url-deste-repositorio>
cd my-claude-code-config
```

## Passo 2: Rodar o instalador

O instalador copia os artefatos deste repositório para `~/.claude/` e faz merge
de configurações — nunca sobrescreve o que você já tem (seu `settings.json`
existente vira `settings.json.bak.<timestamp>` antes do merge, e seus valores
vencem em caso de conflito).

**macOS / Linux:**

```bash
./scripts/install.sh
```

**Windows (PowerShell):**

```powershell
.\scripts\install.ps1
```

## Passo 3: Ler o relatório de saída

O instalador imprime uma linha por artefato copiado ou mesclado:

```
  backup    settings.json                      -> settings.json.bak.20260818120000
  merge     settings.json                      customizacoes preservadas
  merge     mcpServers (11)
  copiar    CLAUDE.md
  copiar    RTK.md
  copiar    hooks/prettier-hook.py
  copiar    skills/...
  copiar    agents/pr-reviewer.md
  copiar    commands/preflight.md

  ACAO MANUAL:
    - GITHUB_PERSONAL_ACCESS_TOKEN nao definido
    - BRAVE_API_KEY nao definido
    ver docs/setup/03-mcp-servers.md

  Proximo passo: abra o Claude Code e rode /preflight
```

Confira duas coisas nesse relatório:

- **`merge` em `settings.json`** — confirma que suas customizações locais (se
  já usava Claude Code antes) foram preservadas.
- **`ACAO MANUAL`** — lista o que falta configurar manualmente. Se aparecer,
  siga para a próxima etapa antes de continuar.

## Sobre o hook `PreToolUse` e o RTK

O `settings.json` instalado registra um hook `PreToolUse` que roda `rtk hook
claude` antes de cada comando Bash — ele reescreve comandos comuns para versões
que consomem menos tokens (`git status` vira `rtk git status`, por exemplo),
com economia relatada de 60-90% nessas operações. Esse hook depende do binário
`rtk` estar disponível no seu `PATH`.

Confirme que está instalado:

```bash
rtk --version
```

Se o comando falhar, todo uso de Bash pelo Claude vai falhar até você instalar o
`rtk` — veja [`config/RTK.md`](../../config/RTK.md) para os comandos de
verificação e o que fazer em caso de colisão de nome com outro binário `rtk`.
Mais contexto sobre por que essa economia importa está em
[`docs/concepts/economia-de-tokens.md`](../concepts/economia-de-tokens.md).

---

**Próximo:** [MCP Servers](03-mcp-servers.md)
