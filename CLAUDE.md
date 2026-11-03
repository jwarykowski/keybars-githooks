# keybars-githooks

Git hooks (pre-push, post-commit, post-merge) that drive keybars Pro, and
an installer. README.md has the detail; this file is what to keep in mind
while working here.

## Commands

- `make check`: shellcheck, then the tests, which build real repositories
  (a bare origin, clones) in a scratch `$HOME` against a fake `keybars-pro`.

## Keep in mind

- POSIX sh only, on Linux and macOS: no bash-isms, no GNU-only flags.
- `hooks/` is both what per-repository wrappers exec and what
  `core.hooksPath` points at for a global install, so every hook runs the
  repository's own first (`own` in `hooks/lib.sh`): `<hook>.local` beside a
  wrapper, or `.git/hooks/<hook>` when installed globally.
- Events go in the background with `alert -q`: a hook never waits on, or
  fails because of, keybars Pro. Only pre-push's tests can stop anything.
- A new hook goes in `hooks`, the installer's `hooks` list and the README.

## Related repos (in ~/development)

- `keybars-pro`: the app and the `keybars-pro` command (`alert`, `run`,
  `rules add`). A change there can break this.
- `keybars-shell`: the shell plugins, built the same way.
