#!/bin/bash

# Script to set the health status of a PR on the development server
# Usage: ./scripts/set-health-status.sh <PR_NUMBER> <STATUS>
# STATUS can be "GOOD" or "BAD"

set -e

PR_NUMBER=$1
STATUS=$2

if [ -z "$PR_NUMBER" ] || ( [ "$STATUS" != "GOOD" ] && [ "$STATUS" != "BAD" ] ); then
    echo "Usage: ./scripts/set-health-status.sh <PR_NUMBER> <STATUS>"
    echo "STATUS can be 'GOOD' or 'BAD'"
    exit 1
fi

echo "Attempting to set health status for PR #$PR_NUMBER to $STATUS..."

# Assuming your Django app is running on localhost:8000
# And the API endpoint is /api/health/set/
# The User-Agent header is used for basic authentication (amal-googerit only)
curl -X POST http://localhost:8000/api/health/set \
  -H "Content-Type: application/json" \
  -H "User-Agent: amal-googerit" \
  -d "{\"status\": \"$STATUS\", \"pr_number\": \"$PR_NUMBER\"}"

echo ""
echo "Health status update request sent for PR #$PR_NUMBER with status: $STATUS"
echo "Check GitHub Actions for updates."
