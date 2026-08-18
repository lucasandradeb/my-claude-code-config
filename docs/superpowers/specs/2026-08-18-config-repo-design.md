# Design — Reestruturação do repositório de configuração do Claude Code

**Data:** 18/08/2026
**Status:** aprovado, aguardando plano de implementação
**Repositório:** `my-claude-code-config`

---

## 1. Problema

O repositório distribui a configuração do Claude Code para o time, mas hoje:

- **Cobertura parcial.** Contém 3 dos ~20 artefatos que existem em `~/.claude/`. Faltam o command `/review`, a skill `spec-driven`, o `settings.json`, a configuração dos 11 MCP servers e o `RTK.md` — este último referenciado por `@RTK.md` dentro do `CLAUDE.md`, de modo que quem clona o repositório recebe uma referência quebrada.
- **Documentação monolítica.** 2.869 das 3.614 linhas estão em três arquivos de raiz (`README.md`, `GUIA_CONFIGURACAO_TIME.md`, `EXEMPLO_CONFIGURACAO.md`) que se sobrepõem. A lista de plugins aparece nos três, e as três cópias já divergiram.
- **Sem trilha de onboarding.** Não existe caminho ordenado para um desenvolvedor novo sair do zero até a configuração completa.
- **Conteúdo factualmente vencido.** Nomes de modelo e tabela de preços desatualizados; link para `CROSS_PLATFORM.md`, arquivo que não existe.
- **Sem metadados de repositório.** Sem `LICENSE` (embora o README tenha seção "Licença"), sem `.gitignore`, sem CI.
- **Instalação manual.** Cópia arquivo a arquivo, com variantes por sistema operacional descritas em prosa.

## 2. Restrição dominante: segredos

A configuração local contém credenciais em texto puro:

| Arquivo | Conteúdo sensível |
|---|---|
| `~/.claude/settings.json` | `env.MYSQL_PASSWORD` (senha real), nomes de projeto GCP, connection names de Cloud SQL dev e prod |
| `~/.claude/settings.local.json` | senha da conta Metabase e quatro session tokens embutidos em regras de permissão `curl` |
| `~/.claude.json` | `GITHUB_PERSONAL_ACCESS_TOKEN`, `BRAVE_API_KEY` |

O repositório é compartilhado externamente. Nenhum desses valores pode entrar — nem como exemplo com valor trocado, porque o histórico do git preserva erro de cópia.

Consequências de projeto, todas obrigatórias:

1. Nenhum arquivo de configuração é copiado do local para o repositório sem passar por sanitização.
2. `settings.local.json` não entra no repositório sob nenhuma forma.
3. O CI executa varredura de segredo em todo push e falha o build ao encontrar um.

Fora do escopo deste trabalho, mas registrado: rotacionar a senha do Metabase e o PAT do GitHub, e mover `MYSQL_PASSWORD` para fora do `settings.json`.

## 3. Decisões

| # | Decisão | Alternativas descartadas |
|---|---|---|
| D1 | Artefatos específicos da Oliv-e ficam **fora** do repositório | Anonimizar como template; repositório privado paralelo |
| D2 | Instalação por **script idempotente com merge**, macOS/Linux e Windows | Manual com documentação melhor; script só para Unix |
| D3 | Documentação organizada por **jornada + catálogo** | Por camada; Diátaxis |
| D4 | Plano de melhorias pessoal vive **fora do repositório**, em `~/.claude/MELHORIAS.md` | Roadmap público; ambos |
| D5 | Sincronização **unidirecional**, local → repositório | Bidirecional |
| D6 | Preços de modelo **não são versionados** — o documento linka a página oficial | Manter tabela e atualizar periodicamente |

D1 exclui: skills `jira-task` e `olive-design-system`; agents `clinical-metrics-analyst` e `health-data-security-reviewer`. O agent `pr-reviewer` entra sanitizado (a versão local menciona "Oliv-e Health"; a genérica já existe no repositório).

D5: a direção única evita conflito silencioso. A detecção de divergência é um relatório local, nunca uma escrita automática.

D6 remove a dívida em vez de administrá-la. Número fixo em documentação vence sozinho.

## 4. Arquitetura

```
my-claude-code-config/
├── README.md                  # ~150 linhas: o que é, quickstart, índice
├── CONTRIBUTING.md
├── LICENSE                    # MIT
├── .gitignore
├── Makefile                   # install, sync, check
├── .github/workflows/ci.yml
│
├── config/                    # o que o Claude consome
│   ├── settings.template.json
│   ├── mcp-servers.template.json
│   ├── CLAUDE.md
│   └── RTK.md
│
├── skills/spec-driven/
├── agents/{pr-reviewer,domain-analyst}.md
├── commands/{preflight,review}.md
├── memory/                    # inalterado
│
├── scripts/{install.sh,install.ps1,sync.sh,check-drift.sh}
│
└── docs/
    ├── setup/                 # trilha ordenada, ~10 min por arquivo
    │   ├── 00-visao-geral.md
    │   ├── 01-pre-requisitos.md
    │   ├── 02-instalacao.md
    │   ├── 03-mcp-servers.md
    │   ├── 04-plugins.md
    │   ├── 05-claude-md.md
    │   ├── 06-skills-agents-commands.md
    │   ├── 07-memoria.md
    │   └── 08-verificacao.md
    ├── reference/             # catálogo, consultado e não lido
    │   ├── mcp-servers.md
    │   ├── plugins.md
    │   ├── skills.md
    │   ├── agents.md
    │   ├── commands.md
    │   ├── settings.md
    │   └── modelos.md
    ├── concepts/              # o porquê
    │   ├── o-que-e-claude-code.md
    │   ├── mcp-vs-plugin.md
    │   ├── economia-de-tokens.md
    │   └── memoria.md
    ├── troubleshooting.md
    └── superpowers/specs/     # design docs (este arquivo)
```

