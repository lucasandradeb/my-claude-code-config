#!/usr/bin/env bash
# Regras de sanitizacao. Fonte unica: sync.sh, check-drift.sh e os testes
# consomem estas funcoes. Nenhum outro lugar deve reimplementar a logica.

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERNS_FILE="${PATTERNS_FILE:-$_LIB_DIR/patterns.txt}"

# Remove de settings.json tudo que e especifico da maquina ou sigiloso.
# - env: removido por inteiro. Carrega senha e nomes de projeto de nuvem.
# - autoMode: descreve a maquina do autor.
# - statusLine: aponta para um caminho de plugin com hash de instalacao,
#   que nao existe em outra maquina. A documentacao explica como ativar.
# - permissions.allow: mantido apenas o que nao carrega caminho absoluto,
#   URL, credencial ou cadeia longa parecida com token.
# - hook de prettier: caminho reescrito para $HOME, portatil.
sanitize_settings() {
  jq '
    del(.env)
    | del(.autoMode)
    | del(.statusLine)
    | if (.permissions.allow? | type) == "array" then
        .permissions.allow |= map(select(
          (test("/Users/|/home/|https?://|password|secret|session|token"; "i") | not)
          and (test("[A-Za-z0-9_-]{24,}") | not)
        ))
      else . end
    | if (.hooks.PostToolUse? | type) == "array" then
        .hooks.PostToolUse |= map(
          .hooks |= map(
            if (.command? // "") | test("prettier-hook\\.py")
            then .command = "python3 $HOME/.claude/hooks/prettier-hook.py"
            else . end))
      else . end
  ' "$1"
}

# Substitui todo valor de env por referencia a variavel de ambiente e troca
# o diretorio de trabalho do autor por placeholder.
sanitize_mcp() {
  jq '
    with_entries(
      .value |= (
        (if (.env? | type) == "object"
         then .env |= with_entries(.value = "${" + .key + "}")
         else . end)
        | (if (.args? | type) == "array"
           then .args |= map(if type == "string" then gsub("(?<h>/(Users|home)/[A-Za-z0-9_.-]+)/[A-Za-z0-9_.-]+"; "$WORKSPACE_DIR") else . end)
           else . end)
      )
    )
  ' "$1"
}

# Retorna 1 se algum padrao proibido aparecer. Usado por sync.sh antes de
# escrever e por make check depois.
scan_secrets() {
  local target="$1"
  if grep -rInE -f "$PATTERNS_FILE" "$target" >&2; then
    return 1
  fi
  return 0
}
