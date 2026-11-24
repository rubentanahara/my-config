#!/usr/bin/env bash
set -u
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
HARNESS=$(cd "$(dirname "$0")/.." && pwd)/harness.zsh
failures=0

expect() {
  if "${@:2}" > /dev/null 2>&1; then echo "  PASS $1"; else echo "  FAIL $1"; failures=$((failures + 1)); fi
}

cd "$ROOT" && git init -q -b main
zsh -c "source $HARNESS; harness . --lang node" > /dev/null 2>&1
expect "node setup step added to workflow" grep -q 'actions/setup-node@v7' .github/workflows/check.yml
zsh -c "source $HARNESS; harness . --lang node" > /dev/null 2>&1
expect "setup step not duplicated" test "$(grep -c setup-node .github/workflows/check.yml)" = 1

echo "stale" > scripts/agent/stop-gate.sh
zsh -c "source $HARNESS; harness . --sync" > /dev/null 2>&1
expect "sync restores scripts/agent" grep -q MAX_ATTEMPTS scripts/agent/stop-gate.sh

MERGED=$(mktemp -d)
cd "$MERGED" && git init -q -b main
printf 'build:\n\t@true\n' > Makefile
zsh -c "source $HARNESS; harness . --lang go" > /dev/null 2>&1
expect "existing Makefile gets test-story" grep -q '^test-story:' Makefile
expect "existing Makefile gets the go TEST_STORY_CMD" grep -qF 'TEST_STORY_CMD := go test ./... -run "$$FILTER"' Makefile
expect "existing Makefile gets format" grep -q '^format:' Makefile
expect "existing Makefile gets the go FORMAT_CMD" grep -qF 'FORMAT_CMD := gofmt -w .' Makefile
expect "merged check prints CHECK PASSED" grep -q 'CHECK PASSED' Makefile
rm -rf "$MERGED"

RECIPELESS=$(mktemp -d)
cd "$RECIPELESS" && git init -q -b main
printf 'build:\n\t@true\n\ncheck: build\n\ncheck: hooks agents harness features\n' > Makefile
zsh -c "source $HARNESS; harness . --lang go" > /dev/null 2>&1
zsh -c "source $HARNESS; harness . --lang go" > /dev/null 2>&1
expect "an already merged check gets CHECK PASSED once" test "$(grep -c 'CHECK PASSED' Makefile)" = 1
expect "CHECK PASSED is the recipe of the harness check rule" test "$(grep -A1 -x 'check: hooks agents harness features' Makefile | sed -n 2p)" = "$(printf '\t@echo "CHECK PASSED"')"
rm -rf "$RECIPELESS"

OWN_RECIPE=$(mktemp -d)
cd "$OWN_RECIPE" && git init -q -b main
printf 'check:\n\t@echo mine\n' > Makefile
zsh -c "source $HARNESS; harness . --lang go" > /dev/null 2>&1
expect "a check with its own recipe is left alone" test "$(grep -c 'CHECK PASSED' Makefile)" = 0
rm -rf "$OWN_RECIPE"

echo "failures: $failures"
exit $((failures > 0))
