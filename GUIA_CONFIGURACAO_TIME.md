# Guia de Configuração Claude Code para o Time

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Instalação Claude Code](#instalação-claude-code)
3. [Configuração de MCP Servers](#configuração-de-mcp-servers)
4. [Configuração de Plugins](#configuração-de-plugins)
5. [Arquivo CLAUDE.md Global](#arquivo-claudemd-global)
6. [Verificação da Instalação](#verificação-da-instalação)
7. [Troubleshooting](#troubleshooting)

---

## Nota sobre Caminhos (Importante!)

Este guia contém comandos e caminhos que variam por sistema operacional. Procure sempre pela seção correspondente ao seu sistema:

| Item | Linux | macOS | Windows |
|------|-------|-------|---------|
| **Diretório Claude** | `~/.claude/` | `~/.claude/` | `%USERPROFILE%\.claude\` |
| **Home directory** | `/home/usuario` | `/Users/usuario` | `C:\Users\Usuario` |
| **Shell padrão** | Bash | Bash/Zsh | PowerShell/CMD |

**Convenções neste documento:**
- Comandos marcados com **Linux/Mac** funcionam em ambos sistemas Unix
- Comandos marcados com **Windows** são para PowerShell (recomendado)
- Alguns comandos git, node e npm funcionam em todas as plataformas

**Importante para Windows:**
- Use `\` (barra invertida) em paths PowerShell
- Use barras duplas `\\` em JSON strings: `"C:\\Users\\Nome"`
- PowerShell: use `$env:USERPROFILE` para home directory
- CMD: use `%USERPROFILE%` para home directory

---

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Node.js** versão 18 ou superior
- **VSCode** atualizado
- **Git** configurado
- Conta **Anthropic/Claude** ativa

Verificar versões:
```bash
node --version  # Deve ser >= 18
code --version  # VSCode instalado
git --version   # Git instalado
```

---

## Instalação Claude Code

### Passo 1: Instalar a Extensão no VSCode

1. Abra o VSCode
2. Vá para Extensions (Cmd+Shift+X no Mac, Ctrl+Shift+X no Windows/Linux)
3. Busque por "Claude Code"
4. Clique em "Install" na extensão oficial da Anthropic
5. Reinicie o VSCode se solicitado

### Passo 2: Autenticação

1. Após instalar, clique no ícone do Claude na sidebar
2. Faça login com sua conta Anthropic
3. Autorize a extensão

---

## Configuração de MCP Servers

MCP (Model Context Protocol) Servers são plugins que expandem as capacidades do Claude Code. Os servers configurados neste guia são:

### Servers Recomendados

1. **filesystem** - Manipulação avançada de arquivos
2. **github** - Integração completa com GitHub
3. **memory** - Sistema de memória persistente
4. **brave-search** - Busca na web
5. **serena** - Análise semântica de código (o mais poderoso!)
6. **docker** - Gerenciamento de containers

### Instalação dos MCP Servers

#### Opção A: Configuração via VSCode Settings (Recomendado)

1. Abra VSCode Settings (Cmd+, ou Ctrl+,)
2. Busque por "Claude MCP"
3. Clique em "Edit in settings.json"
4. Adicione a seguinte configuração:

```json
{
  "claude.mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/Users/SEU_USUARIO"  // Mac/Linux: /Users/seuusuario ou /home/seuusuario
                              // Windows: C:\\Users\\SeuUsuario
      ],
      "env": {}
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "SEU_TOKEN_AQUI"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "SUA_CHAVE_AQUI"
      }
    },
    "docker": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-docker"]
    }
  }
}
```

**IMPORTANTE:** Substitua os valores conforme seu sistema:

**Diretório Home (filesystem server):**
- **Linux:** `/home/seuusuario` (ex: `/home/joao`)
- **Mac:** `/Users/seuusuario` (ex: `/Users/joao`)
- **Windows:** `C:\\Users\\SeuUsuario` (ex: `C:\\Users\\Joao`) - **note as barras duplas!**

**Tokens:**
- `SEU_TOKEN_AQUI` → Personal Access Token do GitHub
- `SUA_CHAVE_AQUI` → API key do Brave Search

#### Opção B: Configuração via Claude Desktop App

Se você usa o Claude Desktop App, edite o arquivo:
- **Mac**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **Linux**: `~/.config/Claude/claude_desktop_config.json`

Use a mesma estrutura JSON da Opção A.

### Obtendo Tokens e API Keys

#### GitHub Personal Access Token

1. Acesse: https://github.com/settings/tokens
2. Clique em "Generate new token (classic)"
3. Dê um nome descritivo (ex: "Claude Code MCP")
4. Selecione os scopes:
   - `repo` (acesso completo a repositórios)
   - `read:org` (ler informações da organização)
   - `user` (ler informações do usuário)
5. Clique em "Generate token"
6. **COPIE O TOKEN IMEDIATAMENTE** (você não verá novamente)
7. Adicione ao arquivo de configuração

#### Brave Search API Key

1. Acesse: https://brave.com/search/api/
2. Crie uma conta ou faça login
3. Siga o processo de obtenção de API key
4. Copie a chave e adicione à configuração

**Nota sobre Brave Search:** Este é opcional. Se não quiser configurar, remova a seção do brave-search da configuração.

---

## Configuração de Plugins

Os plugins adicionam skills, comportamentos e fluxos de trabalho especializados ao Claude Code.

### Plugins do Time

| Plugin | Identificador | Prioridade |
|--------|--------------|------------|
| superpowers | `superpowers@claude-plugins-official` | Essencial |
| explanatory-output-style | `explanatory-output-style@claude-code-plugins` | Essencial |
| serena | `serena@claude-plugins-official` | Essencial |
| context7 | `context7@claude-plugins-official` | Alta |
| code-review | `code-review@claude-plugins-official` | Alta |
| frontend-design | `frontend-design@claude-plugins-official` | Alta |
| feature-dev | `feature-dev@claude-plugins-official` | Alta |
| github | `github@claude-plugins-official` | Alta |
| code-simplifier | `code-simplifier@claude-plugins-official` | Média |
| claude-md-management | `claude-md-management@claude-plugins-official` | Média |
| claude-code-setup | `claude-code-setup@claude-plugins-official` | Média |

### Instalação dos Plugins

#### Via Command Palette (Recomendado)

1. Abra o Command Palette (Cmd+Shift+P ou Ctrl+Shift+P)
2. Digite "Claude: Install Plugin"
3. Instale cada plugin pelo seu identificador completo
4. Aguarde a instalação de cada um

#### Via Arquivo de Configuração

Edite o arquivo de configuração do Claude:
- **Linux/Mac:** `~/.claude/settings.json`
- **Windows:** `%USERPROFILE%\.claude\settings.json` (ou `C:\Users\SeuUsuario\.claude\settings.json`)

```json
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "explanatory-output-style@claude-code-plugins": true,
    "context7@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "github@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "code-simplifier@claude-plugins-official": true,
    "serena@claude-plugins-official": true,
    "claude-md-management@claude-plugins-official": true,
    "claude-code-setup@claude-plugins-official": true
  }
}
```

### Descrição dos Plugins

**superpowers** (essencial)
- Framework central de produtividade — orienta todos os fluxos de trabalho
- Skills: `/brainstorm`, `/writing-plans`, `/executing-plans`, `/systematic-debugging`, `/test-driven-development`, `/verification-before-completion`
- Sem este plugin, o Claude trabalha sem estrutura disciplinada

**explanatory-output-style** (essencial)
- Ativa modo educacional com insights técnicos automáticos
- Explica decisões técnicas, trade-offs e contexto arquitetural

**serena** (essencial)
- Instrui o Claude a usar o Serena MCP Server de forma eficiente
- Leitura incremental de código por símbolos (evita ler arquivos inteiros)
- Complementa o Serena MCP Server com comportamentos específicos

**context7**
- Conecta o Claude a documentação atualizada de bibliotecas
- Supera o knowledge cutoff para libs em evolução rápida (Next.js, React, etc.)

**code-review**
- Análise estruturada de pull requests por categorias
- Comando: `/review-pr` ou `/code-review`
- Verifica segurança, performance, legibilidade e testes

**frontend-design**
- Especializado em criar interfaces frontend de alta qualidade
- Evita estética genérica de código gerado por IA
- Comando: `/frontend-design`

**feature-dev**
- Guia o desenvolvimento de features com análise de codebase antes de implementar
- Skills: `/feature-dev`, subagentes `code-explorer`, `code-architect`, `code-reviewer`

**github**
- Workflows estruturados para PRs, issues e branches
- Complementa o GitHub MCP Server com fluxos de trabalho inteligentes

**code-simplifier**
- Revisa código recém-escrito para clareza e manutenibilidade
- Comando: `/simplify` — usar após implementar, antes de commitar

**claude-md-management**
- Gerencia arquivos CLAUDE.md: audita qualidade e mantém instruções atualizadas
- Comandos: `/revise-claude-md`, `/claude-md-improver`

**claude-code-setup**
- Analisa codebase e recomenda automações do Claude Code
- Comando: `/claude-automation-recommender` — usar ao iniciar em novo projeto

---

## Arquivo CLAUDE.md Global

O arquivo CLAUDE.md contém instruções persistentes que o Claude seguirá em todos os projetos.

### Instalação

1. Copie o arquivo `CLAUDE.md` deste repositório
2. Coloque no diretório de configuração do Claude:
   - **Linux/Mac:** `~/.claude/CLAUDE.md`
   - **Windows:** `%USERPROFILE%\.claude\CLAUDE.md`

Ou crie manualmente:

```bash
# Mac/Linux
touch ~/.claude/CLAUDE.md
open ~/.claude/CLAUDE.md  # Mac
nano ~/.claude/CLAUDE.md  # Linux

