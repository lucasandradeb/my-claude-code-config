# Instruções Globais para Desenvolvimento

## Filosofia de Trabalho

Sempre priorize:
1. **Explicação antes da ação** - Contextualize decisões técnicas e arquiteturais
2. **Código legível sobre código conciso** - Clareza é mais importante que brevidade
3. **Segurança e qualidade** - Nunca comprometa segurança por velocidade
4. **Educação contínua** - Explique o "porquê" das escolhas técnicas

## Estilo de Comunicação

- Sempre forneça contexto sobre decisões técnicas
- Explique trade-offs de diferentes abordagens
- Compartilhe insights sobre padrões e práticas
- Use formato de insights educacionais quando relevante
- Seja objetivo e profissional
- Não use emojis

## Diretrizes por Linguagem

### TypeScript e React

**Princípios Fundamentais:**
- Use TypeScript estrito (`strict: true` no tsconfig.json)
- Sempre defina tipos explícitos para props, state e retornos de função
- Prefira interfaces para objetos públicos e types para unions/intersections
- Use const assertions quando apropriado para inferência precisa

**Padrões React:**
- Componentes funcionais com hooks como padrão
- Use React.FC ou defina props explicitamente
- Organize hooks na ordem: useState, useEffect, useContext, useMemo, useCallback, custom hooks
- Sempre liste todas as dependências em useEffect e useCallback
- Use React.memo apenas quando houver evidência de problema de performance

**Estrutura de Componentes:**
```typescript
// Imports organizados: React, libraries, types, components, styles
import React, { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'

import { UserProfile } from './types'
import { Card } from '@/components/ui'

interface ComponentProps {
  userId: string
  onUpdate?: (profile: UserProfile) => void
}

export function Component({ userId, onUpdate }: ComponentProps) {
  // Hooks primeiro
  const [state, setState] = useState<string>('')

  // Queries e mutations
  const { data, isLoading } = useQuery(...)

  // Handlers e funções auxiliares
  const handleAction = () => {
    // Implementação
  }

  // Render
  return (...)
}
```

**Gerenciamento de Estado:**
- Estado local: useState para estado simples do componente
- Estado compartilhado: Context API para estado que atravessa poucos níveis
- Estado global complexo: Considere Zustand, Jotai ou Redux Toolkit
- Estado de servidor: React Query ou SWR para cache e sincronização

**Boas Práticas:**
- Extraia lógica complexa para custom hooks
- Use barrel exports (index.ts) para módulos
- Mantenha componentes pequenos e focados (< 400 linhas)
- Prefira composição sobre renderização condicional complexa
- Use tipos discriminados para estados mutuamente exclusivos

**Tratamento de Erros:**
- Use Error Boundaries para erros de renderização
- Implemente tratamento de erros em queries e mutations
- Sempre valide entrada do usuário
- Use bibliotecas de validação como Zod ou Yup

### Python

**Princípios Fundamentais:**
- Siga PEP 8 para estilo de código
- Use type hints em todas as funções públicas
- Docstrings no formato Google ou NumPy para funções, classes e módulos
- Prefira clareza sobre "pythonic tricks" obscuros

**Type Hints:**
```python
from typing import Optional, List, Dict, Union, Protocol
from collections.abc import Callable

def process_data(
    items: List[Dict[str, Any]],
    callback: Optional[Callable[[Dict], None]] = None
) -> Dict[str, int]:
    """
    Processa uma lista de itens e retorna estatísticas.

    Args:
        items: Lista de dicionários com dados para processar
        callback: Função opcional chamada para cada item processado

    Returns:
        Dicionário com contadores e estatísticas do processamento

    Raises:
        ValueError: Se items estiver vazio
    """
    if not items:
        raise ValueError("Lista de items não pode estar vazia")

    # Implementação
    return {"processed": len(items)}
```


**Padrões e Práticas:**
- Use dataclasses ou Pydantic models para estruturas de dados
- Prefira dependency injection sobre singletons
- Use context managers (with) para recursos que precisam cleanup
- Implemente __repr__ e __str__ em classes customizadas
- Use enums para constantes relacionadas
- Prefira pathlib sobre os.path

**Async/Await:**
- Use async/await para I/O bound operations
- Não misture código síncrono e assíncrono sem necessidade
- Use asyncio.gather() para paralelização
- Considere httpx para HTTP async

**Tratamento de Erros:**
- Use exceções específicas, não genéricas
- Crie exceções customizadas quando apropriado
- Sempre limpe recursos em finally ou use context managers
- Log erros com contexto suficiente

**Testes:**
- Use pytest como framework
- Organize fixtures em conftest.py
- Use parametrize para testes similares
- Mock apenas boundaries externas (APIs, DB)
- Mantenha cobertura > 70% para código crítico

### C# (.NET)

**Princípios Fundamentais:**
- Siga as convenções de nomenclatura C# (PascalCase para públicos, camelCase para privados)
- Use nullable reference types (habilitado por padrão em .NET 6+)
- Prefira async/await para operações I/O
- SOLID principles como guia arquitetural

**Padrões de Nomenclatura:**
```csharp
// Classes e métodos públicos: PascalCase
public class UserService
{
    // Campos privados: _camelCase com underscore
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    // Propriedades: PascalCase
    public int MaxRetries { get; set; }

    // Métodos: PascalCase
    public async Task<User?> GetUserByIdAsync(Guid userId)
    {
        // Variáveis locais: camelCase
        var cacheKey = $"user:{userId}";

        // Implementação
    }
}
```

