
TerraformファイルとAWS MCPを使用したインフラストラクチャの料金推定を行います。
このコマンドはTerraformのランタイムに依存せず、MCPツールのみを使用します。

# 手順

## 0. 前提条件の確認

### 必要なMCPサーバー
- **Terraform MCP**: Terraformファイルの解析用
- **AWS MCP**: AWS価格情報の取得用

### MCP接続の確認
MCPツールが利用可能か確認します。利用可能なMCPツールをリストアップしてください。

## 1. Terraformディレクトリの確認

Terraformファイルがあるディレクトリを特定します。

```bash
# Terraformファイルを検索
find . -name "*.tf" -type f

# ディレクトリ構造を確認
tree -L 2 -I 'node_modules|.terraform'
```

## 2. Terraformファイルの解析

### 2.1 Terraformファイルの読み込み

プロジェクトのすべての `.tf` ファイルを読み込みます：
- `main.tf` - メインのリソース定義
- `variables.tf` - 変数定義
- `terraform.tfvars` - 変数の値
- その他の `.tf` ファイル

### 2.2 リソースの抽出

Terraformファイルから以下の情報を抽出します：

1. **リソースタイプ**
   - `aws_instance`
   - `aws_rds_instance`
   - `aws_s3_bucket`
   - `aws_lb`
   - `aws_ebs_volume`
   - など

2. **リソース設定**
   - インスタンスタイプ（例: `t3.medium`）
   - リージョン（provider設定から）
   - ストレージサイズ
   - その他の課金対象パラメータ

3. **数量情報**
   - `count` パラメータ
   - `for_each` による複数リソース
   - Auto Scaling の min/max 設定

### 2.3 抽出結果の整理

リソース情報を以下の形式で整理します：

```json
{
  "region": "ap-northeast-1",
  "resources": [
    {
      "type": "aws_instance",
      "name": "web_server",
      "count": 2,
      "attributes": {
        "instance_type": "t3.medium",
        "ebs_block_device": {
          "volume_size": 30,
          "volume_type": "gp3"
        }
      }
    },
    {
      "type": "aws_rds_instance",
      "name": "database",
      "count": 1,
      "attributes": {
        "instance_class": "db.t3.small",
        "allocated_storage": 100,
        "engine": "postgres"
      }
    }
  ]
}
```

## 3. AWS料金情報の取得

### 3.1 AWS MCPを使用した価格取得

抽出した各リソースに対して、AWS MCPを使用して料金情報を取得します。

#### EC2インスタンスの料金
```
リージョン: ap-northeast-1
インスタンスタイプ: t3.medium
OS: Linux
価格モデル: オンデマンド
→ 時間単価を取得
```

#### RDSインスタンスの料金
```
リージョン: ap-northeast-1
インスタンスクラス: db.t3.small
エンジン: postgres
→ 時間単価を取得
```

#### EBSボリュームの料金
```
リージョン: ap-northeast-1
ボリュームタイプ: gp3
サイズ: 30GB
→ GB/月単価を取得
```

#### S3ストレージの料金
```
リージョン: ap-northeast-1
ストレージクラス: Standard
→ GB/月単価を取得
```

#### ロードバランサーの料金
```
リージョン: ap-northeast-1
タイプ: Application Load Balancer
→ 時間単価を取得
```

### 3.2 データ転送料金の考慮

データ転送は使用量ベースのため、以下を注意点として記載：
- インターネットへの転送（GB単位）
- リージョン間転送
- AZ間転送

## 4. 料金計算

### 4.1 月額料金の計算

取得した価格情報を基に月額料金を計算します：

```
EC2インスタンス料金 = 時間単価 × 24時間 × 30日 × インスタンス数
EBSボリューム料金 = GB単価 × サイズ × インスタンス数
RDS料金 = 時間単価 × 24時間 × 30日
RDSストレージ料金 = GB単価 × サイズ
ALB料金 = 時間単価 × 24時間 × 30日
```

### 4.2 総コストの集計

```
月額総コスト = Σ(各リソースの月額料金)
年額推定コスト = 月額総コスト × 12
```

### 4.3 結果の出力

料金推定結果を以下の形式で出力：

```markdown
# AWS料金推定結果

## サマリー
- **月額総コスト**: $XXX.XX USD
- **年額推定コスト**: $X,XXX.XX USD
- **リージョン**: ap-northeast-1

## リソース別内訳

### EC2インスタンス
- タイプ: t3.medium × 2台
- 月額: $XX.XX USD
- 内訳: $X.XX/時間 × 24h × 30日 × 2台

### EBSボリューム
- タイプ: gp3 30GB × 2台
- 月額: $X.XX USD
- 内訳: $X.XX/GB × 30GB × 2台

### RDSインスタンス
- クラス: db.t3.small
- 月額: $XX.XX USD
- ストレージ (100GB): $X.XX USD

### Application Load Balancer
- 月額: $XX.XX USD

## 注意事項
- データ転送料金は含まれていません（使用量により変動）
- 実際の請求額は使用時間・使用量により変動します
- Reserved InstanceやSavings Plansによる割引は考慮されていません
```

