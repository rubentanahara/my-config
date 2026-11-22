You are finishing the setup of an agent harness that was just copied into this existing project. The harness files are templates with empty fields. Fill them from facts you find in this repository.

## Discover first
Read before you write: README, package or build manifests, CI files, the directory tree, the test layout, `git log -n 30`, and any existing docs. Read `AGENTS.md`, `ARCHITECTURE.md`, `SECURITY.md`, `PROGRESS.md` and `Makefile` so you know which fields are empty.

## Fill
- `AGENTS.md`: replace the one-line placeholder with what the project is, its language and its runtime version.
- `ARCHITECTURE.md`: every section. Layers and their allowed dependencies, the seam where behavior is tested, the directory map, who owns each dataset, conventions you can see in the code, and decisions the history or docs record.
- `SECURITY.md`: where secrets come from, where untrusted input enters and is validated, and who receives vulnerability reports.
- `Makefile`: any `*_CMD` line that still reads `set ... in Makefile`. Use the project's real commands. Check that they run with `make build`, `make lint` and `make test`.
- `PROGRESS.md`: Current state (the `make check` result and the backlog, which is empty) and Next steps. State what is broken today, such as a failing lint or test, without fixing it.

## Rules
- Write only what the repository shows. When a fact is missing, write `Unknown: <what a person must confirm>` in that field. Never invent a layer, a contact, a version or a command.
- A file that already holds real content, with no template placeholders, stays as it is. Add only its missing sections.
- Keep every template heading. Keep the text short: one line per fact.
- Leave `GUARDRAILS.md`, `CHANGELOG.md`, `session-handoff.md`, `feature_list.json`, `.husky/`, `.claude/`, `.codex/`, `.github/` and `scripts/` unchanged.
- Do not edit source code or tests, do not install dependencies, do not commit, and do not push.
- If the project's test files would not match the default patterns in `scripts/agent/tdd-gate.sh`, create `.tdd.conf` with `TEST_PATTERN` set to match them. Otherwise create nothing.

## Done when
Run `make check` and quote its last line. A failure on a brownfield project is a finding, not your task: record it in `PROGRESS.md`. Finish with a short list of the files you filled and every `Unknown:` you wrote.
