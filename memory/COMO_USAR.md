# Sistema de Memória do Claude Code

## O que é?

Imagine que você tem um caderno de anotações que o Claude lê automaticamente toda vez que você abre uma conversa. É exatamente isso que o sistema de memória faz — você escreve uma vez, e o Claude "lembra" para sempre.

## Por que isso importa?

Sem memória, toda conversa começa do zero. Você precisa explicar de novo:
- "O projeto usa Clean Architecture"
- "A auth-api roda na porta 5003"
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
| `project` | Arquitetura, decisões técnicas, contexto dos projetos | "auth-api usa JWT com refresh token no Redis" |
| `feedback` | Lições aprendidas, erros que não devem se repetir | "Nunca printar credenciais no terminal" |
| `reference` | Onde encontrar informações externas | "Bugs do pipeline ficam no board X do Jira" |

## Instalação

### Passo 1: Criar a pasta de memória do seu projeto

Abra o terminal e rode:

```bash
# Substitua <nome-do-projeto> pelo nome real
# Exemplo: se trabalha em auth-api:
mkdir -p ~/.claude/projects/-Users-seuusuario-github-projects-auth-api/memory/
```

**Dica**: Não sabe o nome exato da pasta? Abra o Claude Code dentro do projeto e pergunte:
```
Qual é o caminho exato da pasta de memória deste projeto?
```

### Passo 2: Criar o arquivo de índice

Crie o arquivo `MEMORY.md` dentro da pasta:
```bash
touch ~/.claude/projects/<caminho>/memory/MEMORY.md
```

### Passo 3: Criar suas primeiras memórias

Copie os arquivos de exemplo desta pasta (`memory/exemplos/`) e edite com suas informações.

## Exemplo real — Oliv-e Health

Veja os exemplos em `memory/exemplos/` com as memórias prontas para os projetos da Oliv-e.

## Como pedir pro Claude salvar algo

Simplesmente peça na conversa:

```
"Lembre que a questionnaire-api tem uma peculiaridade: a porta dela é 22771, diferente de todas as outras"
```

O Claude vai criar um arquivo de memória automaticamente.

## Dica importante

Memórias são específicas por projeto. Uma memória criada dentro do `auth-api` não vai aparecer quando você abrir o `account-api`. Para memórias globais (que valem em qualquer projeto), use o `~/.claude/CLAUDE.md` global.
