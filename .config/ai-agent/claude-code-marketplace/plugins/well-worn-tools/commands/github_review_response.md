
以下の手順でgithubのPRに対するレビューを読んで、対応を行ってください。

# 手順

## 0. githubのオーナやリポジトリを確認する。
`git remote -v`

以降では、リポジトリ名等は以下のタグ表記を使用する。

<Repository>リポジトリ名</Repository>
<Owner>リポジトリ名</Owner>
<PR_Number>PRの番号</PR_Number>

## 1. 現在のブランチのPRの番号を確認する。
`gh pr status --json number,title,headRefName`

ブランチが見つからない場合は確認が必要です。

## 2. スクリプトで未解決のレビューを取得する。
```bash
${CLAUDE_PLUGIN_ROOT}/scripts/gh-list-unresolved-reviews.sh <Owner> <Repository> <PR_Number>
```

出力例：
```
---
File: path/to/file.sh:45
Thread ID: PRRT_kwDOHZmkFc5n_6u4
Status: Unresolved, Outdated=false
First Comment ID: 2660705204
Thread (1 comments):
  [reviewer] レビューコメント
```

## 3. 手順2の出力の各指摘に対して下記の手順を繰り返す

1. コメント（指摘）の正当性を確認する。
2. 指摘が正しい場合は、改善し、commit, pushする。
3. コメントIDに対して、返答を追加する。

### 返答
```bash
# 上記で確認したFirst Comment IDを使用
echo '[修正内容・対応理由の説明]' | ${CLAUDE_PLUGIN_ROOT}/scripts/gh-reply-review-comment.sh <Owner> <Repository> <PR_Number> ${COMMENT_ID}
```

修正したコミットハッシュを書くと親切です。

### resolvedにマーク（必用な場合のみ）
```bash
# 上記で確認したThread IDを使用
${CLAUDE_PLUGIN_ROOT}/scripts/gh-resolve-review-thread.sh ${THREAD_ID}
```

## 注意事項

1. 取得制限
   - Review取得のスクリプトは未解決のレビュースレッドを最新20件まで取得
   - 各スレッドのコメントは最大10件まで取得

2. 認証
   - `gh`コマンドが自動的に認証情報を使用
   - プライベートリポジトリ等のアクセス権限が必要
