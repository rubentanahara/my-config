#!/usr/bin/env bash
set -uo pipefail

readonly USAGE='Usage: scripts/agent/watch.sh [--once] [--interval <seconds>] [<id>]

Shows each story run.sh started: its result, its implement attempts, the commits and changed files in its worktree,
and the last steps of its sessions. Refreshes until Ctrl+C. Run it in a second terminal next to run.sh.
Steps are recorded for claude sessions only; other CLIs show commits and files.

  --once      print once and exit.
  --interval  seconds between refreshes. Default: 5.
  <id>        show only this story.'
readonly RUNS_DIR=.agent/runs
readonly WORKTREES_DIR=.worktrees
readonly STEPS_SHOWN=5
readonly DEFAULT_INTERVAL_SECONDS=5

main() {
  local once=false interval=$DEFAULT_INTERVAL_SECONDS only=""
  while (( $# > 0 )); do
    case "$1" in
      --once) once=true; shift ;;
      --interval) interval=${2:?$USAGE}; shift 2 ;;
      -h | --help) echo "$USAGE"; return 0 ;;
      -*) echo "$USAGE" >&2; return 1 ;;
      *) only=$1; shift ;;
    esac
  done
  [[ "$interval" =~ ^[1-9][0-9]*$ ]] || { echo "--interval takes a positive number." >&2; return 1; }
  cd "$(git rev-parse --show-toplevel)" || return 1
  if $once; then
    render "$only"
    return
  fi
  while true; do
    clear
    render "$only"
    sleep "$interval"
  done
}

render() {
  local only=$1 dir id found=false
  for dir in "$RUNS_DIR"/*/; do
    [[ -d "$dir" ]] || continue
    id=$(basename "$dir")
    [[ -z "$only" || "$id" == "$only" ]] || continue
    found=true
    render_story "$id"
  done
  $found || echo "No story has started yet. run.sh writes to $RUNS_DIR/<id>."
}

render_story() {
  local id=$1 log_dir="$RUNS_DIR/$1" worktree="$WORKTREES_DIR/$1" attempts
  attempts=$(find "$log_dir" -maxdepth 1 -name 'implement-*.log' | wc -l | tr -d ' ')
  echo "$id  $(story_result "$id")  attempts: $attempts"
  if [[ -d "$worktree" ]]; then
    echo "  commits:"
    git -C "$worktree" log --oneline "$(story_base "$worktree")..HEAD" 2> /dev/null | sed 's/^/    /'
    echo "  changed files: $(git -C "$worktree" status --porcelain | wc -l | tr -d ' ')"
  fi
  if [[ -s "$log_dir/progress.log" ]]; then
    echo "  last steps:"
    tail -n "$STEPS_SHOWN" "$log_dir/progress.log" | sed 's/^/    /'
  fi
  echo
}

story_result() {
  cat "$RUNS_DIR/$1/result" 2> /dev/null || echo "in progress"
}

story_base() {
  local default
  default=$(git -C "$1" symbolic-ref -q --short refs/remotes/origin/HEAD 2> /dev/null || echo main)
  git -C "$1" merge-base HEAD "$default" 2> /dev/null || echo HEAD
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
