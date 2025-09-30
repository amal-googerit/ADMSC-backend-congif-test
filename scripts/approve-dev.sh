#!/bin/bash

# Script to approve dev testing on the Dev droplet
# This script marks the 'dev/manual-testing' check run as success.

set -e

# Configuration
GITHUB_TOKEN=${GITHUB_TOKEN:-} # Ensure GITHUB_TOKEN is set in environment
GITHUB_REPO=${GITHUB_REPO:-}   # Ensure GITHUB_REPO (e.g., user/repo) is set
ACTOR="amal-googerit"          # The user who can approve

if [ -z "$GITHUB_TOKEN" ] || [ -z "$GITHUB_REPO" ]; then
    echo "Error: GITHUB_TOKEN and GITHUB_REPO environment variables must be set."
    exit 1
fi

# Get the latest commit SHA on the main branch
LATEST_COMMIT_SHA=$(git rev-parse HEAD)

echo "Approving manual testing for commit: $LATEST_COMMIT_SHA"

# Create a successful check run
curl -s -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$GITHUB_REPO/check-runs" \
  -d '{
    "name": "dev/manual-testing",
    "head_sha": "'"$LATEST_COMMIT_SHA"'",
    "status": "completed",
    "conclusion": "success",
    "output": {
      "title": "Manual Testing Approved by '$ACTOR'",
      "summary": "The changes on the development server have been manually tested and approved by '$ACTOR'."
    }
  }'

echo "Manual testing for commit $LATEST_COMMIT_SHA marked as SUCCESS."
