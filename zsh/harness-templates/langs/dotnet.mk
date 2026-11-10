INSTALL_CMD := dotnet restore
BUILD_CMD := dotnet build --no-restore
LINT_CMD := dotnet format --verify-no-changes
FORMAT_CMD := dotnet format
TEST_CMD := dotnet test --no-build
TEST_STORY_CMD := dotnet test --no-build --filter "$$FILTER"
RUN_CMD := dotnet run
