INSTALL_CMD := npm ci
BUILD_CMD := npm run build --if-present
LINT_CMD := npm run lint
FORMAT_CMD := npm run format
TEST_CMD := npm test
TEST_STORY_CMD := npm test -- -t "$$FILTER"
RUN_CMD := npm start