**Dependency Injection:**
- Use o DI container nativo do ASP.NET Core
- Registre serviços com tempo de vida apropriado (Singleton, Scoped, Transient)
- Injete interfaces, não implementações concretas
- Use IOptions<T> para configurações

**Async/Await:**
```csharp
// Sempre use async/await para I/O
public async Task<Result<User>> CreateUserAsync(
    CreateUserCommand command,
    CancellationToken cancellationToken = default)
{
    // Valide entrada
    if (string.IsNullOrWhiteSpace(command.Email))
        return Result<User>.Failure("Email é obrigatório");

    // Use cancellation tokens em operações longas
    var user = await _repository
        .AddAsync(command.ToEntity(), cancellationToken);

    return Result<User>.Success(user);
}
```

**Tratamento de Erros:**
- Use Result<T> ou Option<T> patterns ao invés de exceções para fluxo de controle
- Crie exceções customizadas que herdam de Exception
- Use middleware para tratamento global de exceções
- Log estruturado com Serilog ou Microsoft.Extensions.Logging

**Entity Framework Core:**
- Use migrations para versionamento de schema
- Configure entidades com Fluent API, não data annotations
- Use AsNoTracking() para queries read-only
- Implemente soft delete quando apropriado
- Use compiled queries para queries complexas repetidas

**Testes:**
- xUnit como framework padrão
- FluentAssertions para asserções legíveis
- Moq ou NSubstitute para mocking
- Testcontainers para testes de integração com DB
- ArchUnitNET para testes arquiteturais

**Boas Práticas:**
- Use records para DTOs e value objects imutáveis
- Prefira IEnumerable<T> sobre List<T> em retornos públicos
- Use pattern matching quando apropriado
- Implemente IDisposable/IAsyncDisposable quando gerencia recursos
- Use spans e memory para código performance-crítico

## Segurança

**Para Todas as Linguagens:**

1. **Validação de Entrada:**
   - Valide e sanitize todas as entradas de usuário
   - Use bibliotecas de validação estabelecidas
   - Implemente rate limiting em APIs públicas

2. **Autenticação e Autorização:**
   - Use bibliotecas estabelecidas (OAuth, JWT)
   - Nunca armazene senhas em plain text
   - Implemente autorização baseada em roles/policies

3. **Dados Sensíveis:**
   - Nunca commite secrets, tokens ou chaves
   - Use variáveis de ambiente ou secret managers
   - Criptografe dados sensíveis em repouso

4. **Vulnerabilidades Comuns:**
   - Previna SQL Injection usando queries parametrizadas
   - Previna XSS sanitizando output HTML
   - Previna CSRF usando tokens
   - Use HTTPS sempre
   - Mantenha dependências atualizadas

## Versionamento e Git

**Commits:**
- Mensagens em português ou inglês (mantenha consistência no projeto)
- Formato: `tipo: descrição breve`
- Tipos: feat, fix, refactor, docs, test, chore
- Corpo do commit deve explicar o "porquê", não o "o quê"

**Branches:**
- `main/master` - código em produção
- `develop` - integração de features
- `feature/nome-feature` - novas funcionalidades
- `fix/nome-bug` - correções
- `refactor/nome` - refatorações

**Pull Requests:**
- Descrição clara do problema e solução
- Screenshots para mudanças visuais
- Testes adicionados/atualizados
- Documentação atualizada se necessário
- Code review obrigatório antes de merge

## Code Review

**O que verificar:**
1. Código resolve o problema proposto?
2. Testes adequados estão incluídos?
3. Código é legível e bem estruturado?
4. Não introduz vulnerabilidades de segurança?
5. Performance é aceitável?
6. Documentação foi atualizada?

**Feedback Construtivo:**
- Seja específico e objetivo
- Sugira alternativas quando apontar problemas
- Reconheça boas soluções
- Foque no código, não na pessoa

## Documentação

**README.md deve conter:**
- Descrição do projeto e propósito
- Pré-requisitos e dependências
- Instruções de instalação
- Guia de uso básico
- Como rodar testes
- Como contribuir
- Licença

**Documentação de Código:**
- Documente o "porquê", não o "o quê"
- Mantenha documentação próxima ao código
- Use comentários apenas quando o código não é auto-explicativo
- Mantenha documentação atualizada

## Performance

**Otimização Prematura:**
- Não otimize sem evidência de problema
- Profile antes de otimizar
- Foque em algoritmos antes de micro-otimizações
- Mantenha código legível mesmo após otimizações

**Quando Otimizar:**
- Hot paths identificados por profiling
- Operações em loop com grandes datasets
- Queries de banco de dados lentas
- Latência perceptível ao usuário

## Insights Educacionais

Sempre que relevante, forneça insights no formato:

```
★ Insight ─────────────────────────────────────
[2-3 pontos educacionais sobre a decisão técnica]
─────────────────────────────────────────────────
```

Foque em:
- Trade-offs de diferentes abordagens
- Padrões arquiteturais aplicados
- Razões para escolhas técnicas específicas
- Contexto histórico ou evolução da solução

@RTK.md
