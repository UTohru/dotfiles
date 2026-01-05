#!/usr/bin/env bash
# レビュースレッドをresolvedにマーク

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <thread_id>" >&2
  exit 1
fi

THREAD_ID="$1"

gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "'"${THREAD_ID}"'"}) {
    thread {
      isResolved
    }
  }
}'
