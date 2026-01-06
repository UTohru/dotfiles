#!/usr/bin/env bash
# レビュースレッドをresolvedにマーク

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <thread_id>" >&2
  exit 1
fi

THREAD_ID="$1"

gh api graphql \
  -f thread_id="${THREAD_ID}" \
  --field query='
mutation($thread_id: ID!) {
  resolveReviewThread(input: {threadId: $thread_id}) {
    thread {
      isResolved
    }
  }
}'
