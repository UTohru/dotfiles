
以下の手順でgithubのPRに対するレビューを読んで、対応を行ってください。

# 手順

## 0. githubのオーナやリポジトリを確認する。
`git remote -v`

以下では、リポジトリ名等は以下のタグ表記を使用する。

<Repository>リポジトリ名</Repository>
<Owner>リポジトリ名</Owner>
<PR_Number>PRの番号</PR_Number>

## 1. PRの番号を確認する。
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
Thread ID: PRRT_kwDOHZmjFc5n_6u4
Status: Unresolved, Outdated=false
First Comment ID: 2660715204
Thread (1 comments):
  [reviewer] コメント内容
```

## 3. 各指摘に対して下記の手順を繰り返す

1. 指摘内用の正答性を確認する。
2. 指摘が正しい場合は、改善し、commit, pushする。
3. コメントIDに対して、返答を追加する。

### 返答
```bash
# 上記で確認したFirst Comment IDを使用
echo '[修正内容・対応理由の説明]' | ${CLAUDE_PLUGIN_ROOT}/scripts/gh-reply-review-comment.sh <Owner> <Repository> <PR_Number> ${COMMENT_ID}
```

### resolvedにマーク（必用な場合のみ）
```bash
# 上記で確認したThread IDを使用
${CLAUDE_PLUGIN_ROOT}/scripts/gh-resolve-review-thread.sh ${THREAD_ID}
```





## 注意事項

1. GraphQL APIの制限
   - 1時間あたり5,000ノードまで
   - 一度に取得できるスレッド数は最大100件（`first: 100`）

2. REST APIとの違い
   - REST APIには`resolved`フィールドが存在しない
   - GraphQL APIでのみ未解決状態を直接確認可能

3. 認証
   - `gh`コマンドが自動的に認証情報を使用
   - プライベートリポジトリへのアクセス権限が必要

## 補足

### GraphQLクエリの構造
```
query FetchReviewComments($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {          # リポジトリを指定
    pullRequest(number: $pr) {                       # PR番号で特定のPRを取得
      url                                             # PRのURL
      title                                           # PRのタイトル
      reviewDecision                                  # レビューの決定状態
      reviewThreads(first: 100) {                    # レビュースレッド（最大100件）
        edges {
          node {
            isResolved                                # 解決済みかどうか（重要）
            isOutdated                                # 古いコードに対するコメントか
            isCollapsed                               # 折りたたまれているか
            path                                      # ファイルパス
            line                                      # 行番号
            comments(first: 100) {                   # スレッド内のコメント
              totalCount
              nodes {
                author { login }                      # コメント作者
                body                                  # コメント本文
                url                                   # コメントへのリンク
                createdAt                             # 作成日時
              }
            }
          }
        }
      }
    }
  }
}
```

### jqフィルタの説明
1. `.data.repository.pullRequest.reviewThreads.edges[]`: 全てのレビュースレッドを取得
2. `select(.node.isResolved == false)`: `isResolved`がfalseのものだけを選択
3. 整形版では、結果を見やすい構造に変換

### 取得できる情報

- **isResolved**: コメントスレッドが解決済みかどうか（false = 未解決）
- **isOutdated**: コードの変更により古くなったコメントか
- **path**: コメントがあるファイルのパス
- **line**: コメントがある行番号
- **author.login**: コメントした人のGitHubユーザー名
- **body**: コメントの内容
- **url**: GitHubでコメントを直接見るためのURL
