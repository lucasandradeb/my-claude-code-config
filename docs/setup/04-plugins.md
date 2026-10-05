# 04 — Plugins

> Tempo estimado: 3 min

O instalador já gravou as 16 entradas de `enabledPlugins` do template no seu
`settings.json` — 10 habilitadas e 6 explicitamente desabilitadas. Não há ação
manual aqui. Esta etapa é só confirmar que os 10 habilitados carregaram.

Para a lista completa, para que cada plugin serve, quando usá-lo e por que seis
estão desabilitados,
veja [`docs/reference/plugins.md`](../reference/plugins.md). Não repetimos a
tabela aqui — essa referência é a fonte única.

## Confirmar que os 10 plugins habilitados carregaram

1. No VSCode, abra o Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`).
2. Digite "Claude: List Installed Plugins".
3. Confira que os 10 plugins habilitados do template aparecem na lista.

Se algum estiver faltando, reinicie o VSCode completamente e repita — plugins
recém-mesclados no `settings.json` só aparecem depois de um restart completo da
extensão, não apenas de uma nova conversa.

## Se algo não carregar

Um plugin fora do marketplace padrão (é o caso de um dos habilitados) depende de uma
entrada em `extraKnownMarketplaces` apontando para a fonte — o instalador já
inclui isso no merge. Se o Command Palette não listar todos os 10 mesmo após o
restart, a etapa final desta trilha (`/preflight`) e sua tabela de
diagnóstico ajudam a isolar a causa.

---

**Próximo:** [CLAUDE.md](05-claude-md.md)