`config/` separa artefato de documentação. Hoje ambos ocupam a raiz, e não há sinal de qual arquivo é copiado para `~/.claude/` e qual é apenas lido.

`docs/setup/` é numerado porque atende um público que não sabe a ordem. `docs/reference/` não é numerado porque atende acesso aleatório.

### Fluxo do desenvolvedor novo

```
git clone → docs/setup/00 → 01 pré-requisitos → ./scripts/install.sh
   → 03 tokens de MCP (única etapa manual) → 08 verificação (/preflight)
```

### Fluxo do mantenedor

```
altera ~/.claude/ → make sync (sanitiza + copia) → make check (gitleaks, links, shellcheck, drift) → commit
```

## 5. Componentes

### 5.1 `config/settings.template.json`

Derivado de `~/.claude/settings.json`, com o bloco `env` inteiro removido (substituído por `{}`, documentado em `docs/reference/settings.md`).

Preserva: `hooks` (RTK em `PreToolUse`, prettier em `PostToolUse`), `statusLine`, `enabledPlugins` (12), `extraKnownMarketplaces`, `permissions.allow` filtrado para padrões seguros, `effortLevel`, `theme`, `model`.

Remove: `env` completo, `autoMode.environment` (descreve a máquina do autor), qualquer `permissions.allow` com caminho absoluto de usuário, host interno ou credencial.

### 5.2 `config/mcp-servers.template.json`

Os 11 servers de `~/.claude.json`: `filesystem`, `git`, `github`, `memory`, `sqlite`, `sequential-thinking`, `brave-search`, `fetch`, `serena`, `docker`, `supabase`.

Valores de credencial expressos como `"${GITHUB_PERSONAL_ACCESS_TOKEN}"` e `"${BRAVE_API_KEY}"`. Caminhos absolutos do autor substituídos por placeholder.

### 5.3 `scripts/install.sh` e `install.ps1`

Contrato de saída:

```
$ ./install.sh

  backup    ~/.claude/settings.json -> settings.json.bak.20260818
  merge     hooks.PreToolUse (rtk)            [novo]
  merge     enabledPlugins (12)               [novo]
  skip      env.MYSQL_PASSWORD                [segredo: nao copiado]
  copy      skills/spec-driven/               [novo]
  copy      agents/pr-reviewer.md             [novo]
  copy      commands/preflight.md, review.md  [novo]

  ACAO MANUAL:
    - GITHUB_PERSONAL_ACCESS_TOKEN nao definido
    - BRAVE_API_KEY nao definido
    ver docs/setup/03-mcp-servers.md
```

Requisitos:

- **Nunca sobrescreve `settings.json`.** Merge campo a campo via `jq`; conflito de valor preserva o do usuário e reporta `[conflito]`.
- **Backup datado** antes de qualquer escrita.
- **Idempotente.** Segunda execução reporta `[ok]` em todas as linhas e não altera arquivo.
- **Falha limpa.** Ausência de `jq` interrompe com mensagem acionável antes de escrever qualquer coisa.
- **Nunca escreve credencial.** Apenas reporta o que falta definir.

`install.ps1` mantém o mesmo contrato de saída e as mesmas garantias no Windows.

### 5.4 `scripts/sync.sh`

Copia de `~/.claude/` para o repositório: `skills/`, `agents/`, `commands/`, `settings.json`, e os `mcpServers` de `~/.claude.json`.

Aplica, nesta ordem:

1. **Denylist de artefato** — `jira-task`, `olive-design-system`, `clinical-metrics-analyst`, `health-data-security-reviewer` nunca são copiados (D1).
2. **Sanitização** — remove `env`, `autoMode`, caminhos absolutos de usuário; substitui valor de credencial por placeholder.
3. **Verificação** — executa a mesma varredura do CI sobre o resultado. Detecção de segredo aborta o sync sem escrever.

`settings.local.json` está excluído por construção: não aparece na lista de origem.

### 5.5 `scripts/check-drift.sh`

Somente leitura. Compara `~/.claude/` com o repositório e reporta o que divergiu, em ambas as direções. Não escreve. Executa localmente; o CI não tem acesso à máquina do mantenedor.

### 5.6 `.github/workflows/ci.yml`

| Job | Ferramenta | Falha quando |
|---|---|---|
| `secrets` | gitleaks | qualquer padrão de credencial no diff ou no histórico |
| `links` | lychee | link relativo ou externo quebrado |
| `shell` | shellcheck | erro nos scripts `.sh` |

