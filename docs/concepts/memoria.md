# Memória — conhecimento persistente entre conversas

Sem memória, toda conversa começa do zero. Você precisa explicar de novo: "o
projeto usa Clean Architecture", "a API de autenticação roda na porta X", "não
esqueça de rodar o docker antes". Com memória, o Claude já sabe tudo isso antes de
você falar.

Este repositório usa a **memória nativa do Claude Code**, baseada em arquivos
Markdown por projeto (descrita abaixo). O MCP server `memory` (knowledge graph) saiu
do template: ele duplicava a memória nativa e custava tokens de contexto em toda
sessão sem uso medido — veja [`mcp-servers.md`](../reference/mcp-servers.md#removidos-e-por-quê).

## Por que memória em arquivos basta

- O índice `MEMORY.md` é carregado em toda sessão, então o Claude sabe o que
  existe sem ferramenta extra.
- Os arquivos são texto: você lê, edita e versiona como quiser.
- Pedir "lembre que X" na conversa já cria o arquivo correspondente.

## Tipos de informação que valem a pena guardar

1. **Arquitetura do projeto** — "A API de auth usa JWT; refresh tokens ficam no
   Redis; rate limiting de 5 tentativas."
2. **Decisões técnicas** — "Escolhemos Dapper em vez de EF Core por performance em
   queries complexas."
3. **Convenções do time** — "Services terminam com `Service`; DTOs ficam em `/DTOs`."

## Benefícios em projetos reais

1. **Onboarding de novos desenvolvedores** — Claude explica a arquitetura e entende
   as convenções do time automaticamente.
2. **Consistência de código** — lembra padrões usados anteriormente e sugere
   implementações alinhadas com o projeto.
3. **Continuidade entre conversas** — não precisa re-explicar arquitetura nem
   decisões passadas.

## Estrutura de arquivos na prática

A memória fica em arquivos Markdown por projeto:

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
