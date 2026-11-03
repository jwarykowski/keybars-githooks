#!/bin/sh
# keybars-githooks rules adds its two rules once.
set -eu
# shellcheck source=tests/lib.sh
. "$(dirname "$0")/lib.sh"

cat >"$KEYBARS_PRO" <<FAKE
#!/bin/sh
echo "\$*" >>"$log"
if [ "\$1 \$2" = "rules list" ]; then cat "$tmp/rules" 2>/dev/null || true; fi
if [ "\$1 \$2" = "rules add" ]; then echo "\$3" >>"$tmp/rules"; fi
FAKE

"$root/bin/keybars-githooks" rules >/dev/null
check "adds Pulled" "rules add Pulled git.merged -keys all -colour cyan -effect wave"
"$root/bin/keybars-githooks" rules >/dev/null
if grep -q "rules add" "$log"; then fail "added them again"; else pass "adds them once"; fi
if [ "$(grep -c . "$tmp/rules")" -eq 2 ]; then pass "two rules"; else fail "rules: $(cat "$tmp/rules")"; fi
if "$root/bin/keybars-githooks" nonsense 2>/dev/null; then fail "nonsense worked"; else pass "usage on nonsense"; fi
finish
