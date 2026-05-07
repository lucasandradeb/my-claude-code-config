# Sistema de Memória do Claude Code

## O que é?

Imagine que você tem um caderno de anotações que o Claude lê automaticamente toda vez que você abre uma conversa. É exatamente isso que o sistema de memória faz — você escreve uma vez, e o Claude "lembra" para sempre.

## Por que isso importa?

Sem memória, toda conversa começa do zero. Você precisa explicar de novo:
- "O projeto usa Clean Architecture"
- "A API de autenticação roda na porta X"
- "Não esqueça de rodar o docker antes"

Com memória, o Claude já sabe tudo isso antes de você falar.

## Como funciona na prática?

### Estrutura de arquivos

```
~/.claude/projects/<nome-do-projeto>/memory/
├── MEMORY.md          ← índice (carregado em toda sessão)
├── user_meu_nome.md   ← quem sou eu, meu papel
├── projeto_arch.md    ← arquitetura dos projetos
└── feedback_xyz.md    ← lições aprendidas
```

O `MEMORY.md` é o índice — uma linha por memória. O Claude lê esse arquivo em toda sessão para saber o que existe.

### Tipos de memória

| Tipo | O que guardar | Exemplo |
|------|--------------|---------|
| `user` | Seu perfil, stack preferida, forma de comunicação | "Prefiro explicações com exemplos de código" |
| `project` | Arquitetura, decisões técnicas, contexto dos projetos | "A API de auth usa JWT com refresh token no Redis" |
| `feedback` | Lições aprendidas, erros que não devem se repetir | "Nunca commitar o arquivo .env.local" |
| `reference` | Onde encontrar informações externas | "Bugs do pipeline ficam no board X do Linear" |

## Instalação

### Passo 1: Criar a pasta de memória do seu projeto

Abra o terminal e rode:

```bash
# Substitua <caminho> pelo caminho real do projeto
# Dica: abra o projeto no Claude Code e pergunte "qual é o caminho exato da pasta de memória?"
mkdir -p ~/.claude/projects/<caminho>/memory/
```

### Passo 2: Criar o arquivo de índice

```bash
touch ~/.claude/projects/<caminho>/memory/MEMORY.md
```

### Passo 3: Criar suas primeiras memórias

Copie os arquivos de exemplo desta pasta (`memory/exemplos/`) e edite com suas informações.

## Como pedir pro Claude salvar algo

Simplesmente peça na conversa:

```
"Lembre que a nossa fila de mensagens usa o exchange X e a routing key Y"
```

O Claude vai criar um arquivo de memória automaticamente.

## Dica importante

Memórias são específicas por projeto. Uma memória criada dentro do `projeto-A` não vai aparecer quando você abrir o `projeto-B`. Para memórias globais (que valem em qualquer projeto), use o `~/.claude/CLAUDE.md` global.
