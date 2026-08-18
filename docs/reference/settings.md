# Settings

Fonte única das chaves de `config/settings.template.json`. Esse arquivo é copiado
para `~/.claude/settings.json` (ou para `.claude/settings.json` do projeto) durante
a instalação — veja `docs/setup/` para o passo a passo.

## Chaves do template

### `hooks`

Comandos que o Claude Code executa automaticamente em pontos do ciclo de vida de
uma ferramenta. O template traz dois:

- `PreToolUse` com matcher `Bash` → roda `rtk hook claude`, que intercepta comandos
  de shell para o proxy de economia de tokens (RTK).
- `PostToolUse` com matcher `Edit|Write` → roda `prettier-hook.py`, que formata o
  arquivo alterado.

Hooks rodam **sempre**, sem confirmação — só adicione hooks em que você confia.

### `enabledPlugins`

Mapa `"plugin@marketplace": true` com os 12 plugins habilitados por padrão. Lista
completa e o que cada um faz: [`plugins.md`](plugins.md).

### `extraKnownMarketplaces`

Registra marketplaces de plugin que não são a marketplace oficial (veja
[`plugins.md`](plugins.md) para qual é). O template registra `caveman`, apontando
para o repositório GitHub de onde o plugin `caveman@caveman` é instalado. Toda vez
que um plugin de fora da marketplace oficial for adicionado a `enabledPlugins`, a
marketplace correspondente precisa existir aqui.

### `permissions`

Controla quais comandos rodam sem pedir confirmação. `allow` é uma lista de
padrões (`Bash(gh pr *)`, por exemplo, libera qualquer subcomando de `gh pr`).
`defaultMode: "auto"` faz o Claude Code seguir em frente sem parar para perguntas
de esclarecimento sempre que puder tomar uma decisão razoável sozinho — ele ainda
para quando está genuinamente bloqueado.

### `model`

Define o modelo padrão da sessão. Aceita um alias curto (`"haiku"`, `"sonnet"`,
`"opus"` — resolvido para a versão atual de cada família) ou um identificador
completo de modelo. Detalhes e identificadores atuais: [`modelos.md`](modelos.md).

### `effortLevel`

Controla o quanto o modelo "pensa" antes de responder — mais esforço tende a gerar
respostas mais completas ao custo de mais tokens e latência. O template usa
`"medium"` como equilíbrio padrão entre custo e qualidade.

### `theme`

Tema visual do terminal (`"dark"` no template). Puramente cosmético, não afeta
comportamento.

## O que o template não traz, e por quê

### `env`

O template **não** tem bloco `env`. Variável de ambiente com segredo (token de
API, senha, chave privada) não pertence a um arquivo versionado — qualquer pessoa
com acesso ao repositório passaria a ter acesso ao segredo, e o histórico do git
guarda a chave para sempre mesmo que ela seja removida depois. Segredos vão em
`settings.local.json` (veja abaixo) ou em variáveis de ambiente do shell, nunca em
`settings.template.json`.

### `statusLine`

Removido porque a versão original apontava para um caminho de plugin com hash de
instalação (algo como `~/.claude/plugins/cache/<hash>/statusline.sh`) — um caminho
que só existe na máquina onde o plugin foi instalado originalmente. Versionar esse
caminho quebraria a status line de qualquer outra pessoa que copiasse o template.
Para reativar, instale o plugin que fornece a status line desejada e deixe o
próprio plugin escrever o caminho correto no seu `settings.local.json` local.

### `settings.local.json`

Existe, e o Claude Code o lê automaticamente junto com `settings.json` — as duas
camadas são mescladas, com `settings.local.json` sobrescrevendo o que estiver em
conflito. É o lugar certo para tokens, caminhos de máquina específicos e qualquer
override pessoal. Está no `.gitignore` (`settings.local.json` e `*.local.json`) e
**nunca** deve ser versionado.
