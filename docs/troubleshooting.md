# Troubleshooting

Sintomas comuns ao instalar, sincronizar ou usar esta configuração, com causa
e correção. Se o seu problema não está aqui, veja
[`CONTRIBUTING.md`](../CONTRIBUTING.md) para abrir uma mudança que documenta o
caso.

## MCP server não aparece

**Sintoma:** ferramentas de um MCP server não estão disponíveis na conversa.

**Causa:** o server não está em `mcpServers` (arquivo `~/.claude.json`), o
processo do server falhou ao iniciar, ou o Node.js necessário não está
instalado.

**Correção:**
1. Verifique se Node.js está instalado: `node --version`.
2. Reinicie o Claude Code completamente.
3. Command Palette → "Claude: Show Logs" e procure erros relacionados a MCP.
4. Confirme se os tokens/keys de que o server depende estão definidos
   (variáveis de ambiente — veja [03 — MCP Servers](setup/03-mcp-servers.md)).
5. Teste o server manualmente, por exemplo `npx -y
   @modelcontextprotocol/server-memory`.

## Plugin não carrega

**Sintoma:** um plugin instalado não aparece ou não funciona.

**Causa:** cache de plugins corrompido, ou o plugin não está de fato
habilitado em `settings.json`.

**Correção:**
1. Confirme o conteúdo de `~/.claude/settings.json` (chave `enabledPlugins`).
2. Reinstale o plugin: Command Palette → "Claude: Uninstall Plugin", depois
   "Claude: Install Plugin".
3. Limpe o cache: `rm -rf ~/.claude/plugins/cache`.
4. Reinicie o Claude Code.

## `CLAUDE.md` não é aplicado

**Sintoma:** o Claude não segue as instruções do `CLAUDE.md`.

**Causa:** o arquivo não está no local esperado, ou a conversa atual foi
aberta antes da instalação/edição do arquivo (instruções carregam no início
da conversa).

**Correção:**
1. Confirme que o arquivo existe em `~/.claude/CLAUDE.md`.
2. Confira o conteúdo com `cat ~/.claude/CLAUDE.md`.
3. Inicie uma **nova conversa** — instruções globais são carregadas apenas no
   começo.
4. Teste pedindo explicitamente para o Claude seguir as diretrizes.

## Erro de permissão no macOS

**Sintoma:** "Operation not permitted" ao usar o MCP filesystem ou ao rodar
`scripts/install.sh` / `scripts/sync.sh`.

**Causa:** macOS restringe acesso a pastas do usuário por padrão (Privacy &
Security); o terminal ou o editor não têm a permissão concedida.

**Correção:**
1. Vá em System Settings → Privacy & Security → Full Disk Access.
2. Adicione o Terminal (ou o app usado para rodar o Claude Code).
3. Reinicie a aplicação depois de conceder a permissão.

## Token do GitHub inválido

**Sintoma:** o MCP server do GitHub retorna erro de autenticação.

**Causa:** token expirado, revogado, ou sem os scopes necessários.

**Correção:**
1. Verifique se o token tem os scopes corretos (`repo`, no mínimo, para a
   maioria dos usos).
2. Gere um novo token se necessário e atualize a variável de ambiente
   `GITHUB_PERSONAL_ACCESS_TOKEN`.
3. Teste o token diretamente: `curl -H "Authorization: token SEU_TOKEN"
   https://api.github.com/user`.

## `install.sh` falha com `jq: command not found`

**Sintoma:** `scripts/install.sh` para logo no início com erro de `jq`.

**Causa:** `install.sh` usa `jq` para fazer o merge de `settings.json` e de
`mcpServers` campo a campo, e falha rápido (`set -euo pipefail`) se a
ferramenta não está disponível — instalar sem `jq` correria o risco de
sobrescrever customizações do usuário.

**Correção:**
```bash
# macOS
brew install jq

# Debian/Ubuntu
sudo apt-get install jq
```
Depois rode `scripts/install.sh` de novo — o script é idempotente.

## `install.sh` reporta conflito de campo em `settings.json`

