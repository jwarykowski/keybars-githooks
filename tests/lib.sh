# shellcheck shell=sh
# Shared by the tests: a fake keybars-pro that logs its arguments (and runs
# what run is given), git set up in a scratch home, and checks.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# shellcheck disable=SC2034 # the tests that source this use it
root=$(cd "$(dirname "$0")/.." && pwd)
log="$tmp/keybars.log"
export KEYBARS_PRO="$tmp/keybars-pro"
cat >"$KEYBARS_PRO" <<FAKE
#!/bin/sh
echo "\$*" >>"$log"
if [ "\$1" = run ]; then
  while [ "\$1" != -- ]; do shift; done
  shift
  exec "\$@"
fi
FAKE
chmod +x "$KEYBARS_PRO"

export HOME="$tmp/home" GIT_CONFIG_NOSYSTEM=1
mkdir -p "$HOME"
git config --global user.name Tester
git config --global user.email tester@example.com
git config --global init.defaultBranch main

fails=0
pass() { echo "ok: $1"; }
fail() {
  echo "FAIL: $*" >&2
  fails=$((fails + 1))
}

# check <name> <line>: the fake was called with exactly that, in time
check() {
  i=0
  while [ "$i" -lt 50 ] && ! grep -qxF -- "$2" "$log" 2>/dev/null; do
    sleep 0.1
    i=$((i + 1))
  done
  if grep -qxF -- "$2" "$log" 2>/dev/null; then pass "$1"; else fail "$1: want \"$2\", got: $(cat "$log" 2>/dev/null)"; fi
  : >"$log"
}

finish() {
  [ "$fails" -eq 0 ] || {
    echo "$fails failed" >&2
    exit 1
  }
}
