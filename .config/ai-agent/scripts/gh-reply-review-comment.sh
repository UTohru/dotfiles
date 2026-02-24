#!/usr/bin/env bash
# PRレビューコメントに返信

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $(basename "$0") <owner> <repository> <pr_number> <comment_id>" >&2
  echo "Reply body will be read from stdin" >&2
  exit 1
fi

OWNER="$1"
REPOSITORY="$2"
PR_NUMBER="$3"
COMMENT_ID="$4"

# stdinからボディを読み取る
BODY=$(cat)

gh api "repos/${OWNER}/${REPOSITORY}/pulls/${PR_NUMBER}/comments/${COMMENT_ID}/replies" \
  --method POST \
  -f body="${BODY}"
