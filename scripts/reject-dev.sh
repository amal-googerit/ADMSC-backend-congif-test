#!/bin/bash

# Script to reject dev testing on the Dev droplet
# This script marks the 'dev/manual-testing' check run as failure,
# rolls back the Dev working tree to the last successful production deployment,
# and creates a GitHub Issue.

set -e

# Configuration
GITHUB_TOKEN=${GITHUB_TOKEN:-} # Ensure GITHUB_TOKEN is set in environment
GITHUB_REPO=${GITHUB_REPO:-}   # Ensure GITHUB_REPO (e.g., user/repo) is set
ACTOR="amal-googerit"          # The user who can reject

if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPO" ]; then
    echo "Error: GITHUB_TOKEN and GITHUB_REPO environment variables must be set."
    exit 1
fi

# Get the latest commit SHA on the main branch
LATEST_COMMIT_SHA=$(git rev-parse HEAD)

echo "Rejecting manual testing for commit: $LATEST_COMMIT_SHA"

# 1. Find the last successful production deployment SHA
echo "Finding last successful production deployment SHA..."
LAST_PROD_DEPLOY_SHA=$(curl -s -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/deployments?environment=production&per_page=1&state=success" | \
  jq -r '.[0].sha // "unknown"')

if [ "$LAST_PROD_DEPLOY_SHA" == "unknown" ]; then
    echo "Warning: Could not find a previous successful production deployment. Cannot rollback to a safe state."
    ROLLBACK_MESSAGE="No previous successful production deployment found for rollback."
else
    echo "Last successful production deployment SHA: $LAST_PROD_DEPLOY_SHA"
    # 2. Reset the Dev working tree to that safe SHA
    echo "Attempting to rollback Dev server to $LAST_PROD_DEPLOY_SHA..."
    git fetch origin main
    git reset --hard "$LAST_PROD_DEPLOY_SHA"
    # Restart services (assuming docker-compose in /opt/admsc-backend-dev)
    cd /opt/admsc-backend-dev # Adjust this path if necessary
    docker compose -f compose/prod/docker-compose.yml down
    docker compose -f compose/prod/docker-compose.yml up --build -d
    echo "Dev server rolled back to $LAST_PROD_DEPLOY_SHA and services restarted."
    ROLLBACK_MESSAGE="Dev server rolled back to last successful production deployment ($LAST_PROD_DEPLOY_SHA)."
fi

# 3. Mark the dev/manual-testing check run as failure
echo "Marking 'dev/manual-testing' check run as FAILURE..."
curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/check-runs" \
  -d '{
    "name": "dev/manual-testing",
    "head_sha": "'"$LATEST_COMMIT_SHA"'",
    "status": "completed",
    "conclusion": "failure",
    "output": {
      "title": "Manual Testing Rejected by '$ACTOR'",
      "summary": "The changes on the development server have been manually tested and REJECTED by '$ACTOR'.\n\n'$ROLLBACK_MESSAGE'"
    }
  }'

# 4. Create a GitHub Issue describing the revert
echo "Creating GitHub Issue for rejection..."
ISSUE_TITLE="[ACTION REQUIRED] Dev Deployment Rejected for Commit $LATEST_COMMIT_SHA"
ISSUE_BODY="Manual testing for commit \`$LATEST_COMMIT_SHA\` was rejected by @$ACTOR.\n\n**Reason:** The changes introduced issues on the development server.\n\n**Action Taken:**\n- The \`dev/manual-testing\` check run was marked as \`failure\`.\n- $ROLLBACK_MESSAGE\n\n**Next Steps:**\n- Review the changes in PR associated with \`$LATEST_COMMIT_SHA\`.\n- Create a new PR with fixes or revert the problematic merge from main if necessary."

curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/issues" \
  -d '{
    "title": "'"$ISSUE_TITLE"'",
    "body": "'"$ISSUE_BODY"'",
    "assignees": ["'"$ACTOR"'"],
    "labels": ["bug", "dev-ops"]
  }'

echo "Manual testing for commit $LATEST_COMMIT_SHA marked as FAILURE. An issue has been created."
