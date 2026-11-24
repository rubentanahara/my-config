#!/usr/bin/env bash
set -uo pipefail

readonly SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
failures=0

expect() {
  local description=$1 expected=$2 actual=$3
  [[ "$actual" == "$expected" ]] && return
  echo "FAIL: $description"
  echo "  expected: $expected"
  echo "  got:      $actual"
  failures=$((failures + 1))
}

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
cd "$sandbox" && git init -q && mkdir -p scripts/agent
cp -R "$SCRIPTS_DIR/feature.sh" "$SCRIPTS_DIR/jq" scripts/agent/
cat > feature_list.json << 'JSON'
{"project_title":"Test","priority_legend":{},"sprints":[{"sprint":1,"goal":"first"}],
 "epics":[{"id":"E1","title":"Epic","sprint":1,"summary":"","stories":[
   {"id":"F05","name":"Create Tag (v2)!","title":"As a user, I want tags","acceptance_criteria":["Given, When, Then"],
    "test_filter":"FullyQualifiedName~TagTests","depends_on":[],"owns":["src/Tags/"],"state":"not_started","evidence":""}]}]}
JSON

source "$SCRIPTS_DIR/run.sh"
ROOT=$sandbox

expect "branch names are lowercase slugs" "feat/f05-create-tag-v2" "$(branch_name F05)"
expect "session names keep the story name" "F05 · Create Tag (v2)!" "$(session_name F05)"
expect "slugs stop at the length limit without a trailing dash" "feat/$(printf 'a%.0s' $(seq 40))" "feat/$(slug "$(printf 'a%.0s' $(seq 45))")"
expect "claude defaults to sonnet 5.5" "claude-sonnet-5-5" "$(default_model claude)"
expect "copilot implements with sonnet 5.5" "claude-sonnet-5.5" "$(default_model copilot)"
expect "copilot reviews with opus 5.5" "claude-opus-5.5" "$(default_checker_model copilot)"
expect "claude reviews with its implementer model" "claude-sonnet-5-5" "$(default_checker_model claude)"
expect "codex defaults to gpt-5.6-terra" "gpt-5.6-terra" "$(default_model codex)"
expect "agy defaults to gemini 3.8 flash high" "gemini-3.8-flash-high" "$(default_model agy)"
expect "commit subjects start lowercase" "create Tag (v2)!" "$(lowercase_first "Create Tag (v2)!")"

printf 'table\n\n**VERIFY: PASS**\n' > pass.md
printf 'VERIFY: FAIL 1 of 3 criteria, 0 other findings\nmore text\n' > fail.md
printf 'no verdict here\n' > none.md
printf 'VERIFY: PASS\nlater it changed its mind\nVERIFY: FAIL 2 of 3 criteria, 1 other findings\n' > both.md
expect "a bold PASS line counts" "VERIFY: PASS" "$(verdict_of pass.md)"
expect "a FAIL line keeps its counts" "VERIFY: FAIL 1 of 3 criteria, 0 other findings" "$(verdict_of fail.md)"
expect "no VERIFY line gives no verdict" "" "$(verdict_of none.md)"
expect "the last VERIFY line wins" "VERIFY: FAIL 2 of 3 criteria, 1 other findings" "$(verdict_of both.md)"

record F05 shipped "https://example/pull/1" 2> /dev/null
expect "result_of reads a matching result" "https://example/pull/1" "$(result_of F05 shipped)"
expect "result_of refuses another outcome" "" "$(result_of F05 blocked)"
expect "a story without a worktree has no worktree state" "" "$(worktree_state F05)"

cat > stream.jsonl << 'JSONL'
{"type":"system","subtype":"init"}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Read","input":{"file_path":"src/Tags/tag.go"}}]}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"make test-story FILTER=TagTests\nsecond line"}}]}}
{"type":"result","subtype":"success","result":"Done.\nVERIFY: PASS"}
not json at all
JSONL
stream_out="$sandbox/$RUNS_DIR/F05/review-1.md"
stream_shown=$(show_claude_stream "F05 · review" "$stream_out" < stream.jsonl 2> stream.err)
expect "the stream shows one line per step" "F05 · review › Read src/Tags/tag.go|F05 · review › Bash make test-story FILTER=TagTests|F05 · review › not json at all" "$(paste -sd '|' stream.err)"
expect "the stream appends its steps to progress.log" "3" "$(wc -l < "$sandbox/$RUNS_DIR/F05/progress.log" | tr -d ' ')"
expect "the session output file holds the final text and raw lines" "Done.|VERIFY: PASS|not json at all" "$(paste -sd '|' "$stream_out")"
expect "the final text is printed" "Done.|VERIFY: PASS|not json at all" "$(paste -sd '|' - <<< "$stream_shown")"
expect "the raw stream is kept" "5" "$(wc -l < "$stream_out.jsonl" | tr -d ' ')"
expect "the verdict reads from the final text" "VERIFY: PASS" "$(verdict_of "$stream_out")"

