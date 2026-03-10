# Minhas Configurações Claude Code

**Data:** 06/02/2026

---

## Caminhos de Configuração por Sistema Operacional

Este documento usa caminhos que variam dependendo do seu sistema operacional:

| Item | Linux/Mac | Windows |
|------|-----------|---------|
| **Diretório Claude** | `~/.claude/` | `%USERPROFILE%\.claude\` ou `C:\Users\SeuUsuario\.claude\` |
| **CLAUDE.md** | `~/.claude/CLAUDE.md` | `%USERPROFILE%\.claude\CLAUDE.md` |
| **Settings** | `~/.claude/settings.json` | `%USERPROFILE%\.claude\settings.json` |
| **Plugins** | `~/.claude/plugins/` | `%USERPROFILE%\.claude\plugins\` |

**Nota:** No Windows, você pode usar:
- **PowerShell:** `$env:USERPROFILE\.claude\`
- **CMD:** `%USERPROFILE%\.claude\`
- **Git Bash:** `~/.claude/` (funciona como no Linux/Mac)

Ao longo deste documento, quando você ver comandos, procure pela seção correspondente ao seu sistema operacional.

---

## MCP Servers Ativos

### 1. GitHub MCP Server
**Status:** Ativo
**Função:** Integração completa com GitHub
**Ferramentas disponíveis:**
- Criar/editar arquivos em repositórios
- Gerenciar issues e pull requests
- Buscar código em repositórios
- Criar branches e fazer merge
- Criar e fazer review de PRs
- Gerenciar repositórios

**Uso recomendado:**
- Automatizar criação de PRs
- Buscar código em múltiplos repositórios
- Gerenciar issues do time

---

### 2. Filesystem MCP Server
**Status:** Ativo
**Função:** Manipulação avançada de arquivos
**Ferramentas disponíveis:**
- Leitura de múltiplos arquivos simultâneos
- Edição baseada em linhas
- Busca recursiva de arquivos
- Listagem de diretórios com tamanhos
- Árvore de diretórios em JSON

**Uso recomendado:**
- Operações em múltiplos arquivos
- Análise estrutural de projetos
- Busca e replace em larga escala

---

### 3. Memory MCP Server
**Status:** Ativo
**Função:** Sistema de knowledge graph persistente
**Ferramentas disponíveis:**
- Criar entidades e relações
- Adicionar observações
- Buscar e consultar grafos
- Persistir conhecimento entre conversas

**Uso recomendado:**
- Manter contexto sobre projetos
- Documentar decisões arquiteturais
- Criar base de conhecimento do time

**Explicação do Knowledge Graph:**
O Memory server cria um grafo de conhecimento onde você pode armazenar informações estruturadas. Por exemplo:
- Entidade: "Sistema de Autenticação"
- Relações: "usa" → "JWT", "conecta com" → "API de Usuários"
- Observações: "Migrado para OAuth2 em Jan/2026"

Este conhecimento persiste entre conversas, permitindo que o Claude "lembre" de decisões e contextos importantes.

---

### 4. Brave Search MCP Server
**Status:** Ativo
**Função:** Busca na web
**Ferramentas disponíveis:**
- Web search geral
- Local search (negócios e lugares)
- Filtros de conteúdo e freshness

**Uso recomendado:**
- Buscar documentação atualizada
- Pesquisar soluções para problemas
- Encontrar bibliotecas e ferramentas

---

### 5. Serena MCP Server
**Status:** Ativo
**Função:** Análise semântica de código (MUITO PODEROSO!)
**Ferramentas disponíveis:**
- Análise de símbolos (classes, métodos, funções)
- Busca por referências de código
- Edição em nível de símbolo
- Rename refactoring automático
- Busca de padrões em código
- Sistema de memórias de projeto
- Find/replace em nível de símbolo

**Uso recomendado:**
- Refatorações complexas
- Análise de dependências
- Renomear símbolos em todo o codebase
- Entender arquitetura de projetos grandes

**Por que Serena é especial:**
Diferente de ferramentas de busca simples, Serena entende a SEMÂNTICA do código. Ele sabe o que é uma classe, um método, uma interface. Quando você pede para "renomear getUserById", ele encontra TODAS as referências (chamadas, imports, exports) e renomeia tudo corretamente, respeitando escopo e contexto.

---

### 6. Docker MCP Server
**Status:** Ativo
**Função:** Gerenciamento de containers
**Ferramentas disponíveis:**
- Criar containers standalone
- Deploy de stacks Docker Compose
- Visualizar logs de containers
- Listar containers

**Uso recomendado:**
- Gerenciar ambiente de desenvolvimento
- Debug de containers
- Automação de deploy local

---

## Plugins Instalados

### 1. Superpowers Plugin
**Status:** Ativo
**Identificador:** `superpowers@claude-plugins-official`
**Função:** Framework central de produtividade

**O que faz:**
- Estrutura todos os fluxos de trabalho com disciplina
- Skills: `/brainstorm`, `/writing-plans`, `/executing-plans`
- Skills: `/systematic-debugging`, `/test-driven-development`
- Skills: `/verification-before-completion`, `/requesting-code-review`
- Skills: `/dispatching-parallel-agents`, `/finishing-a-development-branch`

---

### 2. Explanatory Output Style Plugin
**Status:** Ativo
**Identificador:** `explanatory-output-style@claude-code-plugins`
**Função:** Modo de saída educacional

**O que faz:**
- Claude fornece explicações detalhadas durante o trabalho
- Adiciona insights educacionais sobre decisões técnicas
- Ideal para aprendizado e onboarding de novos membros
- Explica o "porquê" das escolhas técnicas

**Este plugin está ATIVO agora!** Por isso você recebe explicações detalhadas.

---

### 3. Serena Plugin
**Status:** Ativo
**Identificador:** `serena@claude-plugins-official`
**Função:** Análise semântica eficiente de código

**O que faz:**
- Instrui o Claude a usar o Serena MCP Server de forma eficiente
- Leitura incremental por símbolos (evita ler arquivos inteiros)
- Edição a nível de símbolo (classes, métodos, funções)
- Economiza tokens em análises de codebase

---

### 4. Context7 Plugin
**Status:** Ativo
**Identificador:** `context7@claude-plugins-official`
**Função:** Documentação atualizada de bibliotecas

**O que faz:**
- Busca docs de qualquer biblioteca por nome
- Supera o knowledge cutoff para libs em evolução rápida
- Garante exemplos corretos para Next.js, React, Drizzle, etc.

---

### 5. Code Review Plugin
**Status:** Ativo
**Identificador:** `code-review@claude-plugins-official`
**Função:** Revisão estruturada de pull requests
**Comando:** `/code-review` ou `/review-pr`

**O que faz:**
- Análise detalhada de pull requests por categorias
- Identifica problemas de segurança, performance e legibilidade
- Verifica cobertura de testes
- Sugere melhorias com referência de linha

---

### 6. Frontend Design Plugin
**Status:** Ativo
**Identificador:** `frontend-design@claude-plugins-official`
**Função:** Assistente especializado em UI
**Comando:** `/frontend-design`

**O que faz:**
- Cria interfaces com alta qualidade visual
- Evita estética genérica de código gerado por IA
- Gera código frontend polido e profissional
- Acessibilidade (ARIA), dark mode e responsividade por padrão

---

### 7. GitHub Plugin
**Status:** Ativo
**Identificador:** `github@claude-plugins-official`
**Função:** Workflows estruturados com GitHub

**O que faz:**
- Workflows inteligentes para criação de PRs
- Análise de issues e planejamento de implementação
- Complementa o GitHub MCP Server com comportamentos estruturados

---

### 8. Feature Dev Plugin
**Status:** Ativo
**Identificador:** `feature-dev@claude-plugins-official`
**Função:** Desenvolvimento guiado de features
**Comando:** `/feature-dev`

**O que faz:**
- Explora codebase antes de implementar (subagente `code-explorer`)
- Desenha arquitetura antes de codar (subagente `code-architect`)
- Revisa implementação ao final (subagente `code-reviewer`)

---

### 9. Code Simplifier Plugin
**Status:** Ativo
**Identificador:** `code-simplifier@claude-plugins-official`
**Função:** Simplificação e limpeza de código
**Comando:** `/simplify`

**O que faz:**
- Revisa código recém-escrito para clareza e manutenibilidade
- Identifica duplicações e abstrações desnecessárias
- Verifica consistência com padrões do codebase

---

### 10. Claude MD Management Plugin
**Status:** Ativo
**Identificador:** `claude-md-management@claude-plugins-official`
**Função:** Gestão de arquivos CLAUDE.md
**Comandos:** `/revise-claude-md`, `/claude-md-improver`

**O que faz:**
- Audita qualidade de CLAUDE.md em repositórios
- Atualiza instruções com aprendizados da sessão
- Mantém a "memória de longo prazo" do projeto atualizada

---

### 11. Claude Code Setup Plugin
**Status:** Ativo
**Identificador:** `claude-code-setup@claude-plugins-official`
**Função:** Recomendação de automações do Claude Code
**Comando:** `/claude-automation-recommender`

**O que faz:**
- Analisa codebase e recomenda hooks, plugins e MCP servers
- Lista priorizada de configurações com justificativas
- Ideal ao iniciar Claude Code em um novo projeto

---

## Arquivo CLAUDE.md Global

**Localização:**
- **Linux/Mac:** `~/.claude/CLAUDE.md`
- **Windows:** `%USERPROFILE%\.claude\CLAUDE.md` (ou `C:\Users\SeuUsuario\.claude\CLAUDE.md`)

**Status:** Configurado
**Versão:** 1.0.0

**Conteúdo:**
- Filosofia de trabalho com foco em explicações
- Diretrizes para TypeScript/React
- Diretrizes para Python
- Diretrizes para C#
- Práticas de segurança
- Padrões de Git e versionamento
- Guidelines de code review
- Formato de insights educacionais

**Como funciona:**
Este arquivo é carregado automaticamente em TODAS as conversas com o Claude Code. Ele garante que o Claude sempre siga os padrões do time, independente do projeto.

---

## Configurações Especiais

### Modo de Saída
**Atual:** Explanatory (Explicativo)
**Motivo:** Plugin explanatory-output-style está ativo

**Características:**
- Respostas mais detalhadas
- Insights educacionais formatados
- Explicações de trade-offs
- Contexto sobre decisões técnicas

### Estilo de Comunicação
**Emojis:** Desabilitados (conforme CLAUDE.md)
**Formato:** Profissional e educacional
**Foco:** Clareza e contexto

---

## Comparação: Antes vs Depois

### Antes (Sem Configuração)
- Claude básico sem contexto do projeto
- Sem ferramentas de integração
- Sem persistência de conhecimento
- Sem padrões de código definidos
- Cada conversa começa do zero

### Depois (Com Esta Configuração)
- Claude com 6 MCP servers poderosos
- Integração com GitHub, filesystem, Docker
- Memória persistente entre conversas
- Análise semântica de código (Serena)
- Padrões de código aplicados automaticamente
- 11 plugins ativos: fluxos disciplinados, modo educacional, docs atualizadas, code review, frontend especializado e mais

---

## Próximos Passos

### Para Você
1. Teste as ferramentas em um projeto real
2. Configure tokens faltantes (GitHub, Brave) se ainda não fez
3. Experimente `/review-pr` em um PR e `/feature-dev` em uma nova feature
4. Use o Memory server para documentar decisões importantes
5. Use `/claude-automation-recommender` em um novo projeto para configuração otimizada

### Para o Time
1. Compartilhe o arquivo `GUIA_CONFIGURACAO_TIME.md`
2. Crie um repositório central com estas configurações
3. Agende uma sessão de onboarding
4. Defina um processo de atualização das configurações

---

## Comandos Úteis

### Verificar Configurações

**Linux/Mac:**
```bash
# Ver CLAUDE.md
cat ~/.claude/CLAUDE.md

