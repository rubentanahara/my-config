$branch = 'main'
$requiredCheck = 'check'
$body = @{
    required_status_checks = @{ strict = $false; contexts = @($requiredCheck) }
    enforce_admins = $false
    required_pull_request_reviews = @{ required_approving_review_count = 0 }
    restrictions = $null
} | ConvertTo-Json -Depth 5 -Compress
$body | gh api --method PUT "repos/{owner}/{repo}/branches/$branch/protection" --input - | Out-Null
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "$branch now requires a pull request and a passing '$requiredCheck' job."
