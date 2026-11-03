.PHONY: lint test check

lint:
	shellcheck -x bin/* hooks/* tests/*.sh

test:
	sh tests/hooks_test.sh
	sh tests/rules_test.sh

check: lint test