expect "a backgrounded line gives the session id" "9a986fbf" "$(printf 'Starting background service…\nbackgrounded · 9a986fbf · F05 · review\n' | live_session_id)"
expect "no backgrounded line gives no id" "" "$(printf 'Workspace not trusted.\n' | live_session_id)"
expect "--live refuses other CLIs" "--live works with claude only: it opens each session with claude --bg. Use --cli claude --checker claude, or drop --live." "$(parse_arguments --live --cli copilot 2>&1)"

claude_home=$(mktemp -d)
mkdir -p "$claude_home/projects/-sandbox"
cat > "$claude_home/projects/-sandbox/5dbbc910-aaaa.jsonl" << 'JSONL'
{"type":"user","message":{"content":"go"}}
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"git diff main"}}]}}
{"type":"assistant","isSidechain":true,"message":{"content":[{"type":"text","text":"subagent noise"}]}}
{"type":"assistant","message":{"content":[{"type":"text","text":"Table\nVERIFY: PASS"}]}}
JSONL
claude() {
  case "$1" in
    agents) echo '[{"id":"5dbbc910","state":"done","sessionId":"5dbbc910-aaaa"}]' ;;
    rm) ;;
    *) printf '%s\n' "$@" > "$sandbox/claude-args"; echo "backgrounded · 5dbbc910 · F05 · review" ;;
  esac
}
LIVE=true CLAUDE_CONFIG_DIR=$claude_home
live_out="$sandbox/$RUNS_DIR/F05/review-2.md"
live_shown=$(unset TMUX; run_session claude claude-opus-5-5 read "F05 · review" "Review F05" "$live_out" 2> live.err)
expect "a live session starts in the background" "--bg" "$(grep -x -- --bg "$sandbox/claude-args")"
expect "a live review never waits on a prompt" "dontAsk" "$(grep -x -A1 -- --permission-mode "$sandbox/claude-args" | tail -n 1)"
expect "a live session prints how to open it" "1" "$(grep -c 'claude attach 5dbbc910' live.err)"
expect "a live session keeps its last main-thread answer" "Table|VERIFY: PASS" "$(paste -sd '|' "$live_out")"
expect "a live session prints its answer" "Table|VERIFY: PASS" "$(paste -sd '|' - <<< "$live_shown")"
expect "a live session records its steps" "1" "$(grep -c 'F05 · review › Bash git diff main' "$sandbox/$RUNS_DIR/F05/progress.log")"
unset -f claude
LIVE=false
rm -rf "$claude_home"

watch_output=$(bash "$SCRIPTS_DIR/watch.sh" --once 2>&1)
expect "watch shows the story result" "1" "$(grep -c '^F05  shipped https://example/pull/1' <<< "$watch_output")"
expect "watch shows the last steps" "1" "$(grep -c 'F05 · review › Bash make test-story' <<< "$watch_output")"
expect "watch filters by story id" "No story has started yet. run.sh writes to .agent/runs/<id>." "$(bash "$SCRIPTS_DIR/watch.sh" --once F99 2>&1)"

tdd_repo=$(mktemp -d)
git -C "$tdd_repo" init -q -b main
git -C "$tdd_repo" -c user.email=t@t -c user.name=t commit -q --allow-empty -m base
git -C "$tdd_repo" switch -q -c feat/x
BASE_BRANCH=main
no_commit_message=$(tdd_commit_order F05 "$tdd_repo")
expect "the gate names the missing commit" "TDD rule: there is no commit." "${no_commit_message%% Commit*}"
mkdir -p "$tdd_repo/src"
touch "$tdd_repo/src/x_test.go"
git -C "$tdd_repo" add -A && git -C "$tdd_repo" -c user.email=t@t -c user.name=t commit -q -m "test(red): proves x"
touch "$tdd_repo/src/x.go"
git -C "$tdd_repo" add -A && git -C "$tdd_repo" -c user.email=t@t -c user.name=t commit -q -m "feat(F01): x"
tdd_first=$(git -C "$tdd_repo" log --reverse --format=%H main..HEAD | sed -n 1p)
first_commit_is_red "$tdd_repo" "$tdd_first" && result=ok || result=refused
expect "a first commit named test(red) is accepted" "ok" "$result"
first_commit_is_red "$tdd_repo" "$(git -C "$tdd_repo" rev-parse HEAD)" && result=ok || result=refused
expect "a feat commit is refused as the first" "refused" "$result"
rm -rf "$tdd_repo"

if (( failures > 0 )); then
  echo "$failures run.sh test(s) failed."
  exit 1
fi
echo "run.sh tests passed."