# Windows (PowerShell)
New-Item -Path "$env:USERPROFILE\.claude\CLAUDE.md" -ItemType File
notepad "$env:USERPROFILE\.claude\CLAUDE.md"
```

3. Cole o conteúdo do arquivo CLAUDE.md fornecido

### Como Funciona

O Claude Code carrega automaticamente este arquivo e aplica as instruções a todas as conversas. Isso garante:

- Estilo de código consistente
- Padrões arquiteturais unificados
- Práticas de segurança aplicadas
- Documentação adequada

---

## Verificação da Instalação

### Verificar MCP Servers

1. Abra o VSCode com a extensão Claude Code
2. Abra uma conversa com o Claude
3. Digite:

```
Liste todos os MCP servers disponíveis e suas ferramentas
```

Você deve ver os servers configurados e suas ferramentas.

### Verificar Plugins

1. No VSCode, abra o Command Palette
2. Digite "Claude: List Installed Plugins"
3. Verifique se os 11 plugins estão listados e habilitados

### Verificar CLAUDE.md

1. Inicie uma conversa nova com o Claude
2. Pergunte:

```
Quais são suas diretrizes de desenvolvimento para TypeScript e React?
```

O Claude deve responder seguindo o formato e conteúdo do CLAUDE.md.

### Teste Completo

Execute este teste:

```
Crie um componente React em TypeScript que exiba uma lista de usuários.
Use as melhores práticas e explique suas decisões.
```

O Claude deve:
- Criar código TypeScript com tipos explícitos
- Seguir os padrões definidos no CLAUDE.md
- Fornecer insights educacionais (se explanatory-output-style estiver ativo)
- Não usar emojis

---

## Troubleshooting

### MCP Servers não aparecem

**Problema:** Ferramentas de MCP servers não estão disponíveis.

**Soluções:**
1. Verifique se Node.js está instalado: `node --version`
2. Reinicie o VSCode completamente
3. Verifique os logs:
   - Command Palette → "Claude: Show Logs"
   - Procure por erros relacionados a MCP
4. Verifique se os tokens/keys estão corretos
5. Teste manualmente um server:
   ```bash
   npx -y @modelcontextprotocol/server-memory
   ```

### Plugins não carregam

**Problema:** Plugins instalados não funcionam.

**Soluções:**
1. Verifique o arquivo de configuração:
   - **Linux/Mac:** `~/.claude/settings.json`
   - **Windows:** `%USERPROFILE%\.claude\settings.json`
2. Reinstale os plugins:
   - Command Palette → "Claude: Uninstall Plugin"
   - Command Palette → "Claude: Install Plugin"
3. Limpe o cache:
   **Linux/Mac:**
   ```bash
   rm -rf ~/.claude/plugins/cache
   ```
   **Windows (PowerShell):**
   ```powershell
   Remove-Item -Recurse -Force $env:USERPROFILE\.claude\plugins\cache
   ```
4. Reinicie o VSCode

### CLAUDE.md não é aplicado

**Problema:** Claude não segue as instruções do CLAUDE.md.

**Soluções:**
1. Verifique se o arquivo existe no local correto:
   - **Linux/Mac:** `~/.claude/CLAUDE.md`
   - **Windows:** `%USERPROFILE%\.claude\CLAUDE.md`

2. Verifique o conteúdo:
   **Linux/Mac:**
   ```bash
   cat ~/.claude/CLAUDE.md
   ```
   **Windows (PowerShell):**
   ```powershell
   Get-Content $env:USERPROFILE\.claude\CLAUDE.md
   ```

3. Inicie uma **nova conversa** (instruções são carregadas no início)
4. Teste explicitamente pedindo para seguir as diretrizes

### Erro de permissão (Mac)

**Problema:** "Operation not permitted" ao usar filesystem server.

**Soluções:**
1. Vá para System Preferences → Security & Privacy → Privacy
2. Selecione "Full Disk Access"
3. Adicione o VSCode e o Terminal
4. Reinicie as aplicações

### Token GitHub inválido

**Problema:** MCP Server GitHub retorna erro de autenticação.

**Soluções:**
1. Verifique se o token tem os scopes corretos
2. Gere um novo token se necessário
3. Atualize o token na configuração
4. Teste o token:
   ```bash
   curl -H "Authorization: token SEU_TOKEN" https://api.github.com/user
   ```

### Performance lenta

**Problema:** Claude Code está lento.

**Soluções:**
1. Desabilite MCP servers não utilizados
2. Reduza o número de plugins ativos
3. Limite o filesystem server a diretórios específicos
4. Aumente memória alocada ao VSCode:
   - Settings → "Files: Max Memory for Large File MB"

---

## Configuração para Diferentes Sistemas Operacionais

### macOS

```bash
# Diretórios importantes
~/.claude/                          # Configurações Claude Code
~/Library/Application Support/Claude/  # Claude Desktop App

