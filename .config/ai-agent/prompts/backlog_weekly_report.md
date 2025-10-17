以下の手順でBacklogの週間レポートを作成してください。

(Backlog MCPは使用できません)

# 手順

## 0. backlog のspace名とAPIキーの確認
BacklogのSpace名とAPIキーを取得してください。
ユーザに保管場所を問い合わせてください。

## 1. プロジェクトを選択
projectのリストを取得し、プロジェクト名を提示し、対象とするプロジェクトを選択させてください。

パラメータ
- {APIKey}
- {SpaceName}

```
# プロジェクトの取得
curl -s "https://{SpaceName}/api/v2/projects?apiKey={APIKey} | jq '.[] | {id, projectKey, name}'
```

## 2. 親課題の取得
1週間以内に更新のある親課題を取得します。
- parentChildパラメータ=4で親課題が取得できます。

パラメータ
- {APIKey}
- {SpaceName}
- {ProjectId}
- {date} : 1週間前の日付（ex. 2025-01-01）

```
TMPFILE="/tmp/backlog_parent_issues_$$.json"
echo "(詳細は以下に保存: $TMPFILE)"

curl -s "https://{SpaceName}/api/v2/issues?apiKey=${APIKey}&projectId[]={ProjectId}&parentChild=4&updatedSince={date}&count=100" > "$TMPFILE"

TOTAL_COUNT=$(jq 'length' "$TMPFILE")
echo "取得件数: $TOTAL_COUNT 件"

echo "【ステータス別集計】"
jq -r 'group_by(.status.name) | map({status: .[0].status.name, count: length}) | .[] | "\(.status): \(.count)件"' "$TMPFILE"
```

## 3. 対話的にrepotingを行う
直近の親課題に対して、以下のコマンドを使用しながら対話的にrepotingしてください。


例:
- 親課題のStatusがXXかつpriorityがYYの課題についてまとめて進捗状況を教えてください。
- 親課題のStatusがZZの課題の状況を教えて下さい。

#### **優先度やStatus等で親課題をフィルタリングするコマンド**
パラメータ
- TMPFILE: 更新のあった親課題の詳細ファイル

```
 # 優先度「ABC」かつStasusが「XYZ」以外
jq '.[] | select(.priority.name == "ABC" and .status.name != "XYZ") | {issueKey, summary, status: .status.name, updated: (.updated | split("T")[0])}' $TMPFILE

# 優先度「ABC」のみ（ステータス問わず）
jq '.[] | select(.priority.name == "ABC") | {issueKey, summary, priority: .priority.name, status: .status.name}' $TMPFILE

# 特定のステータスで絞り込み
jq '.[] | select(.status.name == "XXXX" or .status.name == "ZZZZZ") | {issueKey, summary, status: .status.name}' $TMPFILE

# 件数カウント
jq '[.[] | select(.priority.name == "ABC" and .status.name != "KKK")] | length' $TMPFILE
```

#### **課題の集合に関して、各課題の更新状況を取得するコマンド**
(ex. 優先度「ABC」かつStasusが「XYZ」以外の課題の進捗状況を取得)

