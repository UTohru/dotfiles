Backlogの週間レポートの作成

(Backlog MCPは使用できません)

# 手順

## 0. backlog のspace名とAPIキーの確認
BacklogのSpace名とAPIキーを取得してください。
ユーザに保管場所もしくは値を問い合わせてください。

## 1. プロジェクトを選択
閲覧可能なprojectのリストを取得し、プロジェクト名を提示し、対象とするプロジェクトを選択させてください。

```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_projects.sh <BACKLOG_DOMAIN> <API_KEY>
```

例：
```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_projects.sh myspace.backlog.jp YOUR_API_KEY
```

## 2. 親課題の取得
1週間以内に更新のある親課題を取得します。

```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_parent_issues.sh <BACKLOG_DOMAIN> <API_KEY> <PROJECT_ID> <DATE>
```

- DATE: 1週間前の日付（YYYY-MM-DD形式、例: 2025-01-15）
- 結果は `/tmp/backlog_parent_issues_<PID>.json` に保存されます

例：
```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_parent_issues.sh myspace.backlog.jp YOUR_API_KEY 12345 2025-01-15
```

## 3. 対話的にreportingを行う
直近の親課題に対して、以下のコマンドを使用しながら対話的にreportingしてください。

例:
- 親課題のStatusがXXかつpriorityがYYの課題についてまとめて進捗状況を教えてください。
- 親課題のStatusがZZの課題の状況を教えて下さい。

### 3.1 優先度やStatus等で親課題をフィルタリング

手順2で取得した `/tmp/backlog_parent_issues_<PID>.json` をjqでフィルタリングして、対象の課題を絞り込みます。

```bash
TMPFILE="/tmp/backlog_parent_issues_<PID>.json"

# 優先度「ABC」かつステータスが「XYZ」以外
jq '.[] | select(.priority.name == "ABC" and .status.name != "XYZ") | {issueKey, summary, status: .status.name, updated: (.updated | split("T")[0])}' $TMPFILE

# 優先度「ABC」のみ（ステータス問わず）
jq '.[] | select(.priority.name == "ABC") | {issueKey, summary, priority: .priority.name, status: .status.name}' $TMPFILE

# 特定のステータスで絞り込み
jq '.[] | select(.status.name == "XXXX" or .status.name == "YYYY") | {issueKey, summary, status: .status.name}' $TMPFILE

# 件数カウント
jq '[.[] | select(.priority.name == "ABC" and .status.name != "XYZ")] | length' $TMPFILE

# 課題キーのみ抽出（スペース区切り）
jq -r '.[] | select(.status.name == "XXXX") | .issueKey' $TMPFILE | tr '\n' ' '
```

### 3.2 課題の詳細情報を取得

フィルタリングした課題キーを使って、詳細情報を取得します。

```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_issue_details.sh <BACKLOG_DOMAIN> <API_KEY> <PROJECT_ID> <LIMIT> <ISSUE_KEY1> <ISSUE_KEY2> ...
```

- LIMIT: 各親課題につき表示する子課題の数（最近更新順）

例:
```bash
~/.config/ai-agent/scripts/fetch_data/backlog_get_issue_details.sh myspace.backlog.jp YOUR_API_KEY 12345 5 PROJ-123 PROJ-456
```
