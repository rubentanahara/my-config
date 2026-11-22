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

echo "failures: $failures"
exit $((failures > 0))