# Criar estrutura
mkdir -p ~/.claude
touch ~/.claude/CLAUDE.md
touch ~/.claude/settings.json
```

### Windows

```powershell
# Diretórios importantes
$env:USERPROFILE\.claude\           # Configurações Claude Code
$env:APPDATA\Claude\                # Claude Desktop App

# Criar estrutura
New-Item -Path "$env:USERPROFILE\.claude" -ItemType Directory -Force
New-Item -Path "$env:USERPROFILE\.claude\CLAUDE.md" -ItemType File
New-Item -Path "$env:USERPROFILE\.claude\settings.json" -ItemType File
```

### Linux

```bash
# Diretórios importantes
~/.claude/                    # Configurações Claude Code
~/.config/Claude/            # Claude Desktop App

# Criar estrutura
mkdir -p ~/.claude
touch ~/.claude/CLAUDE.md
touch ~/.claude/settings.json
```

---

## Manutenção e Atualizações

### Atualizar MCP Servers

Os servers são instalados via npx com flag `-y`, então sempre usam a versão mais recente. Para forçar atualização:

```bash
npm cache clean --force
```

Depois reinicie o VSCode.

### Atualizar Plugins

1. Command Palette → "Claude: Update All Plugins"
2. Ou manualmente desinstale e reinstale cada plugin

### Atualizar CLAUDE.md

Mantenha o arquivo versionado em um repositório Git interno do time:

**Linux/Mac:**
```bash
# Clone o repositório de configurações do time
git clone https://github.com/seu-time/claude-config.git

