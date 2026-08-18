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

### 3. Use o Memory Server

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
Claude: [Salva no memory server]

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

✅ **Bom**: usar análise semântica (Serena)
```
Você: "Qual a assinatura do método processPayment?"
Claude: [Usa Serena para buscar apenas o método]
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
| Entender estrutura de classe | `Serena` (get_symbols_overview) | `Read` arquivo completo |
| Renomear variável | `Serena` (rename_symbol) | `Edit` manual em vários lugares |

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
