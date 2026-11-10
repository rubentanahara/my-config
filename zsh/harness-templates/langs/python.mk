INSTALL_CMD := pip install -e ".[dev]"
BUILD_CMD := python -m compileall -q .
LINT_CMD := ruff check .
FORMAT_CMD := ruff format .
TEST_CMD := pytest
TEST_STORY_CMD := pytest -k "$$FILTER"
