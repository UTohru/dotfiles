#!/bin/bash
# 指定された課題キーの詳細情報と子課題の進捗状況を取得する

set -euo pipefail

# 使用方法
usage() {
  cat <<EOF
Usage: $0 <BACKLOG_DOMAIN> <API_KEY> <PROJECT_ID> <LIMIT> <ISSUE_KEYS...>

Arguments:
  BACKLOG_DOMAIN  Backlog ドメイン（例: myspace.backlog.jp）
  API_KEY         Backlog の API キー
  PROJECT_ID      プロジェクト ID
  LIMIT           表示する子課題数
  ISSUE_KEYS      課題キー（スペース区切りで複数指定可）

Example:
  $0 myspace.backlog.jp XXXXXXXXXXXXXXXX 12345 5 PROJ-123 PROJ-456
EOF
  exit 1
}

# 引数チェック
if [ $# -lt 5 ]; then
  usage
fi

BACKLOG_DOMAIN="$1"
API_KEY="$2"
PROJECT_ID="$3"
LIMIT="$4"
shift 4
ISSUE_KEYS="$@"

# 依存コマンド確認
command -v curl >/dev/null 2>&1 || { echo "curl が見つかりません" >&2; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "jq が見つかりません" >&2; exit 1; }

# 共通：HTTP 取得（200 以外や JSON でなければエラー）
curl_json() {
  url=$1
  resp="$(curl -fsS -w '\n%{http_code}' "$url")" || {
    echo "HTTP接続エラー: $url" >&2; exit 1; }
  http_code=$(printf '%s' "$resp" | awk 'END{print}')
  body=$(printf '%s' "$resp" | sed '$d')
  if [ "$http_code" != "200" ]; then
    echo "HTTP $http_code: $url" >&2
    exit 1
  fi
  printf '%s' "$body" | jq -e . >/dev/null 2>&1 || {
    echo "JSONではないレスポンス: $url" >&2; exit 1; }
  printf '%s' "$body"
}

# ISSUE_KEYS をループ
for ISSUE_KEY in $ISSUE_KEYS; do
  TMPFILE="${TMPDIR:-/tmp}/backlog_children_$(date +%s)_$$.json"
  DETAIL_FILE="${TMPDIR:-/tmp}/backlog_detail_$(date +%s)_$$.json"

  echo "========================================"
  echo "PBI情報を取得中: $ISSUE_KEY"
  echo "========================================"

  PBI_INFO="$(curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues/${ISSUE_KEY}?apiKey=${API_KEY}")"
  PARENT_ID=$(printf '%s' "$PBI_INFO" | jq -r '.id')
  SUMMARY=$(printf '%s' "$PBI_INFO" | jq -r '.summary')
  PBI_STATUS=$(printf '%s' "$PBI_INFO" | jq -r '.status.name')

  echo "【$ISSUE_KEY】"
  echo "$SUMMARY"
  echo "PBIステータス: $PBI_STATUS"
  echo

  if [ "$PARENT_ID" = "null" ] || [ -z "$PARENT_ID" ]; then
    echo "親IDが取得できませんでした。スキップします。"
    echo
    continue
  fi

  echo "子課題を取得中..."
  curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues?apiKey=${API_KEY}&projectId[]=${PROJECT_ID}&parentIssueId[]=${PARENT_ID}&count=100" > "$TMPFILE"

  TOTAL_COUNT=$(jq 'length' "$TMPFILE")
  echo "子課題数: $TOTAL_COUNT 件"
  echo

  if [ "$TOTAL_COUNT" -eq 0 ]; then
    echo "子課題が存在しません。"
    echo
    rm -f "$TMPFILE" "$DETAIL_FILE" 2>/dev/null || true
    continue
  fi

  echo "================================"
  echo "【最近更新された課題 Top $LIMIT】"
  echo "================================"
  echo

  jq -r "sort_by(.updated) | reverse | .[0:$LIMIT] | .[] | .issueKey" "$TMPFILE" | \
  while IFS= read -r child_key; do
    echo "----------------------"

    curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues/${child_key}?apiKey=${API_KEY}" > "$DETAIL_FILE"

    ISSUE_SUMMARY=$(jq -r '.summary' "$DETAIL_FILE")
    ISSUE_STATUS=$(jq -r '.status.name' "$DETAIL_FILE")
    ISSUE_ASSIGNEE=$(jq -r '.assignee.name // "未設定"' "$DETAIL_FILE")
    ISSUE_UPDATED=$(jq -r '.updated | split("T")[0]' "$DETAIL_FILE")
    ISSUE_DESCRIPTION=$(jq -r '.description // "(説明なし)"' "$DETAIL_FILE")

    echo "* [$child_key] $ISSUE_SUMMARY"
    echo "  ステータス: $ISSUE_STATUS"
    echo "  担当者: $ISSUE_ASSIGNEE"
    echo "  更新日: $ISSUE_UPDATED"
    echo
    echo "  【説明】"
    printf '%s\n' "$ISSUE_DESCRIPTION" | head -n 10 | sed 's/^/    /'

    desc_lines=$(printf '%s\n' "$ISSUE_DESCRIPTION" | wc -l | tr -d '[:space:]')
    if [ "${desc_lines:-0}" -gt 10 ]; then
      echo "    ..."
    fi
    echo

    # 最新コメント
    COMMENTS="$(curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues/${child_key}/comments?apiKey=${API_KEY}&order=desc&count=10")"
    TEXT_COMMENTS=$(printf '%s' "$COMMENTS" | jq '[.[] | select(.content != null)]')
    COMMENT_COUNT=$(printf '%s' "$TEXT_COMMENTS" | jq 'length')

    if [ "$COMMENT_COUNT" -gt 0 ]; then
      echo "  【最新コメント（最大2件）】"
      printf '%s' "$TEXT_COMMENTS" | jq -r '.[0:2] | .[] | "    [\(.createdUser.name)] \(.created | split(\"T\")[0])\n    \(.content)\n"'
    fi

    # 変更ログ
    CHANGELOG=$(printf '%s' "$COMMENTS" | jq '[.[0:2] | .[] | select(.changeLog != null and (.changeLog | length > 0))]')
    if [ "$(printf '%s' "$CHANGELOG" | jq 'length')" -gt 0 ]; then
      echo "  【最近の変更】"
      printf '%s' "$CHANGELOG" | jq -r '.[0:1] | .[] | .changeLog[] | "    - \(.field): \(.originalValue // "なし") -> \(.newValue)"'
    fi

    echo
  done

  echo "================================"
  echo

  rm -f "$TMPFILE" "$DETAIL_FILE" 2>/dev/null || true
done

echo "全課題の調査完了"
