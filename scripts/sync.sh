#!/usr/bin/env bash
# Copia a configuracao local para o repositorio, sanitizando.
# Direcao unica: local -> repositorio. Nunca o contrario (decisao D5).
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null  # caminho resolvido em runtime; shellcheck nao segue
. "$REPO/scripts/lib/sanitize.sh"

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
CLAUDE_JSON="${CLAUDE_JSON:-$HOME/.claude.json}"
DENYLIST="$REPO/scripts/lib/denylist.txt"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

report() { printf '  %-8s %s\n' "$1" "$2"; }

# 0 = permitido, 1 = na denylist
allowed() {
  local base="$1" line
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; esac
    [ "$base" = "$line" ] && return 1
  done < "$DENYLIST"
  return 0
}

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

echo "sync: $CLAUDE_DIR -> $REPO"
echo

# --- artefatos ---
for kind in skills agents commands; do
  [ -d "$CLAUDE_DIR/$kind" ] || continue
  mkdir -p "$STAGE/$kind"
  for item in "$CLAUDE_DIR/$kind"/*; do
    [ -e "$item" ] || continue
    base="$(basename "$item")"
    base="${base%.md}"
    if allowed "$base"; then
      cp -R "$item" "$STAGE/$kind/"
      report "copiar" "$kind/$(basename "$item")"
    else
      report "denylist" "$kind/$(basename "$item") — artefato interno, ignorado"
    fi
  done
done

# --- configuracao ---
mkdir -p "$STAGE/config"
sanitize_settings "$CLAUDE_DIR/settings.json" > "$STAGE/config/settings.template.json"
report "sanitizar" "config/settings.template.json"

jq '.mcpServers' "$CLAUDE_JSON" > "$STAGE/mcp.raw.json"
sanitize_mcp "$STAGE/mcp.raw.json" > "$STAGE/config/mcp-servers.template.json"
rm -f "$STAGE/mcp.raw.json"
report "sanitizar" "config/mcp-servers.template.json"

[ -f "$CLAUDE_DIR/prettier-hook.py" ] && {
  mkdir -p "$STAGE/config/hooks"
  cp "$CLAUDE_DIR/prettier-hook.py" "$STAGE/config/hooks/"
  report "copiar" "config/hooks/prettier-hook.py"
}

# --- verificacao antes de escrever ---
echo
if ! scan_secrets "$STAGE"; then
  echo "ABORTADO: padrao proibido encontrado na area de preparacao." >&2
  echo "Nada foi escrito no repositorio. Corrija a origem e rode de novo." >&2
  exit 1
fi
report "ok" "verificacao de segredo passou"

if [ "$DRY_RUN" -eq 1 ]; then
  echo
  echo "--dry-run: nada escrito."
  exit 0
fi

for kind in skills agents commands config; do
  [ -d "$STAGE/$kind" ] || continue
  cp -R "$STAGE/$kind/." "$REPO/$kind/"
done

echo
echo "sync concluido. Revise com: git diff"
