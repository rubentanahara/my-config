harness_mcp() {
  [[ -f .mcp.json ]] && command -v jq > /dev/null || return 0
  local name
  mkdir -p .codex .agents
  for name in $(jq -r '.mcpServers | keys[]' .mcp.json); do
    grep -qxF "[mcp_servers.$name]" .codex/config.toml 2> /dev/null && continue
    jq -r --arg n "$name" '.mcpServers[$n] | "\n[mcp_servers.\($n)]\ncommand = \(.command | tojson)\nargs = \(.args // [] | tojson)"' .mcp.json >> .codex/config.toml
  done
  [[ -e .agents/mcp_config.json ]] || ln -s ../.mcp.json .agents/mcp_config.json
  echo "mcp: project-level only. claude and copilot read .mcp.json, agy reads .agents/mcp_config.json (a link to it), codex reads .codex/config.toml."
}

harness_codegraph() {
  [[ -d .codegraph ]] && return 0
  command -v codegraph > /dev/null || { echo "WARNING: codegraph is missing; the code index was not built (see the codegraph README to install it)."; return 0; }
  codegraph init -y > .agent/codegraph-init.log 2>&1 && echo "codegraph: indexed. The MCP server keeps it in sync while it runs." || echo "WARNING: codegraph init failed. Log: .agent/codegraph-init.log"
}

HARNESS_TEMPLATES="${${(%):-%x}:A:h}/harness-templates"

harness_lang_ci_setup() {
  local snippet="$HARNESS_TEMPLATES/langs/$1.yml" workflow=.github/workflows/check.yml
  [[ -f $snippet && -f $workflow ]] || return 0
  grep -qF "$(head -n1 "$snippet")" "$workflow" && return 0
  awk -v snippet="$snippet" '{ print } /uses: actions\/checkout@/ { while ((getline line < snippet) > 0) print line }' "$workflow" > "$workflow.tmp" && mv "$workflow.tmp" "$workflow"
}

harness_makefile_rule() {
  awk -v target="$1" '$0 ~ "^" target ":" { found = 1; print; next } found && /^\t/ { print; next } { found = 0 }' "$HARNESS_TEMPLATES/core/Makefile"
}

harness_merge_makefile() {
  local name target
  for name in LOGS HOOK_SCRIPTS_JQ INSTALL_CMD; do
    grep -q "^$name :=" Makefile || { echo; grep "^$name :=" "$HARNESS_TEMPLATES/core/Makefile"; } >> Makefile
  done
  for target in setup hooks agents harness features; do
    grep -q "^$target:" Makefile && continue
    { echo; echo ".PHONY: $target"; harness_makefile_rule $target; } >> Makefile
    echo "makefile: added the $target target"
  done
  grep -Eq '^check:.*\<hooks\>' Makefile && return 0
  grep -q '^check:' Makefile || { echo; echo ".PHONY: check"; } >> Makefile
  { echo; echo "check: hooks agents harness features"; } >> Makefile
  echo "makefile: check now also runs hooks agents harness features"
}

harness_sync() {
  cp -R "$HARNESS_TEMPLATES/core/scripts/agent/." scripts/agent/
  cp -R "$HARNESS_TEMPLATES/core/.husky/." .husky/
  local template
  for template in "$HARNESS_TEMPLATES/core/".claude/{skills,agents}/**/*(.N) "$HARNESS_TEMPLATES/core/"{.claude/settings.json,.codex/hooks.json,.agents/hooks.json}(.N); do
    harness_sync_file "$template" "${template#$HARNESS_TEMPLATES/core/}"
  done
  local target
  for target in features setup; do
    grep -q "^$target:" Makefile 2> /dev/null || echo "sync: Makefile has no $target target. Copy it from $HARNESS_TEMPLATES/core/Makefile and add it to .PHONY."
  done
  bash scripts/agent/sync-agents.sh
  [[ -d .gemini ]] && echo "sync: .gemini/ is from an older harness and nothing uses it now. Delete it if you do not use Gemini CLI."
  harness_codegraph
  echo "sync: scripts/agent and .husky updated from the template."
  make hooks agents
}

harness_sync_file() {
  local template=$1 target=$2
  if [[ ! -e $target ]]; then
    mkdir -p "${target:h}" && cp "$template" "$target" && echo "sync: added $target"
    return
  fi
  cmp -s "$template" "$target" && return
  if [[ ! -t 0 ]]; then
    echo "sync: kept $target, which differs from the template. Run harness --sync in a terminal to review it."
    return
  fi
  diff -u "$target" "$template"
  if read -q "?sync: replace $target with the template above? [y/N] "; then
    cp "$template" "$target" && echo "\nsync: replaced $target"
  else
    echo "\nsync: kept $target"
  fi
}

