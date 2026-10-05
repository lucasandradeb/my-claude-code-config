# Economia de tokens — usando com eficiência

Tokens são a "moeda" que determina quanto você pode usar o Claude. Cada modelo tem
diferentes custos. Aqui estão estratégias para usar de forma eficiente.

## Entendendo tokens

```
1 token ≈ 4 caracteres em inglês
1 token ≈ 3 caracteres em português

Exemplo:
"Olá, como vai?" = ~6 tokens
"function processData() { return data; }" = ~12 tokens
```

Preço por modelo não entra aqui — veja sempre
[claude.com/pricing](https://claude.com/pricing) para os valores atuais, e
[`docs/reference/modelos.md`](../reference/modelos.md) para quando escolher cada
modelo.

## Estratégias de economia

### 1. Escolha o modelo certo

❌ **Ruim**: usar o modelo mais caro para tudo
```
Você: "Formate este JSON"
[Usa o modelo mais capaz — caro e desnecessário]
```

✅ **Bom**: usar modelo apropriado à tarefa
```
Você: "Formate este JSON" → tarefa simples, modelo leve
Você: "Refatore arquitetura do sistema" → tarefa complexa, modelo mais capaz
Você: "Implemente feature padrão" → modelo intermediário (padrão recomendado)
```

Critério completo em [`docs/reference/modelos.md`](../reference/modelos.md).

### 2. Seja específico nas perguntas

❌ **Ruim**: perguntas vagas que exigem exploração
```
Você: "Me fale sobre o projeto"
Claude: [Lê dezenas de arquivos para entender contexto]
```

✅ **Bom**: perguntas direcionadas
```
Você: "Explique como funciona a autenticação em UserService.cs"
Claude: [Lê apenas arquivo específico]
```

### 3. Use a memória para não re-explicar contexto

❌ **Ruim**: re-explicar contexto sempre
```
[Conversa 1]
Você: "O projeto usa arquitetura CQRS com MediatR..."
[Conversa 2]
Você: "O projeto usa arquitetura CQRS com MediatR..." [repete]
```

✅ **Bom**: salvar contexto uma vez
```
[Conversa 1]
Você: "Lembre: projeto usa CQRS com MediatR"
Claude: [Salva um arquivo na memória do projeto]

[Conversa 2]
Você: "Adicione novo command"
Claude: [Usa memória salva, não precisa re-explicar]
```

Veja [`docs/concepts/memoria.md`](memoria.md) para como o sistema de memória
funciona.

### 4. Leituras incrementais

❌ **Ruim**: ler arquivos inteiros desnecessariamente
```
Você: "Qual a assinatura do método processPayment?"
Claude: [Lê arquivo de 500 linhas completo]
```

✅ **Bom**: ler só o trecho necessário (`Grep` e leitura por faixa de linhas; com o
Serena instalado, análise semântica)
```
Você: "Qual a assinatura do método processPayment?"
Claude: [Busca só o método, sem ler o arquivo todo]
```

### 5. Evite re-reads

❌ **Ruim**: ler o mesmo arquivo múltiplas vezes
```
Você: "Leia UserService.cs e me diga o que faz"
Claude: [Lê arquivo]
Você: "Agora refatore o método validateUser"
Claude: [Lê arquivo novamente]
```

✅ **Bom**: trabalhar incrementalmente na mesma conversa
```
Você: "Leia UserService.cs e refatore o método validateUser"
Claude: [Lê uma vez e já faz ambas as ações]
```

### 6. Use globbing inteligente

❌ **Ruim**: padrões muito amplos
```
Você: "Leia todos os arquivos do projeto"
Claude: [Lê centenas de arquivos incluindo node_modules]
```

✅ **Bom**: padrões específicos
```
Você: "Leia apenas os serviços em src/services/*.ts"
Claude: [Lê apenas arquivos relevantes]
```

### 7. Aproveitamento de contexto

✅ **Estratégia**: agrupe tarefas relacionadas em uma conversa
```
Você: "Vou pedir várias mudanças no módulo de auth:
1. Refatore UserService
2. Adicione testes
3. Atualize documentação"

Claude: [Mantém contexto do módulo de auth]
[Não precisa re-ler arquivos entre tarefas]
```

### 8. Ferramentas certas para tarefas certas

| Tarefa | Ferramenta eficiente | Ferramenta ineficiente |
|--------|---------------------|------------------------|
| Buscar arquivo por nome | `Glob` | `Read` + tentativa e erro |
| Buscar texto em código | `Grep` | `Read` em vários arquivos |
| Entender estrutura de classe | `Grep` por declarações, ou Serena (`get_symbols_overview`) se instalado | `Read` arquivo completo |
| Renomear variável | Serena (`rename_symbol`) se instalado; senão `Grep` + `Edit` | `Edit` manual sem varrer todos os usos |

## Lições medidas de um caso real

Números do mantenedor deste repositório, medidos em 30 dias de uso (268 sessões).
São um exemplo, não uma média: o seu perfil será diferente, mas o padrão costuma se
repetir.

| Medição | Valor |
|---|---|
| Peso das 5 maiores sessões | 60% de todo o contexto lido no período |
| Sessões com 1.600+ mensagens | Chegaram a 640 mil tokens de contexto |
| Contexto fixo antes da primeira mensagem | ~72 mil tokens (mediana) |

Cada mensagem reenvia o histórico da sessão, então o custo cresce com o tamanho dela,
não só com o que você pede. As lições:

1. **Sessão curta**: uma tarefa por sessão, `/clear` ao terminar e `/compact` quando
   o contexto passar de ~150 mil tokens.
2. **Documento de handoff** para frentes longas: grave o estado num arquivo do
   repositório e retome lendo esse arquivo, em vez de arrastar uma sessão gigante.
3. **Pode MCPs e plugins sem uso**: cada um entra no contexto fixo de toda sessão
   (nomes de ferramentas, instruções, skills). Veja
   [`mcp-servers.md`](../reference/mcp-servers.md#removidos-e-por-quê) e
   [`plugins.md`](../reference/plugins.md).
4. **Um único estilo de saída**: dois estilos concorrentes (por exemplo, o
   explicativo e o `caveman`) brigam entre si e aumentam tokens de saída, que
   custam cerca de 5x os de entrada.
5. **Subagentes para leitura ampla**: o subagente lê muito e devolve só o resumo,
   preservando o contexto da thread principal. Pode rodar em modelo mais barato —
   veja [`modelos.md`](../reference/modelos.md#roteamento-por-tarefa).
6. **Meça o custo fixo com `/context`**: é o jeito de ver o que está pesando antes
   da primeira mensagem e de confirmar que uma poda funcionou.

## RTK — Rust Token Killer

O RTK é um proxy de CLI que reduz o consumo de tokens em operações de
desenvolvimento (60-90% de economia relatada) reescrevendo comandos comuns
(`git status` vira `rtk git status`, por exemplo) de forma transparente via hook —
sem custo de tokens adicional na reescrita. Configuração completa, comandos meta
(`rtk gain`, `rtk discover`) e como verificar a instalação estão em
[`config/RTK.md`](../../config/RTK.md).

## Monitorando uso

**Verificar consumo**: use o comando de uso da sua interface (Command Palette →
"Claude: Show Usage" no VSCode, ou o comando equivalente da sua CLI).

**Informações mostradas**: tokens usados na conversa atual, custo estimado,
histórico de uso.

**Dica**: se está perto do limite do seu plano, prefira modelos mais leves para
tarefas simples nos períodos de maior consumo.