# Ver settings
cat ~/.claude/settings.json

# Ver plugins instalados
ls -la ~/.claude/plugins/cache/claude-code-plugins/
```

**Windows (PowerShell):**
```powershell
# Ver CLAUDE.md
Get-Content $env:USERPROFILE\.claude\CLAUDE.md

# Ver settings
Get-Content $env:USERPROFILE\.claude\settings.json

# Ver plugins instalados
Get-ChildItem $env:USERPROFILE\.claude\plugins\cache\claude-code-plugins\
```

**Windows (Git Bash/CMD):**
```bash
# Ver CLAUDE.md
type %USERPROFILE%\.claude\CLAUDE.md

# Ver settings
type %USERPROFILE%\.claude\settings.json
```

### Testar MCP Servers
```bash
# Funciona em todas as plataformas (Windows, Linux, Mac)

# Testar Memory server manualmente
npx -y @modelcontextprotocol/server-memory

# Testar Serena (requer projeto)
# Automaticamente testado quando você abre um projeto
```

### Atualizar Configurações

**Linux/Mac:**
```bash
# Fazer backup
cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.backup

# Editar
code ~/.claude/CLAUDE.md  # ou seu editor favorito
```

**Windows (PowerShell):**
```powershell
# Fazer backup
Copy-Item $env:USERPROFILE\.claude\CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md.backup

# Editar
code $env:USERPROFILE\.claude\CLAUDE.md  # ou seu editor favorito
```

---

## Recursos Consumidos

### Armazenamento
- Plugins: ~10-15 MB
- Cache: ~50-100 MB
- Configurações: <1 MB

### Memória (Runtime)
- MCP Servers: ~100-200 MB por server ativo
- VSCode Extension: ~150-300 MB

### Network
- MCP servers fazem chamadas via npx (download sob demanda)
- Cache local evita downloads repetidos

---

## Segurança e Privacidade

### Dados Locais
- **Todas as configurações ficam em:**
  - Linux/Mac: `~/.claude/`
  - Windows: `%USERPROFILE%\.claude\`
- Nenhum dado é enviado para servidores externos (exceto Claude API)
- Memory server armazena dados localmente

### Tokens e Credenciais
- NUNCA commite tokens no Git
- Use variáveis de ambiente quando possível
- Rotacione tokens periodicamente

### Acesso a Arquivos
- Filesystem server tem acesso ao seu diretório home
- Limite o acesso editando a configuração se necessário
- Docker server requer Docker daemon local

---

**Gerado em:** 10/03/2026
**Válido até:** Próxima atualização de configuração