harness_fill_check() {
  case $1 in
    claude | codex | copilot | agy) ;;
    *) echo "unknown --fill '$1'. Available: claude, codex, copilot, agy"; return 1 ;;
  esac
  (( $+commands[$1] )) || { echo "--fill $1: $1 is not installed."; return 1; }
}

typeset -A HARNESS_CHEAPEST_MODEL=(claude haiku codex gpt-6-luna copilot auto agy gemini-3.8-flash-low)

harness_fill() {
  local cli=$1 model=${2:-$HARNESS_CHEAPEST_MODEL[$1]} prompt
  prompt=$(<"$HARNESS_TEMPLATES/fill-prompt.md")
  echo "fill: asking $cli ($model) to fill the md files"
  case $cli in
    claude) command claude -p "$prompt" --model "$model" --permission-mode acceptEdits --allowedTools "Bash(make *)" "Bash(git log *)" "Bash(git ls-files *)" ;;
    codex) command codex exec -m "$model" -s workspace-write "$prompt" ;;
    copilot) command copilot -p "$prompt" --model "$model" --allow-tool=write --allow-tool='shell(make:*)' --allow-tool='shell(git:*)' --deny-tool='shell(git push)' ;;
    agy) command agy -p "$prompt" --model "$model" --mode auto --sandbox ;;
  esac
}

harness_fill_report() {
  local left
  left=$(grep -nE '^<One line|set [A-Z_]+ in Makefile|^- [^:]+:$|^\| \| \||what lives here|YYYY-MM-DD|Unknown:' AGENTS.md ARCHITECTURE.md SECURITY.md PROGRESS.md Makefile 2> /dev/null)
  if [[ -z $left ]]; then
    echo "fill: every field is filled."
    return
  fi
  echo "fill: these lines are still empty or Unknown. A person must fill or confirm them:"
  echo "$left"
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

  local had_makefile=0
  [[ -f Makefile ]] && had_makefile=1

  cp -Rn "$HARNESS_TEMPLATES/core/." .

  (( had_makefile )) && harness_merge_makefile

  [[ -e CLAUDE.md ]] || ln -s AGENTS.md CLAUDE.md

  mkdir -p \
    .claude/{skills,agents,hooks,commands,workflows,routines} \
    .github/{agents,prompts,instructions,workflows,hooks}

  [[ -e .github/copilot-instructions.md ]] || ln -s ../AGENTS.md .github/copilot-instructions.md

  mkdir -p .agents
  [[ -e .agents/skills ]] || ln -s ../.claude/skills .agents/skills

  local ignored
  for ignored in .agent/ .worktrees/; do
    grep -qxF "$ignored" .gitignore 2> /dev/null || echo "$ignored" >> .gitignore
  done

  git config core.hooksPath .husky

  harness_mcp

  mkdir -p .agent
  harness_codegraph
  [[ -d .codex/agents ]] || bash scripts/agent/sync-agents.sh

  [[ -z $sync ]] || harness_sync

  [[ -z $lang ]] || harness_lang "${lang[2]}" || return 1

  local d
  for d in .claude/{skills,agents,hooks,commands,workflows,routines} .github/{agents,prompts,instructions,workflows,hooks}; do
    [[ -z "$(ls -A "$d")" ]] && touch "$d/.gitkeep"
  done

  command -v jq > /dev/null || echo "WARNING: jq is missing; scripts/agent needs it (brew install jq)."
  command -v copilot > /dev/null && echo "copilot: it loads repository hooks and .mcp.json only in trusted folders. Add $PWD to trustedFolders in ~/.copilot/config.json."
  command -v gitleaks > /dev/null || echo "WARNING: gitleaks is missing; pre-commit cannot scan (brew install gitleaks)."

  if [[ -n $fill ]]; then
    harness_fill "${fill[2]}" "${model[2]}" || echo "WARNING: ${fill[2]} exited with an error. Review the md files."
    harness_fill_report
    echo "harness ready in $PWD. Review the filled md files."
  else
    echo "harness ready in $PWD. Next: fill the Makefile commands, AGENTS.md, ARCHITECTURE.md."
  fi
}
