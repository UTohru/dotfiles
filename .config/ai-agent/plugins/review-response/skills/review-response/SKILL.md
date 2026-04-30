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
<Owner>オーナー名</Owner>
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

判断の前に、各指摘について **現状** と **指摘どおり変更した場合の差分** を、対象コードを実際に読んで具体的に記述する。以降の判断はこの記述から従属的に決める。コメント本文のみを根拠に判断ラベルを出すことは禁止する。

### 3-1. 現状の記述
対象ファイル（必要なら呼び出し元・参照先・関連設定）を実際に読み、何が起きているかを具体的に書く（コメント文の言い換えにとどめない）。

### 3-2. 変更後の記述
- suggest change がある場合はそれを当てた状態、ない場合は「指摘どおりに直す」と仮定した状態を、3-1 と同じ粒度で書く（何がどう変わるか）
- 指摘箇所だけでなく、波及する箇所（呼び出し先・呼び出し元・型・設定など）の変化も含める
- 解決策の性質（症状への対処か根本対処か、パッチか構造変更か、追加か置換か等）が読み取れるよう書く

### 3-3. 判断
3-1, 3-2 の記述を根拠に以下を導く。記述だけで判断が出ないなら、調査や代替案の検討に戻る。

- **指摘の妥当性**: 指摘されている問題が実在するか・前提が正しいか
- **解決策の妥当性**: 提案が **適切な解決策** か。「動く・副作用がない」だけでなく、採るレイヤーが正しいか、累積的に負債を生まないか、別アプローチ（別レイヤー、設計変更）が妥当でないかを含めて判断する。指摘の妥当性とは**独立に**判定する。**不適切と判断した場合は、本来どう解決すべきかを併せて特定する**（「不適切」だけで止めて結論にしない）
- **対応の方針**: 指摘が妥当である限り、「対応する/しない」の二択ではなく「どう対応するか」を出す。本PRで実装 / 別PR・別Issue で追跡 / 別レイヤー（別コンポーネント・他チーム）へ申し送り など、必ず追跡方法を伴う方針を出す。「別レイヤーへ申し送り」を選ぶ前に、同一PR内・別レイヤーで解決できないかを先に検討する（解決できるならそれは「本PRで実装」であって「申し送り」ではない）。「責務違い」「スコープ外」は本PRで touch しない理由にはなり得るが、**指摘自体を消す理由にはならない**。「対応不要」を選べるのは指摘自体が不正確と判定された場合のみで、その場合は 3-1 で「指摘が前提とする状態が成立していない」ことが具体的に示されている必要がある

### 3-4. 対応の実施
3-3 から方針が明確に決まったら、必要に応じて修正して commit, push し、返答案をドラフトする。本PRで touch しない方針なら、追跡先を含む返答案をドラフトする。

**原則として、ユーザに選択肢を立てて投げるのは例外**。問題を正しく理解できていれば、ほとんどの場合は妥当な答えが一つに収束する。「A か B か決めかねる」と感じたら、選択肢を立てる前にまず以下を疑う:

- 指摘の真の意図を取り違えていないか
- コードの実際の挙動・前提を見落としていないか
- 関連する制約・依存・既存の方針を確認できているか

検討を尽くしてもなお trade-off が割れる**真の選択ケース**でのみ、修正を保留して案A・案B…と帰結を具体形で出して手順4で提示する。「どうしましょう」と漠然と投げるのは禁止する。

## 4. 返答案・選択肢をまとめてユーザに確認する

手順3で用意した内容を、対応する `First Comment ID` / 対象ファイル位置と共に**まとめて一度だけ**ユーザに提示し、投稿可否・修正希望・選択（該当時）を確認する。ユーザからの承認を得るまでは `reply-review-comment.sh` を実行してはならない。

返答案がユーザとの会話で使用している言語と異なる場合は、ユーザ確認時は会話言語への訳を併記する（投稿時は原文のみ）。

提示フォーマット（方針が明確なケース）：
```
[連番] <File:Line>
コメント:
  [<reviewer>] <元のレビューコメント本文>
現状:
  <具体的に記述>
変更後（採用案を当てた場合）:
  <具体的に記述>
判断:
  指摘: <妥当 / 不正確 / 部分的> — <根拠>
  解決策: <妥当 / 不適切（本来は <代替案>）/ 提案なし> — <根拠>
  対応の方針: <本PRで実装 / 別PR・別Issueで追跡（追跡先: <参照>）/ 別レイヤーへ申し送り / 対応不要（指摘が不正確のため）> — <根拠>
対応:
  <実施した変更の概要、または「本PRでは変更なし」+ 追跡方法>
返答案:
  <返答文>
```

提示フォーマット（選択を仰ぐケース）：
```
[連番] <File:Line>
コメント:
  [<reviewer>] <元のレビューコメント本文>
現状:
  <具体的に記述>
選択肢:
  A. <案Aの内容（場所・方法・コスト・帰結）>
  B. <案Bの内容（場所・方法・コスト・帰結）>
  （他あれば追加）
判断材料:
  <選択を分けている事実（スコープ整合・他作業との関係・累積負債など）>
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
