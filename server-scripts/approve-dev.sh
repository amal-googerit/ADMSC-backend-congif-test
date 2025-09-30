#!/bin/bash

# Approve Dev Script
# This script marks the dev/manual-testing check run as success

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO="${GITHUB_REPO:-}"
COMMIT_SHA="${COMMIT_SHA:-$(git rev-parse HEAD)}"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check if running as amal-googerit
if [ "$USER" != "amal-googerit" ] && [ "$(whoami)" != "amal-googerit" ]; then
    error "This script can only be run by amal-googerit"
fi

# Validate required variables
if [ -z "$GITHUB_TOKEN" ]; then
    error "GITHUB_TOKEN environment variable is required"
fi

if [ -z "$REPO" ]; then
    error "GITHUB_REPO environment variable is required (format: owner/repo)"
fi

log "✅ Approving dev testing for commit: $COMMIT_SHA"

# Get the check run ID for dev/manual-testing
log "🔍 Finding dev/manual-testing check run..."

CHECK_RUNS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/commits/$COMMIT_SHA/check-runs")

CHECK_RUN_ID=$(echo "$CHECK_RUNS" | jq -r '.check_runs[] | select(.name == "dev/manual-testing") | .id')

if [ -z "$CHECK_RUN_ID" ] || [ "$CHECK_RUN_ID" = "null" ]; then
    error "No dev/manual-testing check run found for commit $COMMIT_SHA"
fi

log "📋 Found check run ID: $CHECK_RUN_ID"

# Update check run to success
log "✅ Updating check run to success status..."

curl -s -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/check-runs/$CHECK_RUN_ID" \
  -d '{
    "status": "completed",
    "conclusion": "success",
    "output": {
      "title": "Manual Testing Approved",
      "summary": "Manual testing completed successfully on Dev droplet",
      "text": "✅ All tests passed on Dev droplet\n\n**Approved by**: amal-googerit\n**Approval time**: '"$(date)"'\n\nReady for production deployment."
    }
  }'

if [ $? -eq 0 ]; then
    log "✅ Dev testing approved successfully!"
    log "🚀 Production deployment can now be triggered"

    # Close any related issues
    log "📝 Closing related GitHub issues..."

    ISSUES=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$REPO/issues?state=open&labels=testing,manual-approval" | \
      jq -r '.[] | select(.title | contains("Manual Testing Required")) | .number')

    for issue in $ISSUES; do
        if [ ! -z "$issue" ] && [ "$issue" != "null" ]; then
            curl -s -X POST \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github.v3+json" \
              "https://api.github.com/repos/$REPO/issues/$issue/comments" \
              -d '{
                "body": "✅ **Manual testing approved by @amal-googerit**\n\nDev testing completed successfully. Ready for production deployment."
              }'

            curl -s -X PATCH \
              -H "Authorization: token $GITHUB_TOKEN" \
              -H "Accept: application/vnd.github.v3+json" \
              "https://api.github.com/repos/$REPO/issues/$issue" \
              -d '{"state": "closed"}'

            log "📝 Closed issue #$issue"
        fi
    done

    echo ""
    log "🎉 Dev approval process completed!"
    log "📋 Next steps:"
    log "1. Go to GitHub Actions → Production Deployment"
    log "2. Click 'Run workflow'"
    log "3. Select mode: 'deploy'"
    log "4. Click 'Run workflow'"

else
    error "Failed to update check run status"
fi
