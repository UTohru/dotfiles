#!/bin/bash
# 指定期間内に更新のある親課題を取得する

set -euo pipefail

# 使用方法
usage() {
  cat <<EOF
Usage: $0 <BACKLOG_DOMAIN> <API_KEY> <PROJECT_ID> <DATE>

Arguments:
  BACKLOG_DOMAIN  Backlog のドメイン（例: myspace.backlog.jp）
  API_KEY         Backlog の API キー
  PROJECT_ID      プロジェクト ID
  DATE            開始日（YYYY-MM-DD形式、例: 2025-01-01）

Example:
  $0 myspace.backlog.jp XXXXXXXXXXXXXXXX 12345 2025-01-01

Output:
  /tmp/backlog_parent_issues_<PID>.json に詳細を保存し、パスを出力
EOF
  exit 1
}

# 引数チェック
if [ $# -ne 4 ]; then
  usage
fi

BACKLOG_DOMAIN="$1"
API_KEY="$2"
PROJECT_ID="$3"
DATE="$4"

TMPFILE="/tmp/backlog_parent_issues_$$.json"

# 親課題を取得（parentChild=4）
curl -s "https://${BACKLOG_DOMAIN}/api/v2/issues?apiKey=${API_KEY}&projectId[]=${PROJECT_ID}&parentChild=4&updatedSince=${DATE}&count=100" > "$TMPFILE"

TOTAL_COUNT=$(jq 'length' "$TMPFILE")

echo "取得件数: $TOTAL_COUNT 件"
echo "詳細ファイル: $TMPFILE"
echo ""
echo "【ステータス別集計】"
jq -r 'group_by(.status.name) | map({status: .[0].status.name, count: length}) | .[] | "\(.status): \(.count)件"' "$TMPFILE"