# Copie para seu diretório local
cp claude-config/CLAUDE.md ~/.claude/CLAUDE.md

# Para atualizar no futuro
cd claude-config
git pull
cp CLAUDE.md ~/.claude/CLAUDE.md
```

**Windows (PowerShell):**
```powershell
# Clone o repositório de configurações do time
git clone https://github.com/seu-time/claude-config.git

# Copie para seu diretório local
Copy-Item claude-config\CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md

# Para atualizar no futuro
cd claude-config
git pull
Copy-Item CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md
```

---

## Configuração de Time

### Repositório Central de Configurações

Crie um repositório Git com:

```
claude-team-config/
├── README.md
├── CLAUDE.md              # Instruções globais
├── mcp-config.json        # Configuração de MCP servers (sem tokens!)
├── plugins.json           # Lista de plugins recomendados
├── scripts/
│   ├── setup.sh          # Script de setup automático (Mac/Linux)
│   └── setup.ps1         # Script de setup automático (Windows)
└── docs/
    └── GUIA_CONFIGURACAO.md  # Este guia
```

### Script de Setup Automático

**setup.sh** (Mac/Linux):
```bash
#!/bin/bash

echo "Configurando Claude Code para o time..."

# Criar diretórios
mkdir -p ~/.claude

# Copiar CLAUDE.md
cp CLAUDE.md ~/.claude/CLAUDE.md

