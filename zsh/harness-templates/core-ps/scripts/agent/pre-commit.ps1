if (Get-Command gitleaks -ErrorAction SilentlyContinue) {
    gitleaks protect --staged --redact
    exit $LASTEXITCODE
}
[Console]::Error.WriteLine('WARNING: gitleaks is not installed; staged changes were not scanned for secrets.')
