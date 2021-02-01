#!/bin/bash

newbranch=$(date +"%Y-%m-%d")-update-changelog

# Clean
git branch -D $newbranch || true
git branch -D $origin/$newbranch || true

# Create new branch
git checkout -b $newbranch

# Update the new branch
git add "CHANGELOG.md"
git commit -m "chore(changelog): Update Changelog"

# Push it to remote
git push $origin $newbranch

# Create a pull request
gh pr create --title "chore(changelog): Update Changelog" --body "Update changelog with last data"
