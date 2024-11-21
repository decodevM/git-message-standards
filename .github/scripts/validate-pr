#!/bin/bash

# Fetch Pull Request data from GitHub API
PR_NUMBER=$1
REPO_OWNER=$2
REPO_NAME=$3

# GitHub token for authentication
GITHUB_TOKEN=$4

# Fetch PR details from GitHub API
PR_DETAILS=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/pulls/$PR_NUMBER")

# Extract title, body (description), and footer (if any)
PR_TITLE=$(echo "$PR_DETAILS" | jq -r .title)
PR_BODY=$(echo "$PR_DETAILS" | jq -r .body)

# Check for title format (Conventional Commit format)
TITLE_REGEX="^([a-z]+)(\([a-z0-9\-]+\))?:\s[a-z0-9\s]+$"

if [[ ! "$PR_TITLE" =~ $TITLE_REGEX ]]; then
  echo "ERROR: Invalid PR title format."
  echo "Title should follow this format: type(scope): description"
  echo "Example: feat(auth): add login functionality"
  exit 1
fi

echo "PR title is valid."

# If there is a body (description), validate it
if [[ -n "$PR_BODY" ]]; then
  # Body validation (optional, based on your criteria)
  BODY_MIN_LENGTH=10  # Minimum length for the body, adjust as needed

  if [[ ${#PR_BODY} -lt $BODY_MIN_LENGTH ]]; then
    echo "ERROR: PR body (description) is too short. Minimum length is $BODY_MIN_LENGTH characters."
    exit 1
  fi

  echo "PR body is valid."
else
  echo "PR body is optional and not provided."
fi

# Check for footer (optional)
FOOTER_REGEX="(Fixes\s#\d+|BREAKING\sCHANGE:.*)"
if [[ -n "$PR_BODY" && "$PR_BODY" =~ $FOOTER_REGEX ]]; then
  echo "PR footer is valid."
else
  echo "ERROR: PR footer (if provided) is invalid. It should be in the format 'Fixes #<issue>' or 'BREAKING CHANGE: <description>'."
  exit 1
fi

# If all checks pass
echo "PR title, body, and footer (if applicable) are valid."
exit 0