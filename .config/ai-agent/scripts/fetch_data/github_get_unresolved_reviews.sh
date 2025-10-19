#!/bin/bash
# GitHubのPRに対する未解決のレビューを取得する

set -euo pipefail

# 使用方法
usage() {
  cat <<EOF
Usage: $0 <OWNER> <REPOSITORY> <PR_NUMBER>

Arguments:
  OWNER        GitHub リポジトリのオーナー名
  REPOSITORY   リポジトリ名
  PR_NUMBER    PR番号

Example:
  $0 myorg myrepo 123

Note:
  - gh コマンドが必要です
  - GitHub認証が設定されている必要があります
EOF
  exit 1
}

# 引数チェック
if [ $# -ne 3 ]; then
  usage
fi

OWNER="$1"
REPOSITORY="$2"
PR_NUMBER="$3"

# gh コマンド確認
command -v gh >/dev/null 2>&1 || { echo "gh コマンドが見つかりません" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq が見つかりません" >&2; exit 1; }

# GraphQL APIで未解決のレビューを取得
gh api graphql --field query='
{
  repository(owner: "'"$OWNER"'", name: "'"$REPOSITORY"'") {
    pullRequest(number: '"$PR_NUMBER"') {
      url
      title
      reviewThreads(first: 100) {
        edges {
          node {
            id
            isResolved
            isOutdated
            path
            line
            comments(first: 100) {
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
