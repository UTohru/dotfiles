#!/usr/bin/env bash
# PRレビューコメントに返信

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $(basename "$0") <owner> <repository> <pr_number> <comment_id>" >&2
  echo "Reply body will be read from stdin" >&2
  exit 1
fi

# stdinからボディを読み取る
BODY=$(cat)

gh api "repos/${1}/${2}/pulls/${3}/comments/${4}/replies" \
  --method POST \
  -f body="${BODY}"
