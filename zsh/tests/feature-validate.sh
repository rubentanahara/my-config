#!/usr/bin/env bash
set -u
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
CORE=$(cd "$(dirname "$0")/../harness-templates/core" && pwd)
failures=0

expect() {
  local label=$1 want=$2 got=refused; shift 2
  "$@" > "$ROOT/last.log" 2>&1 && got=ok
  if [[ $got == "$want" ]]; then echo "  PASS $label"; else echo "  FAIL $label (got $got, want $want)"; failures=$((failures + 1)); fi
}

cd "$ROOT" && git init -q -b main && cp -R "$CORE/." . && git add -A && git -c user.email=t@t -c user.name=t commit -qm "chore: scaffold"

expect "empty backlog is consistent" ok make features

bash scripts/agent/feature.sh add > /dev/null <<'J'
{"epics":[{"id":"E1","title":"t","sprint":1,"stories":[{"id":"S1","name":"n","title":"t","test_filter":"f","acceptance_criteria":["Given a, when b, then c"]}]}],"sprints":[{"sprint":1,"goal":"g"}]}
J
expect "added story is consistent" ok make features

jq '.epics[0].stories[0].state = "passing"' feature_list.json > t.json && mv t.json feature_list.json
expect "hand-set passing without evidence refused" refused make features

jq '.epics[0].stories[0].evidence = "x"' feature_list.json > t.json && mv t.json feature_list.json
expect "passing with evidence accepted" ok make features

jq '.epics[0].stories[0].depends_on = ["S9"]' feature_list.json > t.json && mv t.json feature_list.json
expect "unknown dependency refused" refused make features

echo "failures: $failures"
exit $((failures > 0))
