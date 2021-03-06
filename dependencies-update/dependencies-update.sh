#!/bin/sh

DEPENDENCIES_SCOPE=$1
GIT_COMMIT_MESSAGE=$2
GIT_COMMIT_BRANCH=$3

# Check for updates in the scoped dependencies
yarn upgrade --scope "$DEPENDENCIES_SCOPE"

if git diff --quiet --exit-code 2>&1; then
  echo "No changes... Bye!"
  exit 0
fi

# Create a branch on which to commit the changes using the "actions" namespace
# (please, nobody commit to this branch, you might loose your changes).
git checkout -b "$GIT_COMMIT_BRANCH"

# Commit the changes with a simple message
git commit -am "$GIT_COMMIT_MESSAGE"

# Push the branch to GitHub (we're using -f here to make that if there's a
# pending PR open against this branch, it'll just be updated with the latest
# changes).
git push -u origin "$(git rev-parse --abbrev-ref HEAD)" -f

if ! command -v gh 2>&1 /dev/null; then
  echo "GitHub CLI not found. Please create the PR manually."
  exit
fi

# Create a PR from this branch.
gh pr create \
  --title "$GIT_COMMIT_MESSAGE" \
  --body "This is an automated dependency update, review me!" \
  --label dependencies

# `gh pr create` now sets its exit code according to the outcome of the action,
# so we'll set the exit code explictly here to avoid misleading failures.
exit 0

