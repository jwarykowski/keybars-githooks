#!/bin/sh
# pass never fails, and the $ in the hooks below is theirs
# shellcheck disable=SC2015,SC2016
# The hooks, installed in one repository and then for every one.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

git init -q --bare "$tmp/origin.git"
git clone -q "$tmp/origin.git" "$tmp/shop" 2>/dev/null
cd "$tmp/shop"

# a hook of yours, already there
printf '#!/bin/sh\necho "$(cat)" >>"%s/yours"\n' "$tmp" >.git/hooks/pre-push
chmod +x .git/hooks/pre-push
"$root/bin/keybars-githooks" install >/dev/null
[ -x .git/hooks/pre-push.local ] && pass "keeps your hook" || fail "your hook went"

git commit -q --allow-empty -m one
check "a commit" "alert -q -repo shop -branch main git.committed"

git config keybars.test "exit 0"
git push -q origin main 2>/dev/null && pass "a push with passing tests" || fail "the push stopped"
check "the tests run through keybars-pro" "run -q -name build -- sh -c exit 0"
grep -q "refs/heads/main" "$tmp/yours" && pass "your hook runs first, with the refs" || fail "your hook didn't run"

git commit -q --allow-empty -m two
: >"$tmp/keybars.log"
git config keybars.test "exit 3"
if git push -q origin main 2>/dev/null; then fail "a push with failing tests went"; else pass "failing tests stop a push"; fi
git config keybars.block false
git push -q origin main 2>/dev/null && pass "keybars.block false lets it go" || fail "the push stopped with keybars.block false"
: >"$tmp/keybars.log"

# a pull that brings something in
git clone -q "$tmp/origin.git" "$tmp/other" 2>/dev/null
(cd "$tmp/other" && git commit -q --allow-empty -m three && git push -q origin main 2>/dev/null)
git pull -q --no-rebase origin main 2>/dev/null
check "a pull" "alert -q -repo shop -branch main git.merged"

# a rebase replays commits quietly
git commit -q --allow-empty -m four
check "another commit" "alert -q -repo shop -branch main git.committed"
git rebase -q --force-rebase HEAD~1 2>/dev/null
sleep 0.5
if grep -q git.committed "$tmp/keybars.log"; then fail "a rebase sent git.committed"; else pass "a rebase is quiet"; fi

"$root/bin/keybars-githooks" uninstall >/dev/null
[ -x .git/hooks/pre-push ] && ! grep -q keybars .git/hooks/pre-push && [ ! -e .git/hooks/post-commit ] &&
  pass "uninstall puts yours back" || fail "uninstall left: $(echo .git/hooks/*)"

# for every repository
"$root/bin/keybars-githooks" install --global >/dev/null
[ "$(git config --global core.hooksPath)" = "$root/hooks" ] && pass "global install" || fail "core.hooksPath not set"
git init -q "$tmp/blog"
cd "$tmp/blog"
printf '#!/bin/sh\ntouch "%s/ran"\n' "$tmp" >.git/hooks/post-commit
chmod +x .git/hooks/post-commit
git commit -q --allow-empty -m one
check "a commit anywhere" "alert -q -repo blog -branch main git.committed"
[ -e "$tmp/ran" ] && pass "the repository's own hook still runs" || fail "its own hook was skipped"
"$root/bin/keybars-githooks" uninstall --global >/dev/null
[ -z "$(git config --global core.hooksPath || true)" ] && pass "global uninstall" || fail "core.hooksPath still set"
finish
