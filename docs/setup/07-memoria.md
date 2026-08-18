# 07 — Memória

> Tempo estimado: 5 min

Memória é o que evita reexplicar o mesmo contexto em toda conversa nova — "o
projeto usa Clean Architecture", "a API de auth roda na porta X". O que ela é e
por que importa está explicado em
[`docs/concepts/memoria.md`](../concepts/memoria.md); esta etapa é só a
instalação prática.

## Instalação

Siga o passo a passo completo em
[`docs/concepts/memoria.md#instalação`](../concepts/memoria.md#instalação):
criar a pasta `~/.claude/projects/<projeto>/memory/`, criar o `MEMORY.md` de
índice e copiar os exemplos de `memory/exemplos/`.

Resumo do que você vai fazer lá (os comandos exatos estão no link acima):

1. Descobrir o caminho da pasta de memória do projeto atual — pergunte ao
   Claude, dentro do projeto, "qual é o caminho exato da minha pasta de
   memory?".
2. Criar a estrutura de pastas.
3. Copiar `memory/exemplos/MEMORY.md`, `memory/exemplos/user_meu_perfil.md` e
   `memory/exemplos/projeto_portas_servicos.md` deste repositório para lá.
4. Editar os arquivos copiados com suas informações reais.

## Por que isso é por projeto, não global

Memórias de arquivo são específicas por projeto — uma memória criada no
`projeto-A` não aparece quando você abre o `projeto-B`. Para instruções que
valem em qualquer projeto, use o `~/.claude/CLAUDE.md` global (etapa 05 desta
trilha), não a pasta de memória.

## Confirmar que funcionou

Abra uma conversa nova no projeto onde você criou a memória e pergunte algo que
só está registrado lá (ex: se você registrou a porta de um serviço, pergunte
"em que porta roda o serviço X?"). Se o Claude responder corretamente sem você
repetir a informação, a memória está sendo lida.

---

**Próximo:** [Verificação](08-verificacao.md)
