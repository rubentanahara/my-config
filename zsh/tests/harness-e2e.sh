#!/usr/bin/env bash
# Usage: harness-e2e.sh [rust go node dotnet]
# Scaffolds a temp project per language with harness and checks the TDD commit gate.
set -u
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
HARNESS=$(cd "$(dirname "$0")/.." && pwd)/harness.zsh
failures=0

scaffold() {
  mkdir -p "$ROOT/$1" && cd "$ROOT/$1" || exit 1
  git init -q -b main
  git config user.email t@t && git config user.name t
}

apply_harness() {
  zsh -c "source $HARNESS; harness . --lang $1" 2>&1 | grep -E "lang:|unknown"
  printf 'target/\nbin/\nobj/\nnode_modules/\n.agent/\n' > .gitignore
  git add -A && git -c core.hooksPath=/dev/null commit -qm "chore: scaffold" && git checkout -q -b feat/add
}

try() {
  local label=$1 expect=$2 got; shift 2
  mkdir -p .agent
  if "$@" > .agent/last.log 2>&1; then got=ok; else got=refused; fi
  if [[ $got == "$expect" ]]; then
    echo "  PASS $label"
  else
    echo "  FAIL $label (got $got, want $expect)"
    grep -E "TDD gate|error|FAIL" .agent/last.log | head -3
    failures=$((failures + 1))
  fi
}

reset_to_main() {
  git reset -q --hard; git clean -fdq -e .agent; git checkout -q -B "$1" main
}

flow() {
  echo "== $1"
  write_stub; write_test; git add -A
  try "red commit, tests fail" ok git commit -qm "test(red): add"

  reset_to_main no-red
  write_stub; git add -A
  try "source without red refused" refused git commit -qm "feat: add"

  git checkout -q -f feat/add
  write_impl; git add -A
  try "green commit passes" ok git commit -qm "feat: add"

  reset_to_main waiver
  write_impl; git add -A
  try "waiver with passing check" ok git commit -qm "feat: add" -m "No-Tests: spike"

  reset_to_main red-passes
  write_impl; write_test; git add -A
  try "red commit with passing tests refused" refused git commit -qm "test(red): add"
}

run_rust() {
  scaffold rust; cargo init --lib -q --name t > /dev/null 2>&1; rm -f src/lib.rs
  write_stub() { mkdir -p src; echo 'pub fn add(_a: i32, _b: i32) -> i32 { 0 }' > src/lib.rs; }
  write_test() { mkdir -p tests; printf 'use t::add;\n\n#[test]\nfn adds() {\n    assert_eq!(add(1, 2), 3);\n}\n' > tests/add.rs; }
  write_impl() { mkdir -p src; echo 'pub fn add(a: i32, b: i32) -> i32 { a + b }' > src/lib.rs; }
  apply_harness rust; flow rust
}

run_go() {
  scaffold go; go mod init example.com/t > /dev/null 2>&1
  write_stub() { printf 'package t\n\nfunc Add(a, b int) int { return 0 }\n' > add.go; }
  write_test() { printf 'package t\n\nimport "testing"\n\nfunc TestAdd(t *testing.T) {\n\tif Add(1, 2) != 3 {\n\t\tt.Fatal("want 3")\n\t}\n}\n' > add_test.go; }
  write_impl() { printf 'package t\n\nfunc Add(a, b int) int { return a + b }\n' > add.go; }
  apply_harness go; flow go
}

run_node() {
  scaffold node
  cat > package.json <<'J'
{
  "name": "t",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "build": "node --check src/add.ts",
    "lint": "node --check src/add.ts",
    "format": "echo ok",
    "test": "node --test"
  }
}
J
  write_stub() { mkdir -p src; echo 'export function add(_a: number, _b: number): number { return 0; }' > src/add.ts; }
  write_test() { mkdir -p src; printf 'import { test } from "node:test";\nimport assert from "node:assert";\nimport { add } from "./add.ts";\n\ntest("adds", () => { assert.equal(add(1, 2), 3); });\n' > src/add.test.ts; }
  write_impl() { mkdir -p src; echo 'export function add(a: number, b: number): number { return a + b; }' > src/add.ts; }
  apply_harness node; flow node
}

run_dotnet() {
  scaffold dotnet; dotnet new xunit -n T -o . --force > /dev/null 2>&1; rm -f UnitTest1.cs
  write_stub() { printf 'namespace T;\n\npublic static class Calc\n{\n    public static int Add(int a, int b) => 0;\n}\n' > Calc.cs; }
  write_test() { printf 'namespace T;\n\npublic class CalcTests\n{\n    [Fact]\n    public void Adds() => Assert.Equal(3, Calc.Add(1, 2));\n}\n' > CalcTests.cs; }
  write_impl() { printf 'namespace T;\n\npublic static class Calc\n{\n    public static int Add(int a, int b) => a + b;\n}\n' > Calc.cs; }
  apply_harness dotnet; dotnet restore > /dev/null 2>&1; flow dotnet
}

langs=("$@")
[[ ${#langs[@]} -gt 0 ]] || langs=(rust go node dotnet)
for lang in "${langs[@]}"; do "run_$lang"; done

echo "failures: $failures"
exit $((failures > 0))
