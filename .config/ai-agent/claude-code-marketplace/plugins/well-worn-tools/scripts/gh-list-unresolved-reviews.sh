#!/usr/bin/env bash
# 未解決のPRレビューコメントを取得

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $(basename "$0") <owner> <repository> <pr_number>" >&2
  exit 1
fi

OWNER="$1"
REPOSITORY="$2"
PR_NUMBER="$3"

gh api graphql \
  -f owner="${OWNER}" \
  -f repository="${REPOSITORY}" \
  -F pr_number="${PR_NUMBER}" \
  --field query='
query($owner: String!, $repository: String!, $pr_number: Int!) {
  repository(owner: $owner, name: $repository) {
    pullRequest(number: $pr_number) {
      url
      title
      reviewThreads(first: 10) {
        edges {
          node {
            id
            isResolved
            isOutdated
            path
            line
            comments(first: 10) {
              totalCount
              nodes {
                id
                databaseId
                author { login }
                body
                url
                createdAt
              }
            }
          }
        }
      }
    }
  }
}' | jq -r '.data.repository.pullRequest.reviewThreads.edges[] | select(.node.isResolved == false) |
"---
File: \(.node.path):\(.node.line)
Thread ID: \(.node.id)
Status: Unresolved, Outdated=\(.node.isOutdated)
First Comment ID: \(.node.comments.nodes[0].databaseId)
Thread (\(.node.comments.totalCount) comments):
" + (.node.comments.nodes | map("  [\(.author.login)] \(.body | split("\n")[0])") | join("\n")) + "\n"'
