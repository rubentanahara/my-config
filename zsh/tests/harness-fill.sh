#!/usr/bin/env bash
set -u
ROOT=$(mktemp -d)
trap 'rm -rf "$ROOT"' EXIT
HARNESS=$(cd "$(dirname "$0")/.." && pwd)/harness.zsh
failures=0

expect() {
  if "${@:2}" > /dev/null 2>&1; then echo "  PASS $1"; else echo "  FAIL $1"; failures=$((failures + 1)); fi
}

mkdir "$ROOT/bin"
for cli in claude codex copilot gemini; do
  printf '#!/bin/sh\nprintf "%%s\\n" "$@" > "%s/$(basename "$0").args"\n' "$ROOT" > "$ROOT/bin/$cli"
  chmod +x "$ROOT/bin/$cli"
done

run_harness() {
  (cd "$ROOT/p" && PATH="$ROOT/bin:$PATH" zsh -c "source $HARNESS; harness . $*")
}

mkdir "$ROOT/p" && cd "$ROOT/p" && git init -q -b main

run_harness --lang node --fill claude > /dev/null 2>&1
expect "claude gets -p and the brief" grep -q 'finishing the setup of an agent harness' "$ROOT/claude.args"
expect "claude runs with acceptEdits" grep -qx 'acceptEdits' "$ROOT/claude.args"

run_harness --fill codex > /dev/null 2>&1
expect "codex runs exec in workspace-write" grep -qx 'workspace-write' "$ROOT/codex.args"
expect "codex defaults to gpt-6-luna" grep -qx 'gpt-6-luna' "$ROOT/codex.args"

run_harness --fill copilot > /dev/null 2>&1
expect "copilot denies git push" grep -qx -- "--deny-tool=shell(git push)" "$ROOT/copilot.args"
expect "copilot defaults to auto" grep -qx 'auto' "$ROOT/copilot.args"

run_harness --fill gemini > /dev/null 2>&1
expect "gemini runs with auto_edit" grep -qx 'auto_edit' "$ROOT/gemini.args"

expect "claude defaults to haiku" grep -qx 'haiku' "$ROOT/claude.args"
expect "gemini defaults to flash-lite" grep -qx 'flash-lite' "$ROOT/gemini.args"

run_harness --fill claude --model opus > /dev/null 2>&1
expect "--model overrides the default" grep -qx 'opus' "$ROOT/claude.args"

expect "unknown cli refused" bash -c "! (cd $ROOT/p && zsh -c 'source $HARNESS; harness . --fill vim' > /dev/null 2>&1)"
expect "missing cli refused" bash -c "! (cd $ROOT/p && PATH=/usr/bin:/bin zsh -c 'source $HARNESS; harness . --fill gemini' > /dev/null 2>&1)"

echo "failures: $failures"
exit $((failures > 0))
