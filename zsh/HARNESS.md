# How to use the harness

`harness` (zsh) and `Invoke-Harness` (PowerShell) add the agent harness to any repository: guardrail docs, git hooks, skills, a story backlog, `make check` as the single definition of green, and a runner that takes stories from test-first implementation to a merged pull request.

For a new .NET API, use the DOTNET_CLEAN_ARCH template instead. It already contains the full harness.

## 1. Set up a repository

Create the project with its own tool first, then add the harness:

```sh
# New project
cargo new app && harness app --lang rust
npm create vite@latest app -- --template react-ts && (cd app && npm install) && harness app --lang node

# Existing project: work on a branch and let an agent fill the md files
cd repo && git switch -c chore/harness
harness --lang go --fill agy        # --fill accepts claude, codex, copilot or agy
```

Language presets: `dotnet`, `go`, `node`, `python`, `rust`. For another language, add `langs/<lang>.mk` (and optionally `langs/<lang>.yml` for CI) under `~/.config/zsh/harness-templates/`, or run `harness` without `--lang` and set the `*_CMD` lines in the Makefile by hand.

Then:

1. Run `make setup && make check`. It must end with `CHECK PASSED`.
2. Fix every line the fill report lists as empty or `Unknown:`.
3. Commit the harness with a `No-Tests: <reason>` line in the message. The TDD gate refuses a source commit without a red test commit or that waiver.
4. Push the branch and merge it through a pull request. `.husky/pre-push` refuses pushes to `main`.

What the setup writes per project:

| CLI | Context | MCP | Hooks |
|---|---|---|---|
| Claude Code | `CLAUDE.md` link to `AGENTS.md` | `.mcp.json` | `.claude/settings.json` |
| Codex | `AGENTS.md` | `.codex/config.toml` (read once the project is trusted) | `.codex/hooks.json` |
| Copilot CLI | `.github/copilot-instructions.md` link | `.mcp.json` | `.github/hooks/` |
| Antigravity (agy) | `AGENTS.md` | `.agents/mcp_config.json` link to `.mcp.json` | `.agents/hooks.json` |

Skills live in `.claude/skills`. `.agents/skills` links to them for Antigravity.

If `codegraph` is installed, `harness` also runs `codegraph init -y` to build the code index in `.codegraph/` (only its own `.gitignore` is committed). The codegraph MCP server keeps the index in sync while it runs. Agents are told in `AGENTS.md` to use `codegraph explore` before grep. Without codegraph, `harness` prints a warning and continues.

## 2. Write stories

With skills, inside any CLI:

```
/prd      writes docs/prd/<feature>.md
/backlog  cuts it into stories through feature.sh add
```

Or by hand:

```sh
scripts/agent/feature.sh add < fragment.json
scripts/agent/feature.sh waves      # stories ready to run, grouped into parallel waves
```

Each story needs `id`, `name`, `title`, `acceptance_criteria`, `test_filter` and `owns`. Never edit `feature_list.json` by hand. Commit the backlog change and merge it through a pull request, so `main` is clean before the runner starts.

## 3. Run stories

Unattended, from a clean `main`:

```sh
scripts/agent/run.sh --dry-run                        # print the plan, start nothing
scripts/agent/run.sh --cli claude --checker agy       # one vendor implements, another reviews
scripts/agent/run.sh --parallel 2 --no-merge          # two stories at once, stop at open pull requests
scripts/agent/run.sh --story F01                      # run one story only
```

`--cli` and `--checker` accept `claude`, `codex`, `copilot` and `agy`. For each story the runner:

1. Creates a worktree in `.worktrees/<id>` and runs `make setup` in it.
2. Has the implementer commit the failing tests as `test(red): ...`, then the code as `feat(<id>): ...`.
3. Runs `make check`, the scope check, the `PROGRESS.md` check, and proves the story's tests fail on the red commit and pass at the end.
4. Has the checker CLI review the change in a fresh, read-only session with the `verify` skill.
5. Opens a pull request, merges it once CI is green, pulls `main`, and starts the next wave.

Each step gets three attempts. After the third failure the story is blocked, and the last finding is recorded.

By hand, in one session:

```
/feature  ->  /tdd  ->  /verify (in a fresh session)  ->  /ship
```

## 4. Keep older repositories up to date

```sh
harness --sync
```

It copies `scripts/agent` and `.husky` from the template, and adds missing skills, subagents and hook files. For a file you changed locally, it shows the diff and asks before replacing it. Without a terminal it keeps your file and says so. Run it on a branch and merge it through a pull request.

## Windows

The same commands exist in PowerShell:

```powershell
. ~/.config/zsh/harness.ps1
Invoke-Harness app -Lang go -Fill agy
Invoke-Harness -Sync
./make.ps1 check
./scripts/agent/run.ps1 -Cli claude -Checker agy -Parallel 2
```

`-Parallel` runs each story as a background job. Follow one with `Get-Content -Wait .agent/runs/<id>/runner.log`.

## When something goes wrong

| Symptom | Fix |
|---|---|
| The runner says the working tree is not clean | Commit or stash first. |
| A story is blocked after 3 attempts | Read `.agent/runs/<id>/`, fix the cause, run `git worktree remove --force .worktrees/<id>`, then run the runner again. |
| A repository still uses an old runner | Run `harness --sync`. |
| A pull request is opened from the wrong GitHub account | Run `gh auth switch -u <account>`. |
| A first commit is refused by the TDD gate | Commit the failing tests as `test(red): ...` first, or add `No-Tests: <reason>` to the message. |

## Not tested yet

- The runner's conflict resolution step.
- `harness.ps1` on a real Windows machine. It was tested with pwsh on macOS.
