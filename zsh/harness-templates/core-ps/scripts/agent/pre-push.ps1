$protectedRef = 'refs/heads/main'

function Test-OnlyZeros([string]$Sha) { $Sha -match '^0+$' }

foreach ($line in @($input)) {
    $parts = "$line".Trim() -split '\s+'
    if ($parts.Count -lt 4) { continue }
    $localSha, $remoteRef, $remoteSha = $parts[1], $parts[2], $parts[3]
    if ($remoteRef -eq $protectedRef) {
        Write-Host 'Push to main refused: main changes only through a pull request. Push a feature branch and open one with gh pr create.'
        exit 1
    }
    if ((Test-OnlyZeros $localSha) -or (Test-OnlyZeros $remoteSha)) { continue }
    git cat-file -e "$remoteSha^{commit}" 2> $null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Push refused: $remoteRef has commits this clone does not have. Run git fetch, merge them, then push."
        exit 1
    }
    git merge-base --is-ancestor $remoteSha $localSha
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Force push refused: $remoteRef would lose commits that are already pushed. Merge instead of rewriting a pushed branch."
        exit 1
    }
}
exit 0
