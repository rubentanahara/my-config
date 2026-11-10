INSTALL_CMD := cargo fetch
BUILD_CMD := cargo build --all-targets
LINT_CMD := cargo clippy --all-targets -- -D warnings
FORMAT_CMD := cargo fmt
TEST_CMD := cargo test
TEST_STORY_CMD := cargo test "$$FILTER"
RUN_CMD := cargo run
