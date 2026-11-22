#!/usr/bin/env bash
set -euo pipefail

readonly FEATURES_FILE=feature_list.json
readonly PROGRESS_FILE=PROGRESS.md
readonly HARNESS_FILES='["PROGRESS.md","feature_list.json"]'
readonly USAGE='Usage:
  scripts/agent/feature.sh add < fragment.json      add epics, stories and sprints (see the backlog skill)
  scripts/agent/feature.sh show <id>                print one story with its epic and sprint
  scripts/agent/feature.sh status                   progress per sprint and every story not passing
  scripts/agent/feature.sh waves                    open stories grouped into waves that can run in parallel
  scripts/agent/feature.sh start <id>
  scripts/agent/feature.sh done <id>
  scripts/agent/feature.sh block <id> "<reason>"
  scripts/agent/feature.sh unblock <id>             make a blocked story startable again
  scripts/agent/feature.sh scope <id>               files changed on this branch that the story does not own
  scripts/agent/feature.sh validate                 fail when feature_list.json was edited by hand
  scripts/agent/feature.sh reset                    remove every sprint, epic and story; keep project_title, priority_legend and shared'

JQ_DIR="$(dirname "${BASH_SOURCE[0]}")/jq"
STORIES_JQ=$(< "$JQ_DIR/stories.jq")
WAVES_JQ="$STORIES_JQ$(< "$JQ_DIR/waves.jq")"
ADD_JQ=$(< "$JQ_DIR/add.jq")
readonly JQ_DIR STORIES_JQ WAVES_JQ ADD_JQ
readonly SCHEDULED_STATES='["not_started","active"]'
readonly UNFINISHED_STATES='["not_started","active","blocked"]'


fail() {
  echo "$1" >&2
  exit 1
}

story_field() {
  jq -r --arg id "$1" "$STORIES_JQ"' stories[] | select(.id == $id) | .'"$2"' // empty' "$FEATURES_FILE"
}

require_state() {
  local id=$1 allowed=$2 state
  state=$(story_field "$id" state)
  [[ -n "$state" ]] || fail "No story $id in $FEATURES_FILE."
  [[ " $allowed " == *" $state "* ]] || fail "$id is $state. This action needs: $allowed."
}

write_features() {
  local filter=$1
  shift
  jq "$@" "$filter" "$FEATURES_FILE" > "$FEATURES_FILE.tmp"
  mv "$FEATURES_FILE.tmp" "$FEATURES_FILE"
}

set_state() {
  write_features '.epics |= map(.stories |= map(if .id == $id then .state = $state | .evidence = $evidence else . end))' \
    --arg id "$1" --arg state "$2" --arg evidence "$3"
  echo "$1 is now $2."
}

add_from_fragment() {
  local fragment candidate
  fragment=$(cat)
  candidate=$(jq --argjson fragment "$fragment" "$STORIES_JQ$ADD_JQ" "$FEATURES_FILE") || fail "Nothing added."
  jq --argjson open_states "$UNFINISHED_STATES" "$WAVES_JQ" <<< "$candidate" > /dev/null || fail "Nothing added."
  printf '%s\n' "$candidate" > "$FEATURES_FILE.tmp"
  mv "$FEATURES_FILE.tmp" "$FEATURES_FILE"
  jq -r '[.epics[]?.stories[]?.id] as $stories | [.sprints[]?.sprint] as $sprints
    | "Added \($stories | length) story(ies) as not_started\(if ($stories | length) > 0 then ": " + ($stories | join(", ")) else "" end), and \($sprints | length) sprint(s)."' <<< "$fragment"
}

show_story() {
  local story
  story=$(jq --arg id "$1" "$STORIES_JQ"' stories[] | select(.id == $id)' "$FEATURES_FILE")
  [[ -n "$story" ]] || fail "No story $1 in $FEATURES_FILE."
  echo "$story"
}

