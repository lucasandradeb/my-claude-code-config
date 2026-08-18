# 01 — Pré-requisitos

> Tempo estimado: 5 min

Antes de instalar, confirme que sua máquina tem o que o script de instalação e o
próprio Claude Code precisam.

## O que você precisa

| Ferramenta | Para que serve |
|---|---|
| **VSCode** | Editor onde a extensão Claude Code roda |
| **Extensão Claude Code** | A extensão em si, instalada dentro do VSCode |
| **Node.js 18+** | Runtime que os MCP servers usam (a maioria roda via `npx`) |
| **`jq`** | O script de instalação usa `jq` para fazer merge de JSON sem sobrescrever suas configurações |
| **Git** | Clonar este repositório e, depois, uso normal do Claude Code em projetos versionados |

## Verificar o que já está instalado

```bash
node --version   # deve ser >= 18
git --version
jq --version
code --version   # confirma que o VSCode está no PATH
```

Se qualquer comando falhar com "command not found", siga a instalação abaixo para
o seu sistema.

## Instalação por sistema

### macOS

```bash
brew install node jq git
```

VSCode: baixe em https://code.visualstudio.com/ ou `brew install --cask visual-studio-code`.

### Linux (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y nodejs npm jq git
```

VSCode: baixe o pacote `.deb` em https://code.visualstudio.com/ ou use o
repositório oficial da Microsoft.

### Windows (PowerShell)

```powershell
winget install OpenJS.NodeJS.LTS
winget install jqlang.jq
winget install Git.Git
winget install Microsoft.VisualStudioCode
```

## Instalar a extensão Claude Code no VSCode

1. Abra o VSCode.
2. Vá em Extensions (`Cmd+Shift+X` no Mac, `Ctrl+Shift+X` no Windows/Linux).
3. Busque por "Claude Code".
4. Instale a extensão oficial da Anthropic.
5. Reinicie o VSCode se solicitado.
6. Clique no ícone do Claude na sidebar e faça login com sua conta Anthropic.

Com tudo isso confirmado, você está pronto para instalar a configuração deste
repositório.

---

**Próximo:** [Instalação](02-instalacao.md)
