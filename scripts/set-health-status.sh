#!/bin/bash
# Health Status Management Script for amal-googerit
# Usage: ./set-health-status.sh <PR_NUMBER> <STATUS>
# Example: ./set-health-status.sh 123 GOOD

set -e

# Configuration
API_URL="http://localhost:8000/api/health/set"
PR_NUMBER="$1"
STATUS="$2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo "Usage: $0 <PR_NUMBER> <STATUS>"
    echo ""
    echo "PR_NUMBER: The GitHub PR number"
    echo "STATUS: GOOD or BAD"
    echo ""
    echo "Examples:"
    echo "  $0 123 GOOD    # Set health status to GOOD for PR #123"
    echo "  $0 123 BAD     # Set health status to BAD for PR #123"
    echo ""
    echo "This script is only for amal-googerit"
    exit 1
}

# Check if running as amal-googerit
if [ "$USER" != "amal-googerit" ] && [ "$(whoami)" != "amal-googerit" ]; then
    echo -e "${RED}❌ Error: This script can only be run by amal-googerit${NC}"
    exit 1
fi

# Validate arguments
if [ -z "$PR_NUMBER" ] || [ -z "$STATUS" ]; then
    echo -e "${RED}❌ Error: Missing required arguments${NC}"
    usage
fi

# Validate status
if [ "$STATUS" != "GOOD" ] && [ "$STATUS" != "BAD" ]; then
    echo -e "${RED}❌ Error: STATUS must be either GOOD or BAD${NC}"
    usage
fi

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Error: PR_NUMBER must be a number${NC}"
    usage
fi

echo -e "${YELLOW}🔧 Setting health status for PR #$PR_NUMBER to $STATUS...${NC}"

# Check if API is accessible
if ! curl -s -f "$API_URL" > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Cannot connect to API at $API_URL${NC}"
    echo "Make sure the Django application is running and accessible."
    exit 1
fi

# Set health status
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "User-Agent: amal-googerit" \
    -d "{\"status\": \"$STATUS\", \"pr_number\": \"$PR_NUMBER\"}")

# Check if the response contains success
if echo "$RESPONSE" | grep -q "success"; then
    echo -e "${GREEN}✅ Health status set successfully!${NC}"
    echo "Response: $RESPONSE"

    # Show next steps based on status
    if [ "$STATUS" = "GOOD" ]; then
        echo ""
        echo -e "${GREEN}🚀 Next Steps:${NC}"
        echo "1. Go to GitHub Actions → PR Management Actions"
        echo "2. Select action: 'deploy-production'"
        echo "3. Enter PR number: $PR_NUMBER"
        echo "4. Type 'CONFIRM' to deploy to production"
    else
        echo ""
        echo -e "${RED}🔄 Next Steps:${NC}"
        echo "1. Go to GitHub Actions → PR Management Actions"
        echo "2. Select action: 'revert' or 'delete-branch'"
        echo "3. Enter PR number: $PR_NUMBER"
        echo "4. Type 'CONFIRM' to revert or delete"
    fi
else
    echo -e "${RED}❌ Error: Failed to set health status${NC}"
    echo "Response: $RESPONSE"
    exit 1
fi

echo ""
echo -e "${YELLOW}📊 Current health status:${NC}"
curl -s "http://localhost:8000/api/health/status/?pr_number=$PR_NUMBER" | python3 -m json.tool 2>/dev/null || echo "Could not fetch current status"