パラメータ欄を埋めたコマンドをこのまま実行してください
```
## ===== パラメータ（例） =====
BACKLOG_DOMAIN=""
API_KEY=""
PROJECT_ID=""        # 任意。空なら付けません
LIMIT=5              # 表示する子課題数（整数）
# スペース区切りで列挙してください
ISSUE_KEYS="PROJ-123 PROJ-456 PROJ-789"
## ==========================

# 依存コマンド確認
command -v curl >/dev/null 2>&1 || { echo "curl が見つかりません" >&2; exit 1; }
command -v jq   >/dev/null 2>&1 || { echo "jq が見つかりません" >&2; exit 1; }

# 共通：HTTP 取得（200 以外や JSON でなければエラー）
curl_json() {
  url=$1
  # 本文とHTTPコードを分離（改行が本文に含まれても安全に分離できるように最後にだけ http_code を付与）
  resp="$(curl -fsS -w '\n%{http_code}' "$url")" || {
    echo "HTTP接続エラー: $url" >&2; exit 1; }
  http_code=$(printf '%s' "$resp" | awk 'END{print}')
  body=$(printf '%s' "$resp" | sed '$d')
  if [ "$http_code" != "200" ]; then
    echo "HTTP $http_code: $url" >&2
    exit 1
  fi
  # JSON 妥当性チェック
  printf '%s' "$body" | jq -e . >/dev/null 2>&1 || {
    echo "JSONではないレスポンス: $url" >&2; exit 1; }
  # 正常なら本文を出力
  printf '%s' "$body"
}

# PROJECT_ID があればクエリに付与
QP_PROJECT=""
if [ -n "${PROJECT_ID:-}" ]; then
  QP_PROJECT="&projectId[]=$PROJECT_ID"
fi

# ISSUE_KEYS をループ（配列を使わずスペース区切りで）
# キーに空白が含まれる場合は、この方式では不可。Backlog のキーは通常空白なしなので問題ない想定。
set -- $ISSUE_KEYS
if [ "$#" -eq 0 ]; then
  echo "ISSUE_KEYS に有効な課題キーがありません" >&2
  exit 1
fi

for ISSUE_KEY in "$@"; do
  # 一時ファイル（POSIX 互換の mktemp）
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

  # 親IDが無ければスキップ
  if [ "$PARENT_ID" = "null" ] || [ -z "$PARENT_ID" ]; then
    echo "親IDが取得できませんでした。スキップします。"
    echo
    continue
  fi

  echo "子課題を取得中..."
  curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues?apiKey=${API_KEY}${QP_PROJECT}&parentIssueId[]=${PARENT_ID}&count=100" > "$TMPFILE"

  TOTAL_COUNT=$(jq 'length' "$TMPFILE")
  echo "子課題数: $TOTAL_COUNT 件"
  echo

  # 0件なら次へ
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

  # 最近更新順で子課題キーを流す
  # 注意: ここからの while はサブシェルでも問題にならないように外部変数更新はしない
  jq -r "sort_by(.updated) | reverse | .[0:$LIMIT] | .[] | .issueKey" "$TMPFILE" | \
  while IFS= read -r child_key; do
    echo "----------------------"

    # 詳細取得
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
    # 最初の10行まで表示
    printf '%s\n' "$ISSUE_DESCRIPTION" | head -n 10 | sed 's/^/    /'

    # 11行以上あるか判定（POSIX 的に前後空白を削除して整数比較）
    desc_lines=$(printf '%s\n' "$ISSUE_DESCRIPTION" | wc -l | tr -d '[:space:]')
    case "$desc_lines" in
      '' ) desc_lines=0 ;;
    esac
    if [ "$desc_lines" -gt 10 ]; then
      echo "    ..."
    fi
    echo

    # 最新コメント（テキストありのみ）
    COMMENTS="$(curl_json "https://${BACKLOG_DOMAIN}/api/v2/issues/${child_key}/comments?apiKey=${API_KEY}&order=desc&count=10")"
    TEXT_COMMENTS=$(printf '%s' "$COMMENTS" | jq '[.[] | select(.content != null)]')
    COMMENT_COUNT=$(printf '%s' "$TEXT_COMMENTS" | jq 'length')

    if [ "$COMMENT_COUNT" -gt 0 ]; then
      echo "  【最新コメント（最大2件）】"
      printf '%s' "$TEXT_COMMENTS" | jq -r '.[0:2] | .[] | "    [\(.createdUser.name)] \(.created | split(\"T\")[0])\n    \(.content)\n"'
    fi

    # 変更ログ（直近コメント2件のうち changeLog があるもの）
    CHANGELOG=$(printf '%s' "$COMMENTS" | jq '[.[0:2] | .[] | select(.changeLog != null and (.changeLog | length > 0))]')
    if [ "$(printf '%s' "$CHANGELOG" | jq 'length')" -gt 0 ]; then
      echo "  【最近の変更】"
      printf '%s' "$CHANGELOG" | jq -r '.[0:1] | .[] | .changeLog[] | "    - \(.field): \(.originalValue // \"なし\") → \(.newValue)"'
    fi

    echo
  done

  echo "================================"
  echo

  # 一時ファイル削除
  rm -f "$TMPFILE" "$DETAIL_FILE" 2>/dev/null || true
done

echo "全課題の調査完了"
```
