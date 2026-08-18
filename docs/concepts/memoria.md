# Memória — conhecimento persistente entre conversas

Sem memória, toda conversa começa do zero. Você precisa explicar de novo: "o
projeto usa Clean Architecture", "a API de autenticação roda na porta X", "não
esqueça de rodar o docker antes". Com memória, o Claude já sabe tudo isso antes de
você falar.

O Memory Server merece destaque especial pela sua importância em projetos de
longo prazo.

## Como funciona

O Memory Server cria um **knowledge graph** (grafo de conhecimento) estruturado:

```
┌──────────────────────────────────────────────┐
│           KNOWLEDGE GRAPH                     │
├──────────────────────────────────────────────┤
│                                                │
│  [UserService] ─────"usa"────→ [Repository]   │
│       │                             │         │
│       │                             │         │
│    "implementa"                "persiste"     │
│       │                             │         │
│       ↓                             ↓         │
│  [CQRS Pattern]              [PostgreSQL]     │
│                                                │
│  Observações:                                 │
│  - UserService: "Validação com FluentVal"     │
│  - Repository: "Usa Dapper para queries"      │
└──────────────────────────────────────────────┘
```

## Tipos de informação armazenada

1. **Arquitetura do projeto**
   ```
   Entidade: "Sistema de Autenticação"
   Tipo: Architecture
   Observações:
     - Usa JWT para tokens
     - Refresh tokens armazenados no Redis
     - Rate limiting com 5 tentativas
   ```

2. **Decisões técnicas**
   ```
   Entidade: "Escolha do ORM"
   Tipo: Decision
   Observações:
     - Escolhemos Dapper ao invés de EF Core
     - Razão: Performance em queries complexas
     - Data: Janeiro 2026
   ```

3. **Convenções do time**
   ```
   Entidade: "Padrão de Nomenclatura"
   Tipo: Convention
   Observações:
     - Services terminam com "Service"
     - Repositories terminam com "Repository"
     - DTOs em pasta separada /DTOs
   ```

## Comandos úteis

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

## Benefícios em projetos reais

1. **Onboarding de novos desenvolvedores** — Claude explica arquitetura usando
   memórias e entende convenções do time automaticamente.
2. **Consistência de código** — lembra padrões usados anteriormente e sugere
   implementações alinhadas com o projeto.
3. **Documentação viva** — o conhecimento não fica desatualizado; evolui junto
   com o código.
4. **Continuidade entre conversas** — não precisa re-explicar arquitetura,
   mantém contexto de decisões passadas.

## Estrutura de arquivos na prática

Além do Memory Server (knowledge graph via MCP), este repositório também usa
memória baseada em arquivos Markdown por projeto:

```
~/.claude/projects/<nome-do-projeto>/memory/
├── MEMORY.md          ← índice (carregado em toda sessão)
├── user_meu_nome.md   ← quem sou eu, meu papel
├── projeto_arch.md    ← arquitetura dos projetos
└── feedback_xyz.md    ← lições aprendidas
```

O `MEMORY.md` é o índice — uma linha por memória. O Claude lê esse arquivo em
toda sessão para saber o que existe.

### Tipos de memória em arquivo

| Tipo | O que guardar | Exemplo |
|------|--------------|---------|
| `user` | Seu perfil, stack preferida, forma de comunicação | "Prefiro explicações com exemplos de código" |
| `project` | Arquitetura, decisões técnicas, contexto dos projetos | "A API de auth usa JWT com refresh token no Redis" |
| `feedback` | Lições aprendidas, erros que não devem se repetir | "Nunca commitar o arquivo .env.local" |
| `reference` | Onde encontrar informações externas | "Bugs do pipeline ficam no board X do Linear" |

### Instalação

**Passo 1 — criar a pasta de memória do projeto**:

```bash
# Substitua <caminho> pelo caminho real do projeto
# Dica: abra o projeto no Claude Code e pergunte "qual é o caminho exato da pasta de memória?"
mkdir -p ~/.claude/projects/<caminho>/memory/
```

**Passo 2 — criar o arquivo de índice**:

```bash
touch ~/.claude/projects/<caminho>/memory/MEMORY.md
```

**Passo 3 — criar suas primeiras memórias**: copie os arquivos de exemplo de
`memory/exemplos/` e edite com suas informações.

### Como pedir pro Claude salvar algo

Simplesmente peça na conversa:

```
"Lembre que a nossa fila de mensagens usa o exchange X e a routing key Y"
```

O Claude vai criar um arquivo de memória automaticamente.

### Escopo: projeto vs. global

Memórias de arquivo são específicas por projeto. Uma memória criada dentro do
`projeto-A` não aparece quando você abre o `projeto-B`. Para memórias globais
(que valem em qualquer projeto), use o `~/.claude/CLAUDE.md` global.