**Sintoma:** depois de rodar `scripts/install.sh`, algum campo de
`settings.json` ficou com um valor inesperado, misturando o template do
repositório com a customização local.

**Causa:** o merge é recursivo campo a campo (`jq -s '.[0] * .[1]'`, template
primeiro, valor do usuário depois) — o valor do usuário sempre vence em caso
de colisão direta. Quando o campo local tem um formato diferente do
template (por exemplo, um array onde o template espera um objeto), o
resultado do merge pode não ser o que se espera.

**Correção:**
1. `install.sh` sempre faz backup antes de escrever:
   `~/.claude/settings.json.bak.<timestamp>`. Compare o backup com o
   resultado.
2. Ajuste manualmente o campo divergente em `~/.claude/settings.json`.
3. Se o conflito é recorrente, é sinal de que o template do repositório
   precisa ser atualizado — abra uma mudança seguindo
   [`CONTRIBUTING.md`](../CONTRIBUTING.md).

## `sync.sh` aborta com padrão proibido encontrado

**Sintoma:** `scripts/sync.sh` (ou `make sync`) para com a mensagem
`ABORTADO: padrao proibido encontrado na area de preparacao.` e nada é
escrito no repositório.

**Causa:** por design (decisão D5), `sync.sh` roda `scan_secrets` sobre a
área de preparação (staging) antes de copiar qualquer coisa para o
repositório. Se algum arquivo local — configuração, skill, agente, command —
contém um padrão listado em `scripts/lib/patterns.txt` (token, segredo,
caminho absoluto, nome interno de cliente/empresa), o sync é interrompido.
Isso é intencional: o repositório é público/compartilhado, e a área de
preparação nunca deveria expor esse conteúdo.

**Correção:**
1. Leia a saída do comando — `scan_secrets` imprime o arquivo e a linha do
   match.
2. Corrija a origem em `~/.claude/` (remova o segredo, generalize o nome
   interno, mova o caminho absoluto para variável de ambiente).
3. Rode `make sync` de novo.

## `make sync` aborta mesmo sem eu ter mexido em segredo

**Sintoma:** `make sync` aborta com padrão proibido encontrado, mas você não
alterou nada relacionado a credenciais — só editou um skill ou command.

**Causa:** artefatos de prosa (skills, agents, commands) são copiados
"crus" para a área de preparação e verificados como qualquer outro arquivo.
É comum um artefato antigo — por exemplo `~/.claude/agents/pr-reviewer.md`
ou `~/.claude/commands/review.md` — ainda conter, em algum exemplo ou
comentário, um nome interno de cliente/empresa que ficou proibido pela
denylist de padrões depois que o artefato foi escrito.

**Correção:**
1. Localize a ocorrência na saída de `scan_secrets` (arquivo e linha).
2. Edite o artefato local em `~/.claude/` para remover ou generalizar o
   nome (ex.: trocar o nome real por "o cliente" ou por um nome fictício).
3. Rode `make sync` novamente — a verificação roda antes de qualquer
   escrita, então nada precisa ser desfeito no repositório.

## CI falha no job `secrets` — o que fazer quando o segredo já foi commitado

**Sintoma:** o job `secrets` do CI (gitleaks + varredura de padrões
proibidos) falha em um push ou pull request.

**Causa:** um segredo, token ou padrão proibido chegou a ser commitado —
`sync.sh` só protege o caminho local → repositório; um commit manual ou um
merge de branch antiga pode ter introduzido o padrão diretamente.

**Correção:**
1. **Não** tente só remover a linha em um novo commit — o segredo continua
   no histórico do git e permanece exposto para qualquer clone.
2. Revogue o segredo imediatamente na origem (token do GitHub, chave de API
   etc.) — trate como comprometido, mesmo que o repositório seja privado.
3. Remova o segredo do histórico (`git filter-repo` ou ferramenta
   equivalente) antes de considerar o incidente encerrado.
4. Depois de limpo, confirme que `make check` passa localmente antes de
   subir de novo.
