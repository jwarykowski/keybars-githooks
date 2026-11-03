# shellcheck shell=sh
# Shared by the hooks: the keybars-pro command, events about this repository,
# and the repository's own hook, run first.

kp=${KEYBARS_PRO:-keybars-pro}

# send <event>: to keybars Pro's alert rules with the repository and branch,
# in the background, quietly when keybars Pro isn't running
send() {
  event=$1
  set --
  if top=$(git rev-parse --show-toplevel 2>/dev/null); then
    set -- -repo "${top##*/}"
    branch=$(git branch --show-current 2>/dev/null) || branch=
    [ -z "$branch" ] || set -- "$@" -branch "$branch"
  fi
  command -v "$kp" >/dev/null 2>&1 || return 0
  "$kp" alert -q "$@" "$event" >/dev/null 2>&1 &
}

# own <hook>: prints the repository's own hook, if it has one to run. Installed
# per repository, that's <hook>.local beside our wrapper; installed globally,
# it's the hook in .git/hooks, which core.hooksPath would otherwise skip.
own() {
  dir="$(git rev-parse --git-common-dir)/hooks"
  if grep -q "keybars-githooks wrapper" "$dir/$1" 2>/dev/null; then
    hook="$dir/$1.local"
  else
    hook="$dir/$1"
  fi
  [ -x "$hook" ] || return 1
  printf '%s\n' "$hook"
}

# rebasing: commits replayed by a rebase aren't news
rebasing() {
  [ -d "$(git rev-parse --git-path rebase-merge)" ] || [ -d "$(git rev-parse --git-path rebase-apply)" ]
}
