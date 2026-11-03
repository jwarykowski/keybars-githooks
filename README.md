# keybars-githooks

Git hooks for [keybars Pro](https://keybars.app/pro/):

- **pre-push** runs your tests through `keybars-pro run`, so the keyboard
  shows them running, then passed or failed. A failure stops the push.
- **post-commit** sends `git.committed`.
- **post-merge** sends `git.merged` after a pull or merge brings something
  in.

Events carry the repository and branch, so a rule can light something
different for one project. Hooks you already have keep running, first.

## requirements

- keybars Pro running, with its command installed: App settings, Command
  line, **Install the command-line tool**
- git 2.22 or later; Linux or macOS

## install

```sh
git clone https://github.com/jwarykowski/keybars-githooks ~/keybars-githooks
cd your-project
~/keybars-githooks/bin/keybars-githooks install
```

`install --global` sets git's `core.hooksPath` instead, so every repository
gets them; each repository's own hooks in `.git/hooks` still run first. A
repository with its own `core.hooksPath` (husky, lefthook) keeps it; add
the hooks there by hand.

`uninstall` (or `uninstall --global`) takes them out and puts back what was
there.

## tests before a push

```sh
git config keybars.test "make test"
```

The tests run as `build.running`, then `build.passed` or `build.failed`, the
events the marketplace's CI pack plays (`keybars-pro market install
ci-pack`). Without `keybars.test`, pushes aren't touched.

| setting | default | |
|---|---|---|
| `keybars.test` | none | the command pre-push runs |
| `keybars.name` | `build` | the events' name: `<name>.running`, `.passed`, `.failed` |
| `keybars.block` | `true` | `false` pushes even when the tests fail |

`git push --no-verify` skips the hook once.

## rules

The hooks only send events; rules decide what lights.
`keybars-githooks rules` adds two: the top row waves green on a commit, the
whole board cyan when a pull brings something in. Change them on keybars
Pro's Alerts page like any other rule.

## development

`make check` runs shellcheck and the tests, which drive real git
repositories against a fake `keybars-pro`.

## licence

MIT
