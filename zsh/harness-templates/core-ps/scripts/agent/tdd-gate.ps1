param([string]$MessageFile)

$patterns = @{
    TEST_CONTENT_PATTERN = '^\+.*(#\[test\]|#\[cfg\(test\)\]|@Test\b|\[(Fact|Test|TestMethod|Theory)\]|\b(describe|it|test)\(|def test_|func Test[A-Z]|\bassert)'
    TEST_PATTERN         = '(^|/)(tests?|__tests__|spec)/|(^|/)test_|[._]test\.|[._]spec\.|_test\.|Tests?\.[a-z]+$'
    NON_SOURCE_PATTERN   = '\.(md|json|ya?ml|toml|lock|txt)$|^(Makefile|make\.ps1|commands\.mk|\.gitignore)$|^(\.husky|\.claude|\.codex|\.github|scripts|docs)/'
}
if (Test-Path .tdd.conf) {
    foreach ($line in Get-Content .tdd.conf) {
        if ($line -match '^(TEST_CONTENT_PATTERN|TEST_PATTERN|NON_SOURCE_PATTERN)=([''"]?)(.*)\2\s*$') { $patterns[$Matches[1]] = $Matches[3] }
    }
}

$makeScript = Join-Path (git rev-parse --show-toplevel) 'make.ps1'

function Stop-Gate([string]$Reason) {
    [Console]::Error.WriteLine("TDD gate: $Reason")
    exit 1
}

function Test-RedCommitOnBranch {
    $subjects = git log --format=%s main..HEAD 2> $null
    if ($LASTEXITCODE -ne 0) { $subjects = git log -n 50 --format=%s 2> $null }
    [bool](@($subjects) -match '^test\(red\)')
}

function Test-Waiver {
    foreach ($line in Get-Content $MessageFile) {
        if ($line -match '^# -* >8 -*$') { break }
        if ($line -notmatch '^#' -and $line -match '^No-Tests: .+') { return $true }
    }
    $false
}

function Test-Passes([string]$Task) {
    & $makeScript $Task *> $null
    $LASTEXITCODE -eq 0
}

$subject = @(Get-Content $MessageFile)[0]
if ($subject -match '^(revert|Merge)') { exit 0 }

$staged = @(git diff --cached --name-only)
$stagedTests = @($staged | Where-Object { $_ -match $patterns.TEST_PATTERN })
$stagedSource = @($staged | Where-Object { $_ -notmatch $patterns.TEST_PATTERN -and $_ -notmatch $patterns.NON_SOURCE_PATTERN })
if ($stagedTests.Count -eq 0 -and (@(git diff --cached -U0) -match $patterns.TEST_CONTENT_PATTERN)) { $stagedTests = @('content') }

if ($subject -match '^test\(red\)') {
    if ($stagedTests.Count -eq 0) { Stop-Gate 'a red commit must stage a test file.' }
    if (Test-Passes 'test') { Stop-Gate 'red commit, but make test passes. Write a test that fails for the behavior you are about to add.' }
    exit 0
}

if ($stagedSource.Count -eq 0) { exit 0 }

if (-not (Test-Waiver) -and -not (Test-RedCommitOnBranch)) {
    Stop-Gate "source changed but this branch has no 'test(red): ...' commit. Commit the failing tests first, or add a line 'No-Tests: <reason>' to the message."
}

if (-not (Test-Passes 'check')) { Stop-Gate 'make check fails. A green commit needs passing build, lint and tests. Run ./make.ps1 check.' }
exit 0
