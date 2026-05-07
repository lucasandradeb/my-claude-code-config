---
name: Portas dos serviços locais
description: Porta de cada serviço/API quando rodando localmente, para não precisar abrir os configs toda vez
type: project
---

Portas reais de cada serviço no ambiente local (perfil de desenvolvimento):

| Serviço | Porta HTTPS | Porta HTTP | Observação |
|---------|-------------|------------|------------|
| auth-api | [porta] | [porta] | |
| user-api | [porta] | [porta] | |
| product-api | [porta] | [porta] | |

Swagger: `http://localhost:<porta>/swagger`
Health: `http://localhost:<porta>/health`

**How to apply:** Usar essas portas ao testar endpoints localmente, sem precisar abrir as configs de cada projeto.

<!-- INSTRUÇÃO: Substitua a tabela acima com os serviços e portas reais do seu projeto -->
