#!/usr/bin/env bash
set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || exit 1

untracked_links() {
  git ls-files --others --exclude-standard | while IFS= read -r path; do
    [[ -L "$path" ]] && echo "$path -> $(readlink "$path")"
  done
}

untracked_files() {
  git ls-files --others --exclude-standard | while IFS= read -r path; do
    [[ -L "$path" ]] || echo "$path"
  done
}

{
  git rev-parse HEAD 2> /dev/null
  git diff HEAD --binary 2> /dev/null
  untracked_links
  untracked_files | git hash-object --stdin-paths
} | git hash-object --stdin
