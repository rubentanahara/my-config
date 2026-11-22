#!/usr/bin/env bash
set -euo pipefail

readonly BRANCH=main
readonly REQUIRED_CHECK=check

gh api --method PUT "repos/{owner}/{repo}/branches/$BRANCH/protection" --input - > /dev/null <<JSON
{
  "required_status_checks": {"strict": false, "contexts": ["$REQUIRED_CHECK"]},
  "enforce_admins": false,
  "required_pull_request_reviews": {"required_approving_review_count": 0},
  "restrictions": null
}
JSON
echo "$BRANCH now requires a pull request and a passing '$REQUIRED_CHECK' job."
