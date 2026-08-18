# Contribuindo

Este repositório versiona a configuração compartilhada do Claude Code do
time. Ele não é editado diretamente: a fonte de verdade do dia a dia é a sua
pasta local `~/.claude/`, e o repositório é um espelho sanitizado dela.
Entender essa direção é o pré-requisito para qualquer contribuição.

## Como propor uma mudança

O fluxo é sempre o mesmo, independente do que você está mudando — um skill
novo, um ajuste de `CLAUDE.md`, um MCP server a mais:

1. **Altere em `~/.claude/`** — edite o skill, agent, command ou arquivo de
   configuração diretamente na sua instalação local, do mesmo jeito que você
   já faz para testar mudanças no dia a dia.
2. **`make sync`** — copia `~/.claude/` para este repositório, sanitizando
   segredos, caminhos absolutos e dados específicos da sua máquina no
   caminho. Revise o resultado com `git diff` antes de continuar.
3. **`make check`** — roda a suíte de testes, a varredura de segredo
   (gitleaks + padrões proibidos), shellcheck nos scripts e a checagem de
   links da documentação. Só prossiga se tudo passar.
4. **Commit** — Conventional Commits, corpo explicando o porquê (veja
   [Formato de commit](#formato-de-commit) abaixo).

Pular a etapa 2 e editar os arquivos do repositório diretamente é o erro que
motivou esta reestruturação: o repositório volta a divergir da configuração
real que as pessoas usam, e ninguém percebe até o próximo `sync`.

### Pré-condição do sync

`make sync` só escreve no repositório depois de verificar a área de
preparação inteira contra `scripts/lib/patterns.txt`. Se qualquer artefato
local — configuração, skill, agent, command — contiver um padrão proibido
(nome interno de cliente/empresa, token, caminho absoluto, segredo), o sync
aborta e nada é escrito. Isso é proposital: o objetivo é nunca deixar esse
conteúdo chegar perto de um commit. Se isso acontecer com você, limpe o
artefato local apontado na mensagem de erro e rode `make sync` de novo — veja
[`docs/troubleshooting.md`](docs/troubleshooting.md#make-sync-aborta-mesmo-sem-eu-ter-mexido-em-segredo).

## Por que `config/*.template.json` nunca é editado à mão

Os arquivos em `config/` (`settings.template.json`,
`mcp-servers.template.json`) são a saída sanitizada da sua
`~/.claude/settings.json` e do seu `~/.claude.json`, gerada por
`scripts/sync.sh` via `scripts/lib/sanitize.sh`. Editá-los diretamente no
repositório cria duas fontes de verdade que divergem na próxima vez que
alguém rodar `make sync`: a edição manual seria silenciosamente sobrescrita
pelo próximo sync de outra pessoa, ou o template ficaria fora de sincronia
com o que `scripts/install.sh` espera aplicar. Se um template precisa mudar,
a mudança acontece na sua configuração local primeiro, e chega ao
repositório através de `make sync` como qualquer outra mudança.

## Como adicionar um item à denylist

`scripts/lib/denylist.txt` lista artefatos (skills, agents, commands) que
nunca devem sair da máquina local — coisas específicas de um projeto interno
ou de um cliente, por exemplo. `sync.sh` lê esse arquivo e pula qualquer
artefato cujo nome (sem extensão) apareça nele.

Para adicionar um item:
1. Abra `scripts/lib/denylist.txt`.
2. Acrescente uma linha com o nome do artefato — o basename do arquivo `.md`
   (para commands/agents) ou do diretório (para skills), sem barra.
3. Rode `make sync` — o relatório deve mostrar o item marcado como
   `denylist`, não `copiar`.
4. Commit a mudança em `scripts/lib/denylist.txt` normalmente.

Para bloquear um padrão de texto (token, segredo, nome interno) em vez de um
artefato inteiro, o arquivo correto é `scripts/lib/patterns.txt`, consumido
por `scan_secrets` — mesmo fluxo de edição e commit.

## Formato de commit

Conventional Commits (`tipo: descrição breve`), corpo explicando o **porquê**
da mudança, não o que ela faz linha a linha — o diff já mostra o que mudou.

Tipos usados neste repositório: `feat`, `fix`, `refactor`, `docs`, `test`,
`chore`.

```
docs: adiciona secao de troubleshooting sobre denylist desatualizada

Um agent antigo ainda citava um nome interno de cliente que passou a
ser padrao proibido depois que o agent foi escrito. Sem essa secao,
quem esbarrar nisso nao teria como saber que a causa e generica, nao
um segredo de verdade vazando.
```

## Testes

Antes de commitar, `make check` deve passar. Ele roda, em sequência:
`make test` (suíte de testes de shell), varredura de segredo, shellcheck e
checagem de links. Cada um desses testes documenta, no próprio nome do
arquivo em `tests/`, o que ele garante — vale ler o teste antes de mudar o
comportamento que ele cobre.