## 5. コスト最適化の提案

料金推定結果を基に、以下の最適化を提案します：

### 5.1 リソースサイズの見直し
- オーバースペックなインスタンスタイプがないか
- 使用率に応じた適切なサイズへの変更提案

### 5.2 予約購入オプション
長期利用が見込まれる場合：
- Reserved Instances（1年/3年）: 最大72%割引
- Savings Plans: 柔軟な割引オプション

### 5.3 ストレージ最適化
- S3ライフサイクルポリシーの活用
  - Standard → Standard-IA → Glacier
- EBSボリュームタイプの見直し
  - gp3はgp2より20%安価で高性能

### 5.4 リージョン最適化
より安価なリージョンへの変更可能性：
- us-east-1（バージニア北部）が最も安価
- アジアパシフィックはやや高価

### 5.5 アーキテクチャの見直し
- スポットインスタンスの活用（最大90%割引）
- Auto Scalingによる使用量の最適化
- Lambdaへの移行可能性
- Fargateの検討（ECS/EKS）

## 6. 追加分析（オプション）

### 6.1 リソース依存関係の可視化
Terraform MCPを使用して：
- リソース間の依存関係を分析
- コストドライバーとなるリソースの特定

### 6.2 複数シナリオの比較
異なる構成での料金比較：
- 本番環境 vs 開発環境
- 現在の構成 vs 最適化後の構成
- リージョンAとリージョンBの比較

### 6.3 タグ別コスト分析
タグが設定されている場合：
- 環境別（production/staging/development）
- チーム別
- プロジェクト別

## 7. レポートの生成

### 7.1 Markdown形式

上記の推定結果をMarkdownファイルとして保存：
```
cost-estimate-YYYY-MM-DD.md
```

### 7.2 JSON形式（プログラム処理用）

```json
{
  "generated_at": "2025-10-31T12:00:00Z",
  "region": "ap-northeast-1",
  "monthly_cost": 123.45,
  "yearly_cost": 1481.40,
  "resources": [
    {
      "type": "aws_instance",
      "name": "web_server",
      "count": 2,
      "monthly_cost": 50.00
    }
  ]
}
```

### 7.3 CSV形式（スプレッドシート用）

```csv
Resource Type,Name,Count,Monthly Cost
aws_instance,web_server,2,50.00
aws_rds_instance,database,1,30.00
```

## 注意事項

### 料金の精度について
1. **基本料金のみ**
   - 本推定は基本的なリソース料金のみを計算
   - データ転送、APIコール、IOPSなどは含まない

2. **使用量ベースの料金**
   - 実際の使用量により変動
   - S3のリクエスト料金
   - Lambda実行時間
   - データ転送量

3. **価格変動**
   - AWS価格は変更される場合がある
   - 最新価格はAWS公式サイトで確認

### セキュリティ
- Terraformファイルには機密情報が含まれる可能性がある
- `.tfvars`ファイルには特に注意
- 推定結果の共有時も機密情報に注意

### 制限事項
1. **動的リソース**
   - `count`や`for_each`が変数に依存する場合、値の推定が必要
   - モジュールの展開が必要な場合がある

2. **条件付きリソース**
   - `count = var.enabled ? 1 : 0`のような条件式の評価
   - 環境変数による分岐

3. **未サポートリソース**
   - 一部の新しいAWSサービスは価格情報が取得できない場合がある

## トラブルシューティング

### MCPツールが利用できない場合
```
エラー: MCP connection failed
→ MCP設定を確認
→ 必要なMCPサーバーがインストールされているか確認
```

### Terraformファイルの解析エラー
```
エラー: Invalid HCL syntax
→ terraform validateで構文チェック
→ 手動で該当箇所を修正
```

### 価格情報が取得できない場合
```
エラー: Price not found for resource type
→ リソースタイプ名を確認
→ リージョンが正しいか確認
→ 新しいサービスの場合、AWS公式サイトで手動確認
```

## 参考リンク

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Price List API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)

## 実装例

### Terraformファイルのパース例

```
1. main.tfを読み込む
2. resource ブロックを抽出
3. 各リソースの属性を解析
4. 変数参照を解決（variables.tfとtfvarsから）
5. リソース情報を構造化
```

### AWS価格取得の例

```
1. AWS MCPに接続
2. get_pricing APIを呼び出し
3. フィルタ条件:
   - Service: AmazonEC2
   - Region: ap-northeast-1
   - Instance Type: t3.medium
   - Operating System: Linux
   - Tenancy: Shared
   - Pricing Model: OnDemand
4. 価格情報をパース
5. 月額料金を計算
```
