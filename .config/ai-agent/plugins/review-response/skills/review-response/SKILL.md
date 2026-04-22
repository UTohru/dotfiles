---
name: review-response
description: GitHub PRのレビューコメントへの対応を行う
allowed-tools:
  - Bash(git remote:*)
  - Bash(gh pr status:*)
  - Bash(~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/list-unresolved-reviews.sh:*)
  - Bash(echo:*)
  - Bash(~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/reply-review-comment.sh:*)
  - Bash(~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/resolve-review-thread.sh:*)
  - Bash(git commit:*)
  - Bash(git push:*)
---

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
~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/list-unresolved-reviews.sh <Owner> <Repository> <PR_Number>
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

## 3. 手順2の出力の各指摘について、対応と返答案を準備する

各指摘に対して以下を行う（この段階ではまだ返答を投稿しない）。

1. コメント（指摘）の正当性を確認する。
2. 指摘が正しい場合は、改善し、commit, pushする。
3. 各コメントIDに対する返答案（文面）をドラフトする。

## 4. 返答案をまとめてユーザに確認する

手順3でドラフトした返答案を、対応する `First Comment ID` / 対象ファイル位置と共に**まとめて一度だけ**ユーザに提示し、投稿可否・修正希望を確認する。ユーザからの承認を得るまでは `reply-review-comment.sh` を実行してはならない。

返答案がユーザとの会話で使用している言語と異なる場合は、ユーザ確認時は会話言語への訳を併記する（投稿時は原文のみ）。

提示フォーマット：
```
[連番]
コメント:
  [<reviewer>] <元のレビューコメント本文>
返答案:
  <返答文>
```

## 5. 承認後に返答を投稿し、必要ならresolveする

### 返答
投稿する返答文には、対応するcommitハッシュを添えると親切（ユーザ確認用の提示には含めない）。

```bash
# 上記で確認したFirst Comment IDを使用
echo '[確認済みの返答文（必要に応じてcommitハッシュを付与）]' | ~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/reply-review-comment.sh <Owner> <Repository> <PR_Number> ${COMMENT_ID}
```

### resolvedにマーク（必用な場合のみ）
```bash
# 上記で確認したThread IDを使用
~/.config/ai-agent/plugins/review-response/skills/review-response/scripts/resolve-review-thread.sh ${THREAD_ID}
```

## 注意事項

1. 取得制限
   - Review取得のスクリプトは未解決のレビュースレッドを最新20件まで取得
   - 各スレッドのコメントは最大10件まで取得

2. 認証
   - `gh`コマンドが自動的に認証情報を使用
   - プライベートリポジトリ等のアクセス権限が必要
