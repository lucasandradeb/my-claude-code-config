#!/usr/bin/env bash
# Helpers de asserção. Cada arquivo de teste deve terminar com `exit $FAILURES`.
: "${REPO:?REPO nao definido — rode via tests/run.sh}"

FAILURES=0

_pass() { printf '  ok    %s\n' "$1"; }
_fail() { printf '  FALHA %s\n' "$1"; FAILURES=$((FAILURES + 1)); }

assert_file_exists() {
  if [ -f "$1" ]; then _pass "existe: $1"; else _fail "nao existe: $1"; fi
}

assert_contains() {
  case "$1" in
    *"$2"*) _pass "contem: $2" ;;
    *)      _fail "nao contem: $2" ;;
  esac
}

assert_not_contains() {
  case "$1" in
    *"$2"*) _fail "contem (nao deveria): $2" ;;
    *)      _pass "ausente: $2" ;;
  esac
}

assert_eq() {
  if [ "$1" = "$2" ]; then _pass "igual: $2"; else _fail "esperado '$2', obtido '$1'"; fi
}

assert_exit_code() {
  want=$1; shift
  "$@" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then _pass "exit $want"; else _fail "exit esperado $want, obtido $got"; fi
}
