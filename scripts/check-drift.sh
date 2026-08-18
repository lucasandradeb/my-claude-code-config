#!/usr/bin/env bash
# Reporta divergencia entre a configuracao local e o repositorio.
# Somente leitura — nunca escreve. O CI nao consegue rodar isto, porque
# nao enxerga a maquina do mantenedor.
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
DENYLIST="$REPO/scripts/lib/denylist.txt"
DIFFS=0

allowed() {
  local base="$1" line
  while IFS= read -r line; do
    case "$line" in ''|\#*) continue ;; esac
    [ "$base" = "$line" ] && return 1
  done < "$DENYLIST"
  return 0
}

echo "drift: $CLAUDE_DIR <-> $REPO"
echo

for kind in skills agents commands; do
  for item in "$CLAUDE_DIR/$kind"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    allowed "${name%.md}" || continue
    if [ ! -e "$REPO/$kind/$name" ]; then
      printf '  so local    %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    elif ! diff -rq "$item" "$REPO/$kind/$name" >/dev/null 2>&1; then
      printf '  divergente  %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    fi
  done
  for item in "$REPO/$kind"/*; do
    [ -e "$item" ] || continue
    name="$(basename "$item")"
    if [ ! -e "$CLAUDE_DIR/$kind/$name" ]; then
      printf '  so no repo  %s/%s\n' "$kind" "$name"
      DIFFS=$((DIFFS + 1))
    fi
  done
done

echo
if [ "$DIFFS" -eq 0 ]; then
  echo "alinhado."
  exit 0
fi
echo "$DIFFS divergencia(s). Rode 'make sync' para trazer o local para ca."
exit 1
