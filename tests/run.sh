#!/usr/bin/env bash
set -uo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"
export REPO

total=0
for t in "$REPO"/tests/test_*.sh; do
  [ -f "$t" ] || continue
  printf '\n== %s\n' "$(basename "$t")"
  bash "$t"
  total=$((total + $?))
done

printf '\n'
if [ "$total" -eq 0 ]; then
  echo "todos os testes passaram"
  exit 0
fi
echo "$total asserção(ões) falharam"
exit 1