O job `links` elimina estruturalmente a classe de defeito que produziu a referência a `CROSS_PLATFORM.md`.

### 5.7 `Makefile`

`make install` → `scripts/install.sh`
`make sync` → `scripts/sync.sh`
`make check` → gitleaks + lychee + shellcheck + `check-drift.sh`

## 6. Migração de conteúdo

| Origem | Destino |
|---|---|
| `README.md:20-136` | `concepts/o-que-e-claude-code.md`, `reference/modelos.md` |
| `README.md:137-343` | `reference/mcp-servers.md`, `concepts/mcp-vs-plugin.md` |
| `README.md:344-438` | `concepts/memoria.md` |
| `README.md:439-754` + `GUIA:238-289` + `EXEMPLO:142-289` | **fonte única:** `reference/plugins.md` |
| `README.md:755-879` | `reference/skills.md` |
| `README.md:958-1139` | `concepts/economia-de-tokens.md` |
| `README.md:1241-1323` | `README.md` (seção Referências, enxuta) |
| `GUIA:19-330` | `setup/01-02`, `setup/05` |
| `GUIA:329-514` | `setup/06`, `reference/{agents,commands}.md` |
| `GUIA:515-662` | `setup/07`, `concepts/memoria.md` |
| `GUIA:663-708` | `setup/08-verificacao.md` |
| `GUIA:709-790` | `troubleshooting.md` |
| `EXEMPLO_CONFIGURACAO.md` | `config/*.template.json`, `reference/settings.md` |

A consolidação da lista de plugins em `reference/plugins.md` resolve a divergência tripla. Os documentos de `setup/` linkam para ela em vez de repetir.

### Correções factuais

- `LICENSE` MIT criado; a seção "Licença" do README passa a corresponder ao arquivo.
- Nomes de modelo atualizados para a família Claude 5 em `reference/modelos.md`. A skill `claude-api` deve ser consultada durante a escrita — os identificadores não podem ser escritos de memória.
- Tabela de preços de `README.md:975-977` removida; substituída por link para a página oficial (D6).
- Versionamento unificado: uma versão para o repositório, marcada por tag git, em vez de quatro versões independentes nos arquivos.

### Fora de escopo, por decisão explícita

`CROSS_PLATFORM.md` não é criado. A referência atual desaparece porque o `README.md` é reescrito, não por remoção deliberada.

## 7. Plano de melhorias pessoal

Escrito em `~/.claude/MELHORIAS.md`, fora do controle de versão (D4). Backlog priorizado:

**Crítico**
- Rotacionar senha do Metabase, PAT do GitHub e senha do MySQL
- Limpar `settings.local.json` — 24 entradas, várias com credencial embutida em `curl`

**Alto**
- `env.ANTHROPIC_MODEL: "claude-sonnet-4-6"` conflita com `"model": "opus[1m]"`. A variável de ambiente prevalece; a sessão pode estar rodando Sonnet enquanto a configuração declara Opus.

**Médio**
- Quatro documentos duplicados soltos em `~/.claude/` (`MINHAS_CONFIGURACOES.md`, `README_CONFIGURACAO.md`, `GUIA_CONFIGURACAO_TIME.md`) — o repositório passa a ser fonte única
- MCP servers sem uso observado no histórico: `sqlite`, `docker`, `fetch`, `supabase`. Avaliar remoção ou adoção.

**Baixo**
- Hooks adicionais a avaliar
- Skills próprias a criar

## 8. Verificação

O trabalho está concluído quando:

1. `make check` passa — sem segredo, sem link quebrado, sem erro de shell.
2. `./scripts/install.sh` executado duas vezes seguidas em máquina limpa produz o mesmo estado, e a segunda execução não altera arquivo.
3. `./scripts/install.sh` sobre um `~/.claude/settings.json` preexistente e customizado preserva as customizações.
4. `grep -rE 'oliv-e|MYSQL_PASSWORD|Metabase-Session|ghp_'` no repositório e no histórico não retorna nada.
5. Um desenvolvedor seguindo `docs/setup/00` até `08` chega ao `/preflight` verde sem consultar fonte externa a este repositório.
6. Cada plugin, MCP server, skill, agent e command é descrito em exatamente um lugar.

## 9. Ordem de execução

1. Guard-rails — `LICENSE`, `.gitignore`, `.github/workflows/ci.yml`, `Makefile`
2. `config/` sanitizado — templates, `CLAUDE.md`, `RTK.md`
3. Artefatos — `skills/`, `agents/`, `commands/` sincronizados sob a denylist
4. Scripts — `install.sh`, `install.ps1`, `sync.sh`, `check-drift.sh`
5. Documentação — `docs/`, seguindo o mapa da seção 6
6. `README.md` reescrito como índice
7. `~/.claude/MELHORIAS.md`

Guard-rails primeiro: a varredura de segredo precisa existir antes de qualquer arquivo de configuração ser movido para o repositório.

## 10. Escala

~25 arquivos novos, ~3.600 linhas redistribuídas, 4 scripts, 1 workflow de CI.
