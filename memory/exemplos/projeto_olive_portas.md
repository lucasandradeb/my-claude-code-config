---
name: Oliv-e Health — portas locais das APIs
description: Portas HTTPS/HTTP de cada API .NET e Node.js quando rodando com perfil Local
type: project
---

Portas reais lidas dos launchSettings.json de cada projeto (perfil Local/default):

| Serviço | HTTPS | HTTP |
|---|---|---|
| auth-api | 5003 | 5004 |
| account-api | 5001 | 5002 |
| card-api | 5005 | 5006 |
| clinical-metrics-api | 5007 | 5008 |
| company-api | — | 5010 |
| dr-olive-api | 5011 | 5012 |
| medic-api | 5015 | 5016 |
| questionnaire-api | — | 22771 |
| integration-api | — | 80 (PORT env) |
| mercer-marsh-api | — | 3000 (PORT env) |

Swagger: `https://localhost:<porta>/swagger`
Health: `https://localhost:<porta>/health`

**How to apply:** Usar essas portas ao testar endpoints localmente, sem precisar abrir os launchSettings de cada projeto.
