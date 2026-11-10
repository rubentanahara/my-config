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
  echo "lang: $1 commands set in Makefile"
}

harness() {
  local -a lang
  zparseopts -D -E -- -lang:=lang
  [[ -z $lang || -f "$HARNESS_TEMPLATES/langs/${lang[2]}.mk" ]] || { harness_lang "${lang[2]}"; return 1; }
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

  [[ -z $lang ]] || harness_lang "${lang[2]}" || return 1

  local d
  for d in .claude/{skills,agents,hooks,commands,workflows,routines} .github/{agents,prompts,instructions,workflows,hooks}; do
    [[ -z "$(ls -A "$d")" ]] && touch "$d/.gitkeep"
  done

  command -v jq > /dev/null || echo "WARNING: jq is missing; scripts/agent needs it (brew install jq)."
  command -v gitleaks > /dev/null || echo "WARNING: gitleaks is missing; pre-commit cannot scan (brew install gitleaks)."

  echo "harness ready in $PWD. Next: fill the Makefile commands, AGENTS.md, ARCHITECTURE.md."
}
