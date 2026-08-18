# Sistema de Memória do Claude Code

Este arquivo virou um resumo. A explicação completa — o que é, por que importa,
como o knowledge graph funciona, os tipos de memória, instalação e comandos —
está em [`docs/concepts/memoria.md`](../docs/concepts/memoria.md).

Resumo rápido: o Claude pode lembrar de arquitetura, decisões técnicas e
convenções do time entre conversas, tanto via Memory Server (knowledge graph)
quanto via arquivos Markdown em `~/.claude/projects/<projeto>/memory/`. Para
criar uma memória, basta pedir na conversa: "Lembre que...". Os arquivos de
exemplo desta pasta (`memory/exemplos/`) mostram o formato esperado.
