LOGS := .agent

INSTALL_CMD := echo "set INSTALL_CMD in Makefile" && false
BUILD_CMD := echo "set BUILD_CMD in Makefile" && false
LINT_CMD := echo "set LINT_CMD in Makefile" && false
FORMAT_CMD := echo "set FORMAT_CMD in Makefile" && false
TEST_CMD := echo "set TEST_CMD in Makefile" && false
TEST_STORY_CMD := echo "set TEST_STORY_CMD in Makefile (it receives FILTER)" && false
RUN_CMD := echo "set RUN_CMD in Makefile" && false

.PHONY: check setup build lint test test-story format run hooks features clean

check: hooks features build lint test
	@echo "CHECK PASSED: hooks, features, build, lint, tests"

setup:
	git config core.hooksPath .husky
	$(INSTALL_CMD)
	@command -v gitleaks >/dev/null || echo "WARNING: gitleaks is not installed; the pre-commit hook needs it."
	@command -v jq >/dev/null || echo "WARNING: jq is not installed; make check and the scripts in scripts/agent need it."
	@echo "OK   setup. Run make check next."

build:
	@mkdir -p $(LOGS)
	@$(BUILD_CMD) > $(LOGS)/build.log 2>&1 || { \
		tail -20 $(LOGS)/build.log; \
		echo "CHECK FAILED at build. Full log in $(LOGS)/build.log. Fix the errors, then run make check."; \
		exit 1; }
	@echo "OK   build"

lint:
	@mkdir -p $(LOGS)
	@$(LINT_CMD) > $(LOGS)/lint.log 2>&1 || { \
		tail -20 $(LOGS)/lint.log; \
		echo "CHECK FAILED at lint. Run make format to fix it automatically, then run make check."; \
		exit 1; }
	@echo "OK   lint"

test: build
	@$(TEST_CMD) > $(LOGS)/test.log 2>&1 || { \
		tail -40 $(LOGS)/test.log; \
		echo "CHECK FAILED at tests. Full log in $(LOGS)/test.log. Fix the code, not the test, unless the test is wrong."; \
		exit 1; }
	@echo "OK   tests"

test-story: build
	@test -n "$(FILTER)" || { echo "Pass a filter: make test-story FILTER=<filter>"; exit 1; }
	@FILTER="$(FILTER)" $(TEST_STORY_CMD)

hooks:
	@jq -n -e --slurpfile claude .claude/settings.json --slurpfile codex .codex/hooks.json '$$claude[0].hooks != null and $$claude[0].hooks == $$codex[0].hooks' > /dev/null || { \
		echo "CHECK FAILED at hooks. .codex/hooks.json differs from the hooks in .claude/settings.json. Edit .claude/settings.json, then run: jq '{hooks}' .claude/settings.json > .codex/hooks.json"; \
		exit 1; }
	@echo "OK   hooks"

features:
	@mkdir -p $(LOGS)
	@bash scripts/agent/feature.sh validate > $(LOGS)/features.log 2>&1 || { \
		cat $(LOGS)/features.log; \
		echo "CHECK FAILED at features. Change feature_list.json only through scripts/agent/feature.sh."; \
		exit 1; }
	@echo "OK   features"

format:
	$(FORMAT_CMD)
	@echo "OK   format"

run:
	$(RUN_CMD)

clean:
	rm -rf $(LOGS)
	@echo "OK   clean"
