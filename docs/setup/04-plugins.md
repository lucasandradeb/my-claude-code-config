# 04 — Plugins

> Tempo estimado: 3 min

O instalador já habilitou os 12 plugins do template em `enabledPlugins` dentro do
seu `settings.json` — não há ação manual aqui. Esta etapa é só confirmar que
carregaram.

Para a lista completa dos 12 plugins, para que cada um serve e quando usá-lo,
veja [`docs/reference/plugins.md`](../reference/plugins.md). Não repetimos a
tabela aqui — essa referência é a fonte única.

## Confirmar que os 12 plugins carregaram

1. No VSCode, abra o Command Palette (`Cmd+Shift+P` / `Ctrl+Shift+P`).
2. Digite "Claude: List Installed Plugins".
3. Confira que os 12 plugins do template aparecem habilitados.

Se algum estiver faltando, reinicie o VSCode completamente e repita — plugins
recém-mesclados no `settings.json` só aparecem depois de um restart completo da
extensão, não apenas de uma nova conversa.

## Se algo não carregar

Um plugin fora do marketplace padrão (é o caso de um dos 12) depende de uma
entrada em `extraKnownMarketplaces` apontando para a fonte — o instalador já
inclui isso no merge. Se o Command Palette não listar todos os 12 mesmo após o
restart, a etapa final desta trilha (`/preflight`) e sua tabela de
diagnóstico ajudam a isolar a causa.

---

**Próximo:** [CLAUDE.md](05-claude-md.md)