# Copiar settings (se não existir)
if [ ! -f ~/.claude/settings.json ]; then
    cp plugins.json ~/.claude/settings.json
fi

echo "Configuração concluída!"
echo "Agora configure seus tokens:"
echo "1. GitHub Token: https://github.com/settings/tokens"
echo "2. Brave API Key: https://brave.com/search/api/"
echo ""
echo "Adicione os tokens no VSCode Settings → Claude → MCP Servers"
```

**setup.ps1** (Windows):
```powershell
Write-Host "Configurando Claude Code para o time..."

# Criar diretórios
New-Item -Path "$env:USERPROFILE\.claude" -ItemType Directory -Force

# Copiar CLAUDE.md
Copy-Item -Path "CLAUDE.md" -Destination "$env:USERPROFILE\.claude\CLAUDE.md"

# Copiar settings (se não existir)
if (-not (Test-Path "$env:USERPROFILE\.claude\settings.json")) {
    Copy-Item -Path "plugins.json" -Destination "$env:USERPROFILE\.claude\settings.json"
}

Write-Host "Configuração concluída!"
Write-Host "Agora configure seus tokens:"
Write-Host "1. GitHub Token: https://github.com/settings/tokens"
Write-Host "2. Brave API Key: https://brave.com/search/api/"
Write-Host ""
Write-Host "Adicione os tokens no VSCode Settings → Claude → MCP Servers"
```

---

## Segurança

### NUNCA COMMITE:
- Tokens de acesso (GitHub, APIs)
- Chaves privadas
- Credenciais

### Boas Práticas:
1. Use variáveis de ambiente quando possível
2. Adicione arquivos de configuração local ao `.gitignore`
3. Rotacione tokens periodicamente
4. Use tokens com escopo mínimo necessário
5. Configure tokens por projeto (se possível) ao invés de global

### Arquivo de Template

Crie um arquivo `mcp-config.template.json`:

```json
{
  "claude.mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "<SUBSTITUA_PELO_SEU_TOKEN>"
      }
    }
  }
}
```

Cada membro do time cria sua própria cópia local com seus tokens.

---

## Perguntas Frequentes

**Q: Preciso configurar todos os MCP servers?**
A: Não. Configure apenas os que você vai usar. Os essenciais são: filesystem, github e serena.

**Q: Os plugins são obrigatórios?**
A: Não, mas são altamente recomendados. O `superpowers`, `explanatory-output-style` e `serena` são essenciais — os demais podem ser instalados conforme necessidade do time.

**Q: Posso ter CLAUDE.md diferente por projeto?**
A: Sim! Coloque um `CLAUDE.md` na raiz do projeto. Ele complementa (não substitui) o global.

**Q: Como desabilitar temporariamente um MCP server?**
A: No VSCode settings, comente a seção do server com `//` ou remova temporariamente.

**Q: O que fazer se um MCP server estiver causando lentidão?**
A: Desabilite-o temporariamente e reporte o problema. Você pode trabalhar sem ele.

**Q: Posso criar meus próprios MCP servers?**
A: Sim! Consulte a documentação oficial: https://modelcontextprotocol.io

---

## Recursos Adicionais

- **Documentação Oficial Claude Code**: https://docs.anthropic.com/claude/docs/claude-code
- **MCP Protocol**: https://modelcontextprotocol.io
- **GitHub do Claude Code**: https://github.com/anthropics/claude-code
- **Comunidade**: Discord oficial Anthropic

---

**Versão:** 1.1.0
**Última atualização:** 10/03/2026
**Mantenedor:** [Seu Nome/Time]
