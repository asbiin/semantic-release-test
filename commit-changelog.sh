#!/bin/bash

repo=asbiin/semantic-release-test
base=master

newbranch=$(date +"%Y-%m-%d")-update-changelog

content=$(base64 -w 0 CHANGELOG.md)

# Test if branch already exists
test=$(curl -fsSL \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$repo/git/ref/heads/$newbranch 2> /dev/null)

if [ $? = 0 ]; then
  # Delete previous branch
  curl -sSL \
    -X DELETE \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$repo/git/refs/heads/$newbranch > /dev/null
fi

# Create a new branch
curl -sSL \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$repo/git/refs \
  -d "{\"ref\":\"refs/heads/$newbranch\",\"sha\":\"$GITHUB_SHA\"}" > /dev/null

# Get changelog sha
sha=$(curl -sSL \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$repo/contents/CHANGELOG.md \
  | jq '.sha')

# Upload file content
curl -sSL \
  -X PUT \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$repo/contents/CHANGELOG.md \
  -d "{\"message\":\"chore(changelog): Update Changelog\",\"sha\":$sha,\"branch\":\"$newbranch\",\"content\":\"$content\"}" > /dev/null

# Create a pull request
curl \
  -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$repo/pulls \
  -d "{\"head\":\"$newbranch\",\"base\":\"$base\",\"title\":\"chore(changelog): Update Changelog\"}" > /dev/null