print_status() {
  jq -r "$STORIES_JQ"'
    stories as $all
    | ($all | map(select(.state == "passing") | .id)) as $passing
    | ((.sprints // []) | map({key: (.sprint | tostring), value: .goal}) | from_entries) as $goals
    | $all | group_by(.sprint == null) | map(group_by(.sprint)[]) | .[]
    | (.[0].sprint | tostring) as $sprint
    | "sprint \(if $sprint == "null" then "parked" else $sprint end)\(if $goals[$sprint] then " (\($goals[$sprint]))" else "" end): \(map(select(.state == "passing")) | length)/\(length) passing",
      (.[] | select(.state != "passing")
        | "  \(.id) [\(.state)] \(.name)\(if (.depends_on - $passing | length) > 0 then " (waits on \(.depends_on - $passing | join(", ")))" else "" end)")
  ' "$FEATURES_FILE"
}

print_waves() {
  local result
  result=$(jq -c --argjson open_states "$SCHEDULED_STATES" "$WAVES_JQ" "$FEATURES_FILE")
  jq -r '.skipped[]' <<< "$result" >&2
  jq -r '.waves[] | join(" ")' <<< "$result"
}

start_story() {
  local id=$1 active unmet
  require_state "$id" "not_started blocked"
  active=$(jq -r "$STORIES_JQ"' [stories[] | select(.state == "active") | .id] | join(", ")' "$FEATURES_FILE")
  [[ -z "$active" ]] || fail "One story at a time: $active is active. Finish it with done or park it with block first."
  unmet=$(jq -r --arg id "$id" "$STORIES_JQ"' stories as $all | ($all[] | select(.id == $id) | .depends_on)
    - [$all[] | select(.state == "passing") | .id] | join(", ")' "$FEATURES_FILE")
  [[ -z "$unmet" ]] || fail "$id depends on $unmet, which is not passing yet."
  set_state "$id" active ""
}

base_revision() {
  local default_branch
  default_branch=$(git symbolic-ref -q --short refs/remotes/origin/HEAD 2> /dev/null || echo main)
  git merge-base HEAD "$default_branch" 2> /dev/null || git rev-parse HEAD
}

changed_files() {
  { git diff --name-only "$(base_revision)"; git ls-files --others --exclude-standard; } | sort -u | jq -R . | jq -s .
}

files_outside_owns() {
  jq -r --arg id "$1" --argjson changed "$(changed_files)" --argjson harness "$HARNESS_FILES" "$STORIES_JQ"'
    ((.shared // []) + $harness) as $always_allowed
    | (stories[] | select(.id == $id) | .owns // []) as $owns
    | if ($owns | length) == 0 then empty
      else $changed[] | . as $file | select(any(($owns + $always_allowed)[]; covers($file)) | not) end' "$FEATURES_FILE"
}

check_scope() {
  local id=$1 outside
  [[ -n "$(story_field "$id" state)" ]] || fail "No story $id in $FEATURES_FILE."
  [[ "$(jq -r --arg id "$id" "$STORIES_JQ"' stories[] | select(.id == $id) | .owns // [] | length' "$FEATURES_FILE")" != 0 ]] \
    || { echo "$id has no owns, so its scope is not checked."; return 0; }
  outside=$(files_outside_owns "$id")
  if [[ -n "$outside" ]]; then
    echo "$id changed files outside its owns:" >&2
    echo "$outside" | sed 's/^/  /' >&2
    fail "Undo those changes, or block $id and say which file it needs, so a person can widen its owns."
  fi
  echo "$id changed only files it owns."
}

finish_story() {
  local id=$1 test_filter output revision
  require_state "$id" "active"
  grep -qwF "$id" "$PROGRESS_FILE" || fail "$PROGRESS_FILE does not mention $id, so it stays active. Add what $id changed, why, and what comes next, then run done again."
  check_scope "$id" > /dev/null || exit 1
  make check || fail "make check failed, so $id stays active. Fix the failures above, then run done again."
  test_filter=$(story_field "$id" test_filter)
  output=$(make test-story FILTER="$test_filter" 2>&1) || {
    echo "$output" | tail -30 >&2
    fail "Tests for $id failed, so it stays active."
  }
  revision=$(git rev-parse --short HEAD 2> /dev/null || echo "no commit")
  [[ -z "$(git status --porcelain)" ]] || revision="$revision plus uncommitted changes"
  set_state "$id" passing "tests passed on $revision, $(date -u +%Y-%m-%dT%H:%MZ)"
}

block_story() {
  require_state "$1" "not_started active"
  set_state "$1" blocked "$2"
}

unblock_story() {
  require_state "$1" "blocked"
  set_state "$1" not_started ""
}

validate_features() {
  local errors
  errors=$(jq -r "$STORIES_JQ"'
    stories as $all | ($all | map(.id)) as $ids
    | $all[] | . as $story
    | (if (.state | IN("not_started", "active", "blocked", "passing")) then empty else "\(.id) has unknown state \(.state)." end),
      (if (.state | IN("passing", "blocked")) and ((.evidence // "") == "") then "\(.id) is \(.state) with no evidence. Change state only through feature.sh." else empty end),
      ((.depends_on // [])[] | select(. as $dep | $ids | index($dep) | not) | "\($story.id) depends on \(.), which does not exist.")
  ' "$FEATURES_FILE")
  [[ -z "$errors" ]] || fail "$errors"
  echo "Backlog is consistent."
}

reset_backlog() {
  local active
  active=$(jq -r "$STORIES_JQ"' [stories[] | select(.state == "active") | .id] | join(", ")' "$FEATURES_FILE")
  [[ -z "$active" ]] || fail "$active is active. Finish it with done or park it with block before the reset."
  write_features '.sprints = [] | .epics = []'
  echo "Backlog reset: no sprints, epics or stories left. project_title, priority_legend and shared are kept."
}

cd "$(git rev-parse --show-toplevel)"
command -v jq > /dev/null || fail "jq is required. Install it (brew install jq, or winget install jqlang.jq) and retry."

case "${1:-} $#" in
  "add 1") add_from_fragment ;;
  "show 2") show_story "$2" ;;
  "status 1") print_status ;;
  "waves 1") print_waves ;;
  "start 2") start_story "$2" ;;
  "done 2") finish_story "$2" ;;
  "block 3") block_story "$2" "$3" ;;
  "unblock 2") unblock_story "$2" ;;
  "scope 2") check_scope "$2" ;;
  "validate 1") validate_features ;;
  "reset 1") reset_backlog ;;
  *) fail "$USAGE" ;;
esac
