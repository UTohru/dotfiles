
TerraformとAWSを使用したインフラストラクチャの料金推定を行います。

# 手順

## 0. 前提条件の確認

### 必要なツール
- `terraform`: Terraformがインストールされていること
- `infracost`: コスト推定ツール（推奨）
- `aws-cli`: AWS CLIが設定されていること

### infracostのインストール確認
```bash
# infracostがインストールされているか確認
which infracost

# インストールされていない場合
# Linux/macOS:
# curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
```

### AWS認証情報の確認
```bash
# AWS認証情報が設定されているか確認
aws sts get-caller-identity
```

## 1. Terraformディレクトリの確認

作業対象のTerraformディレクトリに移動するか、パスを確認します。

```bash
# Terraformファイルがあるディレクトリを確認
find . -name "*.tf" -type f | head -10

# または特定のディレクトリに移動
cd <terraform-directory>
```

## 2. Terraformの初期化と検証

```bash
# Terraformの初期化（まだの場合）
terraform init

# フォーマットチェック（オプション）
terraform fmt -check

# 構文検証
terraform validate
```

## 3. Terraform Planの実行

変更内容を確認します。

```bash
# planファイルを生成
terraform plan -out=tfplan.binary

# JSONフォーマットで出力（infracost用）
terraform show -json tfplan.binary > tfplan.json
```

## 4. コスト推定の実行

### 方法A: infracostを使用（推奨）

```bash
# プランファイルからコスト推定
infracost breakdown --path tfplan.json

# より詳細な出力
infracost breakdown --path tfplan.json --format table

# 差分表示（既存インフラとの比較）
infracost diff --path tfplan.json

# HTML形式で出力（レポート用）
infracost breakdown --path tfplan.json --format html > cost-estimate.html

# 複数の環境を比較する場合
infracost breakdown --path tfplan.json --format json > cost-estimate.json
```

### 方法B: MCPツールを使用（利用可能な場合）

MCP（Model Context Protocol）でTerraformやAWSのツールが利用可能な場合：

```
# MCPのTerraformツールを確認
利用可能なMCPツールをリストアップし、Terraform関連のツールを探す

# Terraformリソースの情報を取得
MCPのTerraformツールを使用してリソース情報を取得

# AWSのMCPツールで価格情報を取得
AWSのMCPツールを使用して、各リソースタイプの料金を取得

# 推定コストを計算
取得した情報を基に総コストを計算
```

## 5. 結果の分析

### コスト推定の確認ポイント

1. **月額コスト**: 通常の月間運用コスト
2. **初期コスト**: 一時的な初期費用
3. **リソース別コスト**: どのリソースが最もコストがかかるか
4. **リージョン**: リージョンによる価格差
5. **インスタンスタイプ**: 適切なインスタンスサイズか

### 主要なコスト要素

```bash
# infracostの出力から主要コストを抽出
infracost breakdown --path tfplan.json --format json | jq '.projects[].breakdown.resources[] | select(.monthlyCost != null) | {name: .name, cost: .monthlyCost}' | jq -s 'sort_by(.cost) | reverse'
```

## 6. コスト最適化の提案

料金推定結果を基に、以下の最適化を検討：

1. **リソースサイズの見直し**
   - オーバースペックなインスタンスがないか
   - 使用率の低いリソースの削減

2. **予約インスタンス/Savings Plans**
   - 長期利用が見込まれる場合の割引オプション

3. **リージョンの最適化**
   - より安価なリージョンへの変更可能性

4. **ストレージクラスの最適化**
   - S3のストレージクラス（Standard/IA/Glacier等）
   - EBSのボリュームタイプ

5. **Auto Scaling設定**
   - 需要に応じた自動スケーリング

## 7. レポートの生成（オプション）

```bash
# Markdown形式でレポート生成
infracost breakdown --path tfplan.json --format markdown > cost-report.md

# Slackに通知する場合
# infracost comment github --path cost-estimate.json --repo owner/repo --pull-request 123
```

## 8. クリーンアップ

```bash
# 生成したplanファイルを削除（機密情報が含まれる場合）
rm -f tfplan.binary tfplan.json
```

## 注意事項

1. **料金の精度**
   - infracostの料金は見積もりであり、実際の請求額と異なる場合があります
   - データ転送料金やAPIコールなど、使用量ベースの料金は正確に推定できません
   - 最新の価格情報はAWS公式サイトで確認してください

2. **セキュリティ**
   - planファイルには機密情報が含まれる可能性があります
   - 共有する際は注意してください
   - `.gitignore`に`*.tfplan`, `tfplan.json`を追加することを推奨

3. **API制限**
   - AWS Pricing APIには呼び出し制限があります
   - 大量のリソースがある場合は注意してください

4. **リージョン設定**
   - infracostはTerraformのprovider設定からリージョンを取得します
   - 正しいリージョンが設定されているか確認してください

## トラブルシューティング

### infracostが認識しないリソースがある場合
```bash
# サポートされているリソースを確認
# https://www.infracost.io/docs/supported_resources/aws/

# 未サポートのリソースは手動で見積もりが必要
```

### AWS認証エラーが発生する場合
```bash
# 環境変数を確認
echo $AWS_PROFILE
echo $AWS_REGION

# 認証情報を再設定
aws configure
```

### Terraform初期化エラー
```bash
# バックエンド設定を確認
cat backend.tf

# キャッシュをクリア
rm -rf .terraform
terraform init -reconfigure
```

## 補足: MCPツールとの統合

MCP（Model Context Protocol）サーバーが利用可能な環境では、より高度な分析が可能です：

### Terraform MCPサーバー
- リソース定義の解析
- 依存関係の可視化
- ベストプラクティスのチェック

### AWS MCPサーバー
- リアルタイムの価格情報取得
- リソースタイプ別の詳細料金
- リージョン別価格比較

MCPツールを使用する場合は、各MCPサーバーのドキュメントを参照してください。

## 参考リンク

- [Infracost Documentation](https://www.infracost.io/docs/)
- [AWS Pricing Calculator](https://calculator.aws/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
