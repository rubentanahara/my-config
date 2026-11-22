harness_mcp() {
  [[ -f .mcp.json ]] && command -v jq > /dev/null || return 0
  local agent name
  local -a cmd
  for agent in codex copilot; do
    command -v "$agent" > /dev/null || continue
    for name in $(jq -r '.mcpServers | keys[]' .mcp.json); do
      "$agent" mcp get "$name" > /dev/null 2>&1 && continue
      cmd=("${(@f)$(jq -r --arg n "$name" '.mcpServers[$n] | .command, .args[]' .mcp.json)}")
      "$agent" mcp add "$name" -- "${cmd[@]}" > /dev/null && echo "mcp: $agent <- $name"
    done
  done
}

HARNESS_TEMPLATES="${${(%):-%x}:A:h}/harness-templates"

harness_lang_ci_setup() {
  local snippet="$HARNESS_TEMPLATES/langs/$1.yml" workflow=.github/workflows/check.yml
  [[ -f $snippet && -f $workflow ]] || return 0
  grep -qF "$(head -n1 "$snippet")" "$workflow" && return 0
  awk -v snippet="$snippet" '{ print } /uses: actions\/checkout@/ { while ((getline line < snippet) > 0) print line }' "$workflow" > "$workflow.tmp" && mv "$workflow.tmp" "$workflow"
}

harness_sync() {
  cp -R "$HARNESS_TEMPLATES/core/scripts/agent/." scripts/agent/
  cp -R "$HARNESS_TEMPLATES/core/.husky/." .husky/
  grep -q '^features:' Makefile 2> /dev/null || echo "sync: Makefile has no features target. Copy it and the check dependency from $HARNESS_TEMPLATES/core/Makefile."
  echo "sync: scripts/agent and .husky updated from the template."
}

harness_fill_check() {
  case $1 in
    claude | codex | copilot | gemini) ;;
    *) echo "unknown --fill '$1'. Available: claude, codex, copilot, gemini"; return 1 ;;
  esac
  (( $+commands[$1] )) || { echo "--fill $1: $1 is not installed."; return 1; }
}

typeset -A HARNESS_CHEAPEST_MODEL=(claude haiku codex gpt-6-luna copilot auto gemini flash-lite)

harness_fill() {
  local cli=$1 model=${2:-$HARNESS_CHEAPEST_MODEL[$1]} prompt
  prompt=$(<"$HARNESS_TEMPLATES/fill-prompt.md")
  echo "fill: asking $cli ($model) to fill the md files"
  case $cli in
    claude) command claude -p "$prompt" --model "$model" --permission-mode acceptEdits --allowedTools "Bash(make *)" "Bash(git log *)" "Bash(git ls-files *)" ;;
    codex) command codex exec -m "$model" -s workspace-write "$prompt" ;;
    copilot) command copilot -p "$prompt" --model "$model" --allow-tool=write --allow-tool='shell(make:*)' --allow-tool='shell(git:*)' --deny-tool='shell(git push)' ;;
    gemini) command gemini -p "$prompt" --model "$model" --approval-mode auto_edit ;;
  esac
}

harness_lang() {
  local preset="$HARNESS_TEMPLATES/langs/$1.mk" line key
  if [[ ! -f $preset ]]; then
    echo "unknown --lang '$1'. Available: $(ls "$HARNESS_TEMPLATES/langs" | sed "s/\.mk$//" | paste -sd, -)"
    return 1
  fi
  while IFS= read -r line; do
    key=${line%% :=*}
    grep -q "^$key := .*set $key in Makefile" Makefile || continue
    VALUE=${line#*:= } KEY=$key awk '$1 == ENVIRON["KEY"] && $2 == ":=" { print ENVIRON["KEY"] " := " ENVIRON["VALUE"]; next } { print }' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
  done < "$preset"
  harness_lang_ci_setup "$1"
  echo "lang: $1 commands set in Makefile"
}

harness() {
  local -a lang sync fill model
  zparseopts -D -E -- -lang:=lang -sync=sync -fill:=fill -model:=model
  [[ -z $lang || -f "$HARNESS_TEMPLATES/langs/${lang[2]}.mk" ]] || { harness_lang "${lang[2]}"; return 1; }
  [[ -z $fill ]] || harness_fill_check "${fill[2]}" || return 1
  local dir="${1:-.}"
  mkdir -p "$dir" && cd "$dir" || return 1

  if [[ ! -d .git ]]; then git init -q && echo "git: initialized"; fi

  cp -Rn "$HARNESS_TEMPLATES/core/." .

  [[ -e CLAUDE.md ]] || ln -s AGENTS.md CLAUDE.md

  mkdir -p \
    .claude/{skills,agents,hooks,commands,workflows,routines} \
    .github/{agents,prompts,instructions,workflows,hooks}

  [[ -e .github/copilot-instructions.md ]] || ln -s ../AGENTS.md .github/copilot-instructions.md

  grep -qxF '.agent/' .gitignore 2> /dev/null || echo '.agent/' >> .gitignore

  git config core.hooksPath .husky

  harness_mcp

  [[ -z $sync ]] || harness_sync

  [[ -z $lang ]] || harness_lang "${lang[2]}" || return 1

  local d
  for d in .claude/{skills,agents,hooks,commands,workflows,routines} .github/{agents,prompts,instructions,workflows,hooks}; do
    [[ -z "$(ls -A "$d")" ]] && touch "$d/.gitkeep"
  done

  command -v jq > /dev/null || echo "WARNING: jq is missing; scripts/agent needs it (brew install jq)."
  command -v gitleaks > /dev/null || echo "WARNING: gitleaks is missing; pre-commit cannot scan (brew install gitleaks)."

  if [[ -n $fill ]]; then
    harness_fill "${fill[2]}" "${model[2]}" || echo "WARNING: ${fill[2]} exited with an error. Review the md files."
    echo "harness ready in $PWD. Review the filled md files and every 'Unknown:' line."
  else
    echo "harness ready in $PWD. Next: fill the Makefile commands, AGENTS.md, ARCHITECTURE.md."
  fi
}
