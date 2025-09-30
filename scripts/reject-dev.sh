#!/bin/bash

# Reject Dev Script
# This script marks the dev/manual-testing check run as failure and rolls back to last successful production deployment

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

log "❌ Rejecting dev testing for commit: $COMMIT_SHA"

# Get the check run ID for dev/manual-testing
log "🔍 Finding dev/manual-testing check run..."

CHECK_RUNS=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/commits/$COMMIT_SHA/check-runs")

CHECK_RUN_ID=$(echo "$CHECK_RUNS" | jq -r '.check_runs[] | select(.name == "dev/manual-testing") | .id')

if [ -z "$CHECK_RUN_ID" ] || [ "$CHECK_RUN_ID" = "null" ]; then
    error "No dev/manual-testing check run found for commit $COMMIT_SHA"
fi

log "📋 Found check run ID: $CHECK_RUN_ID"

# Get last successful production deployment SHA
log "🔍 Finding last successful production deployment..."

LAST_DEPLOYMENT=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO/deployments?environment=production&per_page=1" | \
  jq -r '.[0].sha // empty')

if [ -z "$LAST_DEPLOYMENT" ]; then
    warning "No successful production deployment found, using current HEAD"
    LAST_DEPLOYMENT=$(git rev-parse HEAD~1)
fi

log "📋 Last successful production deployment SHA: $LAST_DEPLOYMENT"

# Update check run to failure
log "❌ Updating check run to failure status..."

curl -s -X PATCH \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/check-runs/$CHECK_RUN_ID" \
  -d '{
    "status": "completed",
    "conclusion": "failure",
    "output": {
      "title": "Manual Testing Failed",
      "summary": "Manual testing failed on Dev droplet - rolling back",
      "text": "❌ Tests failed on Dev droplet\n\n**Rejected by**: amal-googerit\n**Rejection time**: '"$(date)"'\n\n**Rollback target**: `'$LAST_DEPLOYMENT'`\n\nReverting to last successful production deployment."
    }
  }'

if [ $? -ne 0 ]; then
    error "Failed to update check run status"
fi

# Rollback to last successful deployment
log "🔄 Rolling back to last successful deployment: $LAST_DEPLOYMENT"

# Reset working tree to last successful deployment
git reset --hard $LAST_DEPLOYMENT

# Force push the revert
git push origin main --force

log "✅ Rollback completed to SHA: $LAST_DEPLOYMENT"

# Create GitHub issue describing the revert
log "📝 Creating GitHub issue for the revert..."

ISSUE_BODY="## 🔄 Automatic Rollback Performed

**Reason**: Manual testing failed on Dev droplet
**Rejected by**: @amal-googerit
**Rejection time**: $(date)
**Rollback target**: \`$LAST_DEPLOYMENT\`

### 📋 What happened:
1. Changes were merged to main branch
2. Manual testing was performed on Dev droplet
3. Tests failed or issues were found
4. Automatic rollback was triggered
5. Main branch was reset to last successful production deployment

### 🔍 Rollback Details:
- **From commit**: \`$COMMIT_SHA\`
- **To commit**: \`$LAST_DEPLOYMENT\`
- **Action**: Hard reset and force push

### ✅ Next Steps:
1. Investigate the issues found during testing
2. Fix the problems in a new branch
3. Create a new PR with the fixes
4. Repeat the testing process

---
*This rollback was performed automatically by the CI/CD system.*"

curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://api.github.com/repos/$REPO/issues" \
  -d '{
    "title": "🔄 Automatic Rollback - Manual Testing Failed",
    "body": "'$(echo "$ISSUE_BODY" | sed 's/"/\\"/g' | tr '\n' '\\n')'",
    "labels": ["rollback", "testing-failed", "urgent"]
  }' | jq -r '.number'

# Close any related testing issues
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
            "body": "❌ **Manual testing failed and rejected by @amal-googerit**\n\nDev testing failed. Automatic rollback has been performed to last successful production deployment."
          }'
        
        curl -s -X PATCH \
          -H "Authorization: token $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github.v3+json" \
          "https://api.github.com/repos/$REPO/issues/$issue" \
          -d '{"state": "closed"}'
        
        log "📝 Closed issue #$issue"
    fi
done

log "✅ Dev rejection process completed!"
log "🔄 Main branch has been rolled back to: $LAST_DEPLOYMENT"
log "📝 GitHub issue created describing the rollback"

# Send Slack notification if enabled
if [ "$ENABLE_SLACK" = "true" ] && [ ! -z "$SLACK_WEBHOOK_URL" ]; then
    log "📢 Sending Slack notification..."
    
    SLACK_MESSAGE="{
      \"text\": \"❌ Dev Testing Rejected - Rollback Performed\",
      \"blocks\": [
        {
          \"type\": \"header\",
          \"text\": {
            \"type\": \"plain_text\",
            \"text\": \"❌ Dev Testing Rejected - Rollback Performed\"
          }
        },
        {
          \"type\": \"section\",
          \"fields\": [
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Commit:* \`$COMMIT_SHA\`\"
            },
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Rejected by:* @amal-googerit\"
            },
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Status:* ❌ Rolled back\"
            },
            {
              \"type\": \"mrkdwn\",
              \"text\": \"*Repository:* $REPO\"
            }
          ]
        },
        {
          \"type\": \"section\",
          \"text\": {
            \"type\": \"mrkdwn\",
            \"text\": \"🔄 *Rollback Details:*\\nMain branch has been reset to: \`$LAST_DEPLOYMENT\`\\n\\nPlease investigate the issues and create a new PR with fixes.\"
          }
        }
      ]
    }"
    
    curl -X POST "$SLACK_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "$SLACK_MESSAGE" || warning "Failed to send Slack notification"
fi
