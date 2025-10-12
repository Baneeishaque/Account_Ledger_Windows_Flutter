#!/bin/bash
set -euo pipefail

# Extract hostname from the repository URL
REPO_HOST=$(echo "$CONFIGURATION_REPO" | sed -E 's/^(https?|git)@?:\]\/\/([^\/]+)\/.*/\3/')

GIT_CONFIG_URL_REWRITE=""

case "$REPO_HOST" in
    "github.com")
        GIT_CONFIG_URL_REWRITE="https://oauth2:${CONFIGURATION_REPO_ACCESS_TOKEN}@github.com"
        ;;
    "gitlab.com")
        GIT_CONFIG_URL_REWRITE="https://oauth2:${CONFIGURATION_REPO_ACCESS_TOKEN}@gitlab.com"
        ;;
    "dev.azure.com")
        # For Azure DevOps, PATs are used as the password. 'oauth2' is a common placeholder username.
        # The git config will rewrite 'https://dev.azure.com' to 'https://oauth2:<PAT>@dev.azure.com'.
        GIT_CONFIG_URL_REWRITE="https://oauth2:${CONFIGURATION_REPO_ACCESS_TOKEN}@dev.azure.com"
        ;;
    *)
        # Default to a generic token injection if host is not explicitly handled.
        # This might not work for all hosts, but provides a fallback.
        echo "Warning: Unknown repository host '$REPO_HOST'. Attempting generic token injection."
        GIT_CONFIG_URL_REWRITE="https://oauth2:${CONFIGURATION_REPO_ACCESS_TOKEN}@${REPO_HOST}"
        ;;
esac

# Configure Git to use the access token for the detected host.
# This rewrites URLs like 'https://host.com/repo' to 'https://oauth2:TOKEN@host.com/repo'.
git config --global url."${GIT_CONFIG_URL_REWRITE}".insteadOf "https://${REPO_HOST}"

# Clone the private configurations repository
git clone "$CONFIGURATION_REPO" configurations-private

# Copy the .env file to the project root
cp configurations-private/AccountLedger/.env ./.env

# Clean up the cloned repository
rm -rf configurations-private
