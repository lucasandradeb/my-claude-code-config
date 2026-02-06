# Claude Code - Guia Completo

Repositório centralizado de configurações, diretrizes e padrões para uso do Claude Code no desenvolvimento.

## Índice

- [O que é Claude Code?](#o-que-é-claude-code)
- [Modelos Claude: Opus, Sonnet e Haiku](#modelos-claude-opus-sonnet-e-haiku)
- [MCP Servers - O Poder do Claude Code](#mcp-servers---o-poder-do-claude-code)
- [Memory Server - Conhecimento Persistente](#memory-server---conhecimento-persistente)
- [Plugins - Especializações do Claude](#plugins---especializações-do-claude)
- [Skills - Comandos Rápidos](#skills---comandos-rápidos)
- [Claude Cowork - Colaboração em Equipe](#claude-cowork---colaboração-em-equipe)
- [Economia de Tokens - Usando com Eficiência](#economia-de-tokens---usando-com-eficiência)
- [Configuração do Projeto](#configuração-do-projeto)
- [Referências e Documentação Oficial](#referências-e-documentação-oficial)

---

## O que é Claude Code?

**Claude Code** é um assistente de programação AI desenvolvido pela Anthropic que funciona como uma extensão do VSCode. Pense nele como um **colega de equipe especializado** que entende código, pode ler e modificar arquivos, executar comandos, buscar informações online e muito mais.

### Principais Características

- **Integração Nativa com VSCode**: Trabalha diretamente no seu editor
- **Execução de Comandos**: Pode rodar scripts, testes, git commands, etc.
- **Leitura e Escrita de Arquivos**: Manipula código com precisão
- **Análise Semântica**: Entende a estrutura e relações do código
- **Extensível via MCP**: Adiciona capacidades através de servidores especializados
- **Conversação Contextual**: Mantém contexto da conversa e do projeto

### Como Funciona?

```
Você → Pergunta/Pedido → Claude Code → Analisa → Executa Ações → Responde
                                ↓
                          MCP Servers
                          (Filesystem, GitHub, etc.)
```

O Claude Code recebe suas instruções em linguagem natural, analisa o contexto do projeto, usa ferramentas especializadas (MCP servers) e executa as ações necessárias.

---

## Modelos Claude: Opus, Sonnet e Haiku

A Anthropic oferece diferentes modelos do Claude, cada um otimizado para casos de uso específicos. Pense neles como diferentes níveis de expertise:

### 🎯 Claude Opus 4.6

**O Especialista Sênior**

- **Quando usar**: Tarefas complexas, arquitetura de sistemas, decisões críticas
- **Características**:
  - Mais inteligente e capaz
  - Raciocínio mais profundo
  - Melhor em tarefas que exigem criatividade e análise complexa
  - Maior custo por uso
- **Exemplos de uso**:
  - Refatoração arquitetural de sistemas
  - Análise de segurança avançada
  - Design de APIs complexas
  - Debugging de problemas difíceis

```
Complexidade: ████████████ (10/10)
Velocidade:   ██████░░░░░░ (5/10)
Custo:        ████████████ (10/10)
```

### 🚀 Claude Sonnet 4.5

**O Desenvolvedor Pleno (Recomendado)**

- **Quando usar**: Desenvolvimento diário, maioria das tarefas de programação
- **Características**:
  - Excelente equilíbrio custo-benefício
  - Velocidade rápida
  - Capaz o suficiente para a maioria das tarefas
  - **Padrão recomendado para desenvolvimento**
- **Exemplos de uso**:
  - Implementação de features
  - Code reviews
  - Escrita de testes
  - Debugging regular
  - Refatoração de código

```
Complexidade: ████████░░░░ (8/10)
Velocidade:   ████████░░░░ (8/10)
Custo:        ████░░░░░░░░ (4/10)
```

### ⚡ Claude Haiku 4.5

**O Desenvolvedor Júnior/Estagiário**

- **Quando usar**: Tarefas simples, rápidas e repetitivas
- **Características**:
  - Mais rápido e barato
  - Ideal para operações simples
  - Menor capacidade de raciocínio complexo
  - Ótimo para automação
- **Exemplos de uso**:
  - Formatação de código
  - Geração de boilerplate
  - Tarefas repetitivas
  - Perguntas simples sobre documentação

```
Complexidade: ████░░░░░░░░ (4/10)
Velocidade:   ████████████ (10/10)
Custo:        ██░░░░░░░░░░ (2/10)
```

### Como Escolher o Modelo?

```
┌─────────────────────────────────────────────┐
│ Tarefa complexa e crítica?                  │
│ └─→ SIM: Use Opus                           │
│ └─→ NÃO: Continue                           │
└─────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────┐
│ Tarefa muito simples/repetitiva?            │
│ └─→ SIM: Use Haiku                          │
│ └─→ NÃO: Use Sonnet (padrão)                │
└─────────────────────────────────────────────┘
```

**Regra de Ouro**: Na dúvida, use **Sonnet**. Ele oferece o melhor equilíbrio para desenvolvimento diário.

---

## MCP Servers - O Poder do Claude Code

**MCP (Model Context Protocol)** é um protocolo que permite ao Claude Code conectar-se a servidores especializados que expandem suas capacidades. É como dar "superpoderes" específicos ao Claude.

### Como Funciona?

```
Claude Code
    ↓
MCP Protocol (camada de comunicação)
    ↓
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ Filesystem  │   GitHub    │   Memory    │   Serena    │
│   Server    │   Server    │   Server    │   Server    │
└─────────────┴─────────────┴─────────────┴─────────────┘
      ↓              ↓             ↓             ↓
   Arquivos       API GitHub   Knowledge    Análise
   do Sistema                    Graph      Semântica
```

### MCP Servers Recomendados

#### 1. 📁 **Filesystem Server**

**O que faz**: Manipulação avançada de arquivos e diretórios

**Capacidades**:
- Ler múltiplos arquivos simultaneamente
- Criar diretórios recursivamente
- Buscar arquivos por padrões (glob)
- Listar diretórios com informações detalhadas
- Operações atômicas de edição

**Exemplo de uso**:
```
Você: "Leia todos os arquivos .ts na pasta src/components"
Claude: [Usa filesystem server para ler múltiplos arquivos de uma vez]
```

**Por que é importante**: Torna operações com arquivos muito mais eficientes e precisas.

---

#### 2. 🐙 **GitHub Server**

**O que faz**: Integração completa com GitHub

**Capacidades**:
- Criar e gerenciar Pull Requests
- Abrir, comentar e fechar Issues
- Buscar código em repositórios
- Fazer fork de repositórios
- Criar branches
- Merge de PRs
- Visualizar status de checks/CI

**Exemplo de uso**:
```
Você: "Crie um PR com as mudanças que fizemos"
Claude: [Usa github server para criar PR com título e descrição]

Você: "Liste todas as issues abertas com label 'bug'"
Claude: [Busca issues usando a API do GitHub]
```

**Configuração necessária**:
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "seu_token_aqui"
      }
    }
  }
}
```

**Como obter token**: GitHub Settings → Developer settings → Personal access tokens → Generate new token

---

#### 3. 🧠 **Memory Server**

**O que faz**: Cria um knowledge graph persistente entre conversas

**Capacidades**:
- Armazena informações sobre o projeto
- Cria relações entre entidades (classes, funções, conceitos)
- Persiste aprendizado entre sessões
- Busca contextual de conhecimento

**Exemplo de uso**:
```
Você: "Lembre que UserService usa o padrão Repository"
Claude: [Cria entidade "UserService" e relação com padrão Repository]

[Nova conversa, dias depois]

Você: "Como está estruturado o UserService?"
Claude: [Recupera informações salvas do knowledge graph]
```

**Estrutura do Knowledge Graph**:
```
Entidades: Classes, Funções, Conceitos, Padrões
     ↓
Observações: Detalhes sobre cada entidade
     ↓
Relações: Como entidades se conectam
```

**Por que é poderoso**: Claude "lembra" de decisões arquiteturais, padrões do projeto e convenções mesmo em conversas futuras.

---

#### 4. 🎯 **Serena Server**

**O que faz**: Análise semântica avançada de código

**Capacidades**:
- Entende estrutura de símbolos (classes, métodos, funções)
- Encontra referências de código
- Rename inteligente (refactoring)
- Busca por padrões complexos
- Inserção/substituição de código a nível de símbolo
- Análise de dependências

**Exemplo de uso**:
```
Você: "Renomeie o método getUserData para fetchUserData em todo o projeto"
Claude: [Usa serena para renomear mantendo todas as referências]

Você: "Mostre todos os lugares que usam a classe UserRepository"
Claude: [Encontra todas as referências semanticamente]
```

**Linguagens suportadas**: TypeScript, Python, C#, Java, Go, Rust e mais

**Por que é essencial**: Permite refatorações seguras e análises que vão além de simples busca textual.

---

#### 5. 🐳 **Docker Server**

**O que faz**: Gerenciamento de containers Docker

**Capacidades**:
- Criar e gerenciar containers
- Deploy de stacks Docker Compose
- Visualizar logs de containers
- Listar containers ativos

**Exemplo de uso**:
```
Você: "Suba um container PostgreSQL para desenvolvimento"
Claude: [Cria container com configurações apropriadas]

Você: "Mostre os logs do container api"
Claude: [Exibe logs do container em tempo real]
```

---

#### 6. 🔍 **Brave Search Server**

**O que faz**: Busca na web para informações atualizadas

**Capacidades**:
- Busca geral na web
- Busca local (empresas, lugares)
- Acesso a documentação atualizada
- Pesquisa de erros e soluções

**Exemplo de uso**:
```
Você: "Qual a sintaxe mais recente do async/await em C# 13?"
Claude: [Busca documentação atualizada online]
```

**Quando usar**: Para tecnologias muito recentes ou documentação que mudou após o knowledge cutoff do Claude.

---

### Comparativo: Com e Sem MCP Servers

#### Sem MCP Servers
```
Você: "Encontre todos os usos da função processPayment"
Claude: Usa busca textual simples (grep)
  → Pode encontrar comentários, strings, etc.
  → Não entende escopo ou contexto
```

#### Com Serena MCP
```
Você: "Encontre todos os usos da função processPayment"
Claude: Usa análise semântica
  → Encontra apenas referências reais à função
  → Mostra contexto de cada uso
  → Pode mostrar call hierarchy
```

---

## Memory Server - Conhecimento Persistente

O Memory Server merece uma seção especial pela sua importância em projetos de longo prazo.

### Como Funciona?

O Memory Server cria um **Knowledge Graph** (grafo de conhecimento) estruturado:

```
┌──────────────────────────────────────────────┐
│           KNOWLEDGE GRAPH                    │
├──────────────────────────────────────────────┤
│                                              │
│  [UserService] ─────"usa"────→ [Repository]  │
│       │                             │        │
│       │                             │        │
│    "implementa"                "persiste"    │
│       │                             │        │
│       ↓                             ↓        │
│  [CQRS Pattern]              [PostgreSQL]    │
│                                              │
│  Observações:                                │
│  - UserService: "Validação com FluentVal"    │
│  - Repository: "Usa Dapper para queries"     │
└──────────────────────────────────────────────┘
```

### Tipos de Informação Armazenada

1. **Arquitetura do Projeto**
   ```
   Entidade: "Sistema de Autenticação"
   Tipo: Architecture
   Observações:
     - Usa JWT para tokens
     - Refresh tokens armazenados no Redis
     - Rate limiting com 5 tentativas
   ```

2. **Decisões Técnicas**
   ```
   Entidade: "Escolha do ORM"
   Tipo: Decision
   Observações:
     - Escolhemos Dapper ao invés de EF Core
     - Razão: Performance em queries complexas
     - Data: Janeiro 2026
   ```

3. **Convenções do Time**
   ```
   Entidade: "Padrão de Nomenclatura"
   Tipo: Convention
   Observações:
     - Services terminam com "Service"
     - Repositories terminam com "Repository"
     - DTOs em pasta separada /DTOs
   ```

### Comandos Úteis

```
# Criar memória
"Lembre que o UserService usa injeção de dependência"

# Buscar memória
"Como está estruturado o sistema de auth?"

# Atualizar memória
"Atualize: agora usamos Redis para cache de usuários"

# Ver grafo completo
"Mostre todo o knowledge graph do projeto"
```

### Benefícios em Projetos Reais

1. **Onboarding de Novos Desenvolvedores**
   - Claude explica arquitetura usando memórias
   - Entende convenções do time automaticamente

2. **Consistência de Código**
   - Lembra padrões usados anteriormente
   - Sugere implementações alinhadas com o projeto

3. **Documentação Viva**
   - Conhecimento não fica desatualizado
   - Evolui junto com o código

4. **Continuidade Entre Conversas**
   - Não precisa re-explicar arquitetura
   - Mantém contexto de decisões passadas

---

## Plugins - Especializações do Claude

**Plugins** são extensões que modificam o comportamento do Claude Code para tarefas específicas. Diferente de MCP servers (que adicionam ferramentas), plugins modificam como o Claude pensa e age.

### Como Funcionam?

```
Claude Code Base
      ↓
   Plugin aplicado
      ↓
Comportamento modificado
```

### Plugins Recomendados

#### 1. 📝 **code-review**

**O que faz**: Transforma Claude em um revisor de código especializado

**Ativa com**: `/code-review` ou `/review-pr`

**Comportamento modificado**:
- Analisa PRs de forma estruturada
- Verifica segurança, performance, legibilidade
- Sugere melhorias específicas
- Identifica code smells
- Valida testes

**Exemplo de uso**:
```
Você: /code-review https://github.com/user/repo/pull/123

Claude:
## Code Review - PR #123

### Segurança
✓ Input validation presente
⚠️ SQL query concatenada (linha 45) - usar prepared statements

### Performance
⚠️ Loop O(n²) detectado (linha 78-92)
  Sugestão: usar Map para lookup O(1)

### Testes
✗ Nova função getUserProfile não tem testes
  Recomendação: adicionar testes unitários
```

---

#### 2. 💡 **explanatory-output-style**

**O que faz**: Ativa modo educacional com insights técnicos

**Comportamento modificado**:
- Explica decisões técnicas
- Fornece contexto arquitetural
- Compartilha trade-offs de abordagens
- Inclui blocos de "Insight" educacionais

**Exemplo de uso**:
```
Você: "Crie um hook React para buscar dados de usuário"

Claude:
[Cria o hook]

★ Insight ─────────────────────────────────────
- Usamos useEffect com array de dependências para evitar
  re-fetches desnecessários
- useState separado para loading/error/data permite
  UI mais granular
- Cleanup function previne memory leaks em unmount
─────────────────────────────────────────────────
```

**Quando ativar**: Ideal para aprendizado ou quando trabalha com desenvolvedores menos experientes.

---

#### 3. 🎨 **frontend-design**

**O que faz**: Especialista em criar interfaces frontend de alta qualidade

**Ativa com**: `/frontend-design`

**Comportamento modificado**:
- Foco em design e UX
- Componentes com estética profissional
- Acessibilidade por padrão
- Animações e transições suaves
- Código visual polido

**Exemplo de uso**:
```
Você: /frontend-design Crie um card de produto

Claude:
[Gera componente com]:
- Design moderno e profissional
- Hover effects suaves
- Acessibilidade (ARIA labels)
- Responsividade
- Dark mode support
```

---

### Como Instalar Plugins

**Via Command Palette** (Recomendado):
```
1. Cmd+Shift+P (Mac) ou Ctrl+Shift+P (Windows)
2. Digite: "Claude: Install Plugin"
3. Digite o nome: "code-review@claude-code-plugins"
```

**Via Configuração Manual**:
```json
{
  "plugins": [
    "code-review@claude-code-plugins",
    "explanatory-output-style@claude-code-plugins",
    "frontend-design@claude-code-plugins"
  ]
}
```

### Plugin vs MCP Server

| Aspecto | Plugin | MCP Server |
|---------|--------|------------|
| **O que faz** | Modifica comportamento do Claude | Adiciona ferramentas/capacidades |
| **Como funciona** | Altera instruções internas | Conecta a serviços externos |
| **Exemplo** | Modo code-review | Acesso a GitHub API |
| **Ativação** | Manual com `/comando` ou auto | Sempre disponível |
| **Uso** | Tarefas específicas | Operações gerais |

**Analogia**:
- **Plugin** = Mudar a "personalidade" do Claude para uma tarefa
- **MCP Server** = Dar novas "ferramentas" ao Claude

---

## Skills - Comandos Rápidos

**Skills** são comandos pré-programados que executam fluxos de trabalho específicos. Pense neles como "atalhos inteligentes" ou "macros com IA".

### Skills Disponíveis

#### `/commit`

**O que faz**: Cria um commit git seguindo melhores práticas

**Fluxo**:
1. Analisa mudanças com `git diff`
2. Lê histórico de commits para seguir estilo
3. Gera mensagem de commit apropriada
4. Adiciona co-author do Claude
5. Executa o commit

**Exemplo**:
```
Você: /commit

Claude:
[Analisa mudanças]
[Cria commit]

git commit -m "feat: adiciona validação de email no UserService

Implementa validação de formato de email usando regex.
Adiciona testes unitários para casos válidos e inválidos.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

#### `/review-pr` ou `/code-review`

**O que faz**: Revisa Pull Request completo

**Fluxo**:
1. Busca informações do PR
2. Analisa diff de arquivos
3. Verifica testes
4. Identifica problemas
5. Sugere melhorias
6. Gera relatório estruturado

**Exemplo**:
```
Você: /review-pr 123

Claude:
## Code Review Summary

📁 Files Changed: 8
➕ Additions: 234 lines
➖ Deletions: 45 lines

### Issues Found
🔴 Critical (1):
  - SQL injection vulnerability in UserService.cs:45

🟡 Warning (3):
  - Missing null checks in validateEmail()
  - N+1 query pattern detected
  - No tests for new endpoints

### Recommendations
1. Use parameterized queries
2. Add input validation
3. Implement eager loading
4. Add integration tests
```

---

#### `/frontend-design`

**O que faz**: Ativa modo especialista em frontend

**Comportamento**:
- Foco em design visual
- UX e acessibilidade
- Componentes polidos
- Animações e interações

---

### Como Usar Skills

**Sintaxe**:
```
/nome-da-skill [argumentos opcionais]
```

**Exemplos**:
```
/commit
/commit -m "mensagem customizada"
/review-pr 123
/code-review https://github.com/user/repo/pull/456
/frontend-design
```

### Criar Skills Customizadas

Skills podem ser criadas para fluxos de trabalho específicos do seu time:

```typescript
// Exemplo conceitual
{
  "skill": "deploy-staging",
  "description": "Deploy para ambiente de staging",
  "steps": [
    "Rodar testes",
    "Build do projeto",
    "Push para Docker Registry",
    "Atualizar Kubernetes staging",
    "Notificar time no Slack"
  ]
}
```

---

## Claude Cowork - Colaboração em Equipe

**Claude Cowork** é uma funcionalidade que permite compartilhar sessões do Claude Code com outros membros do time, possibilitando colaboração em tempo real.

### Como Funciona?

```
Desenvolvedor A (VSCode)
      ↓
   Inicia sessão Cowork
      ↓
   Gera link de compartilhamento
      ↓
Desenvolvedor B acessa via navegador (claude.ai)
      ↓
   Ambos veem e interagem com a mesma conversa
```

### Casos de Uso

#### 1. **Pair Programming Remoto**
```
Dev A: [Compartilha sessão]
Dev B: [Acessa pelo navegador]
Ambos: Trabalham juntos na implementação de feature
```

#### 2. **Code Review Colaborativo**
```
Author: [Cria PR e inicia análise com Claude]
Reviewer: [Acessa sessão compartilhada]
Ambos: Discutem mudanças e melhorias em tempo real
```

#### 3. **Debugging em Equipe**
```
Junior Dev: [Encontra bug complexo]
Senior Dev: [Acessa sessão compartilhada]
Claude: Ajuda ambos a investigar e resolver
```

#### 4. **Onboarding**
```
Novo desenvolvedor: [Explorando codebase com Claude]
Mentor: [Acompanha e guia pelo Cowork]
```

### Como Usar

**Iniciar Sessão Cowork**:
1. No Claude Code, inicie uma conversa
2. Click no ícone de compartilhamento
3. Selecione "Start Cowork Session"
4. Copie o link gerado

**Participar de Sessão**:
1. Receba o link do Cowork
2. Abra em claude.ai
3. Interaja normalmente
4. Mudanças são sincronizadas em tempo real

### Segurança e Privacidade

⚠️ **Importante**:
- Sessões Cowork compartilham TODO o contexto da conversa
- Arquivos lidos ficam visíveis para todos os participantes
- Não compartilhe sessões com informações sensíveis
- Links de Cowork expiram após a sessão

### Limites e Considerações

- **Latência**: Pode haver pequeno delay na sincronização
- **Permissões**: Todos os participantes podem executar comandos
- **Tokens**: Consumo de tokens é compartilhado
- **Sessões Simultâneas**: Cada workspace pode ter uma sessão ativa

---

## Economia de Tokens - Usando com Eficiência

Tokens são a "moeda" que determina quanto você pode usar o Claude. Cada modelo tem diferentes custos. Aqui estão estratégias para usar de forma eficiente:

### Entendendo Tokens

```
1 token ≈ 4 caracteres em inglês
1 token ≈ 3 caracteres em português

Exemplo:
"Olá, como vai?" = ~6 tokens
"function processData() { return data; }" = ~12 tokens
```

**Custo por modelo (valores aproximados)**:
```
Haiku:  $0.25  / 1M tokens entrada
Sonnet: $3.00  / 1M tokens entrada
Opus:   $15.00 / 1M tokens entrada
```

### Estratégias de Economia

#### 1. **Escolha o Modelo Certo**

❌ **Ruim**: Usar Opus para tudo
```
Você: "Formate este JSON"
[Usa Opus - caro e desnecessário]
```

✅ **Bom**: Usar modelo apropriado
```
Você: "Formate este JSON" → Use Haiku
Você: "Refatore arquitetura do sistema" → Use Opus
Você: "Implemente feature padrão" → Use Sonnet
```

---

#### 2. **Seja Específico nas Perguntas**

❌ **Ruim**: Perguntas vagas que exigem exploração
```
Você: "Me fale sobre o projeto"
Claude: [Lê dezenas de arquivos para entender contexto]
```

✅ **Bom**: Perguntas direcionadas
```
Você: "Explique como funciona a autenticação em UserService.cs"
Claude: [Lê apenas arquivo específico]
```

---

#### 3. **Use Memory Server**

❌ **Ruim**: Re-explicar contexto sempre
```
[Conversa 1]
Você: "O projeto usa arquitetura CQRS com MediatR..."
[Conversa 2]
Você: "O projeto usa arquitetura CQRS com MediatR..." [repete]
```

✅ **Bom**: Salvar contexto uma vez
```
[Conversa 1]
Você: "Lembre: projeto usa CQRS com MediatR"
Claude: [Salva no memory server]

[Conversa 2]
Você: "Adicione novo command"
Claude: [Usa memória salva, não precisa re-explicar]
```

---

#### 4. **Leituras Incrementais**

❌ **Ruim**: Ler arquivos inteiros desnecessariamente
```
Você: "Qual a assinatura do método processPayment?"
Claude: [Lê arquivo de 500 linhas completo]
```

✅ **Bom**: Usar análise semântica (Serena)
```
Você: "Qual a assinatura do método processPayment?"
Claude: [Usa Serena para buscar apenas o método]
```

---

#### 5. **Evite Re-Reads**

❌ **Ruim**: Ler mesmo arquivo múltiplas vezes
```
Você: "Leia UserService.cs e me diga o que faz"
Claude: [Lê arquivo]
Você: "Agora refatore o método validateUser"
Claude: [Lê arquivo novamente]
```

✅ **Bom**: Trabalhar incrementalmente na mesma conversa
```
Você: "Leia UserService.cs e refatore o método validateUser"
Claude: [Lê uma vez e já faz ambas as ações]
```

---

#### 6. **Use Globbing Inteligente**

❌ **Ruim**: Padrões muito amplos
```
Você: "Leia todos os arquivos do projeto"
Claude: [Lê centenas de arquivos incluindo node_modules]
```

✅ **Bom**: Padrões específicos
```
Você: "Leia apenas os serviços em src/services/*.ts"
Claude: [Lê apenas arquivos relevantes]
```

---

#### 7. **Aproveitamento de Contexto**

✅ **Estratégia**: Agrupe tarefas relacionadas em uma conversa
```
Você: "Vou pedir várias mudanças no módulo de auth:
1. Refatore UserService
2. Adicione testes
3. Atualize documentação"

Claude: [Mantém contexto do módulo de auth]
[Não precisa re-ler arquivos entre tarefas]
```

---

#### 8. **Ferramentas Certas para Tarefas Certas**

| Tarefa | Ferramenta Eficiente | Ferramenta Ineficiente |
|--------|---------------------|------------------------|
| Buscar arquivo por nome | `Glob` | `Read` + tentativa erro |
| Buscar texto em código | `Grep` | `Read` em vários arquivos |
| Entender estrutura classe | `Serena` (get_symbols_overview) | `Read` arquivo completo |
| Renomear variável | `Serena` (rename_symbol) | `Edit` manual em vários lugares |

---

### Monitorando Uso

**Verificar consumo**:
```
Command Palette → "Claude: Show Usage"
```

**Informações mostradas**:
- Tokens usados na conversa atual
- Custo estimado
- Histórico de uso

### Limites e Quotas

**Planos típicos** (verifique seu plano específico):
```
Free Tier:      Limitado por dia
Pro:            ~500K tokens/mês
Team:           ~2M tokens/mês (compartilhado)
Enterprise:     Customizado
```

**Dica**: Se está perto do limite, use Haiku para tarefas simples nos últimos dias do mês.

---

## Configuração do Projeto

Este repositório contém configurações padronizadas para uso eficiente do Claude Code.

### Arquivos Principais

#### [CLAUDE.md](CLAUDE.md)
Diretrizes globais de desenvolvimento que o Claude segue automaticamente:
- Padrões de código para TypeScript/React, Python e C#
- Convenções de segurança e versionamento
- Estilo de comunicação e insights educacionais

**Instalação**:
```bash
# Linux/Mac
cp CLAUDE.md ~/.claude/CLAUDE.md

# Windows (PowerShell)
Copy-Item CLAUDE.md $env:USERPROFILE\.claude\CLAUDE.md
```

---

#### [GUIA_CONFIGURACAO_TIME.md](GUIA_CONFIGURACAO_TIME.md)
Guia passo-a-passo completo para configurar:
- MCP servers (filesystem, github, memory, serena, docker, brave-search)
- Plugins recomendados
- Troubleshooting
- Scripts de setup automático

---

#### [CROSS_PLATFORM.md](CROSS_PLATFORM.md)
Guia de desenvolvimento cross-platform (Windows/Linux/macOS):
- Boas práticas para paths e line endings
- Exemplos em Python, TypeScript e C#
- Configuração Git para times multiplataforma

---

#### [EXEMPLO_CONFIGURACAO.md](EXEMPLO_CONFIGURACAO.md)
Exemplo real de configuração completa:
- MCP servers configurados
- Plugins instalados
- Comparativo antes/depois

---

### Início Rápido

1. **Instalar Claude Code**
   ```
   VSCode → Extensions → "Claude Code" → Install
   ```

2. **Configurar Diretrizes**
   ```bash
   cp CLAUDE.md ~/.claude/CLAUDE.md
   ```

3. **Configurar MCP Servers**
   - Siga o [GUIA_CONFIGURACAO_TIME.md](GUIA_CONFIGURACAO_TIME.md)
   - Configure filesystem, github (com token), serena, memory

4. **Instalar Plugins**
   ```
   Cmd+Shift+P → "Claude: Install Plugin"
   - code-review@claude-code-plugins
   - explanatory-output-style@claude-code-plugins
   ```

5. **Testar**
   ```
   Abra conversa com Claude:
   "Liste todos os MCP servers disponíveis"
   ```

---

### MCP Servers Recomendados para Começar

| Prioridade | Server | Razão |
|-----------|--------|-------|
| **Essencial** | filesystem | Manipulação eficiente de arquivos |
| **Essencial** | serena | Refactoring e análise semântica |
| **Altamente Recomendado** | memory | Conhecimento persistente |
| **Altamente Recomendado** | github | Integração com workflow |
| **Opcional** | docker | Se usa containers |
| **Opcional** | brave-search | Para buscas web |

---

## Referências e Documentação Oficial

### Documentação Principal

- **Claude Code - Documentação Oficial**
  https://docs.anthropic.com/claude/docs/claude-code
  Guia completo, tutoriais e referências

- **Claude API Documentation**
  https://docs.anthropic.com/claude/docs
  Detalhes sobre modelos, pricing e capacidades

- **MCP (Model Context Protocol)**
  https://modelcontextprotocol.io
  Especificação do protocolo MCP e desenvolvimento de servers

- **Claude Code - GitHub Repository**
  https://github.com/anthropics/claude-code
  Issues, releases e exemplos de configuração

### MCP Servers Oficiais

- **Lista de MCP Servers**
  https://github.com/modelcontextprotocol/servers
  Repositório com servers oficiais e comunitários

- **Filesystem MCP**
  https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem

- **GitHub MCP**
  https://github.com/modelcontextprotocol/servers/tree/main/src/github

- **Memory MCP**
  https://github.com/modelcontextprotocol/servers/tree/main/src/memory

- **Serena MCP**
  https://github.com/genesis-ai-dev/mcp-serena
  Análise semântica de código

### Plugins

- **Claude Code Plugins**
  https://github.com/anthropics/claude-code-plugins
  Plugins oficiais e documentação

### Comunidade e Suporte

- **Discord da Anthropic**
  https://discord.gg/anthropic
  Comunidade, suporte e discussões

- **Forum da Anthropic**
  https://discuss.anthropic.com
  Discussões técnicas e best practices

### Modelos e Pricing

- **Claude Models Overview**
  https://docs.anthropic.com/claude/docs/models-overview
  Comparativo detalhado entre Opus, Sonnet e Haiku

- **Pricing**
  https://www.anthropic.com/pricing
  Preços atualizados por modelo e tiers

### Tutoriais e Exemplos

- **Claude Code Examples**
  https://github.com/anthropics/claude-code-examples
  Exemplos práticos de uso

- **Best Practices Guide**
  https://docs.anthropic.com/claude/docs/best-practices
  Melhores práticas para uso eficiente

### Segurança

- **Security Best Practices**
  https://docs.anthropic.com/claude/docs/security
  Diretrizes de segurança ao usar Claude Code

---

## Contribuindo

Melhorias e sugestões são bem-vindas!

1. Fork do repositório
2. Crie uma branch: `git checkout -b melhoria/descricao`
3. Commit: `git commit -m "docs: adiciona seção sobre X"`
4. Push: `git push origin melhoria/descricao`
5. Abra um Pull Request

---

## Suporte

- **Problemas de configuração**: Consulte [GUIA_CONFIGURACAO_TIME.md](GUIA_CONFIGURACAO_TIME.md#troubleshooting)
- **Issues**: Abra uma issue neste repositório
- **Dúvidas sobre Claude Code**: https://docs.anthropic.com/claude/docs/claude-code

---

## Licença

Este projeto é de uso interno. Configurações podem ser adaptadas conforme necessidade.

**Versão:** 2.0.0
**Última atualização:** 06/02/2026
**Compatível com:** Claude Code VSCode Extension (todas as versões)
