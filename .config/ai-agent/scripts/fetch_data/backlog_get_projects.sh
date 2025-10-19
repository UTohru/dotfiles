#!/bin/bash
# Backlogのプロジェクト一覧を取得する

set -euo pipefail

# 使用方法
usage() {
  cat <<EOF
Usage: $0 <SPACE_NAME> <API_KEY>

Arguments:
  SPACE_NAME  Backlog のスペース名（例: myspace.backlog.jp）
  API_KEY     Backlog の API キー

Example:
  $0 myspace.backlog.jp XXXXXXXXXXXXXXXX
EOF
  exit 1
}

# 引数チェック
if [ $# -ne 2 ]; then
  usage
fi

SPACE_NAME="$1"
API_KEY="$2"

# プロジェクトの取得
curl -s "https://${SPACE_NAME}/api/v2/projects?apiKey=${API_KEY}" | jq '.[] | {id, projectKey, name}'
