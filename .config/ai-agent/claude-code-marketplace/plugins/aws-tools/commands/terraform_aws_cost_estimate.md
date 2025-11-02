
TerraformファイルからAWSインフラストラクチャの料金推定を行います。
Terraform CLIが利用可能な場合は自動解析、そうでない場合は手動パースのハイブリッドアプローチを採用します。

# 前提条件

## 必須
- **AWS Pricing MCP Server**: AWS価格情報の取得に必須
  - パッケージ: `awslabs.aws-pricing-mcp-server`
  - すべてのAPI呼び出しは無料

## オプション
- **Terraform CLI**: 利用可能な場合、より正確な解析が可能
  - バージョン: プロジェクトの `required_version` に準拠
  - 変数展開やモジュール解決が自動で行われる

# 実行フロー

```
1. Terraformディレクトリの確認
   ↓
2. Terraform CLIの利用可能性チェック
   ↓
   ├─ 利用可能かつプロジェクト要件を満たす → [Path A] Terraform CLIを使用
   │
   └─ 利用不可またはバージョン不一致 → [Path B] 手動パース
   ↓
3. AWS Pricing MCP Serverで価格取得
   ↓
4. 料金計算
   ↓
5. レポート生成
```

---

# 手順

## 1. Terraformディレクトリの確認

```bash
find . -name "*.tf" -type f
```

## 2. Terraform CLIの利用可能性チェック

```bash
terraform init && terraform plan -out=tfplan.binary
```

- 成功 → **Path A**（Terraform CLI使用）
- 失敗 → **Path B**（手動パース）

---

## Path A: Terraform CLIを使用（推奨）

### A-1. Planの実行とJSON出力

```bash
cd <terraform-directory>
terraform init
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
```

### A-2. リソース情報の抽出

```bash
cat tfplan.json | jq '.planned_values.root_module.resources[] | {
  type: .type,
  name: .name,
  values: .values
}'
```

抽出項目：リソースタイプ、属性、リージョン、数量（展開済み）

### A-3. リソース情報の整理

抽出した情報を整理：
- リージョン、抽出方法
- 各リソースのタイプ、名前、数量、主要属性

---

## Path B: 手動パース

### B-1. Terraformファイルの読み込み

```bash
find <terraform-directory> -name "*.tf" -type f
```

対象：`main.tf`, `variables.tf`, `terraform.tfvars`, `provider.tf` など

### B-2. リソースブロックの抽出

`resource` ブロックから以下を抽出：
- リソースタイプ（例：`aws_instance`）
- リソース名
- 属性（`instance_type`, `count` など）

### B-3. 変数参照の解決

1. `variables.tf` から変数定義を読み込む
2. `terraform.tfvars` から値を読み込む
3. デフォルト値を使用
4. `var.xxx` を実際の値に置換

### B-4. リージョン情報と数量の取得

- リージョン：`provider.tf` から取得
- 数量：`count`（なければ1）、`for_each`（変数の場合は推定）

### B-5. リソース情報の整理

抽出した情報を整理（Path Aと同様）

---

## 3. AWS料金情報の取得

AWS Pricing MCP Serverを使用して価格を取得します。

### 主要リソースの価格取得

各リソースタイプのクエリ例：

```
# EC2
"What is the on-demand hourly price for EC2 t3.medium instance in ap-northeast-1 region running Linux?"

# RDS
"Get the hourly price for RDS db.t3.small PostgreSQL instance in Tokyo region with Single-AZ deployment"

# EBS
"What is the monthly price per GB for EBS gp3 volumes in ap-northeast-1?"
```

その他：S3, ALB, Elastic IP, NAT Gateway, VPN, CloudWatch Logsなど

**注意:** データ転送料金は使用量ベースのため、基本料金のみを計算します。

---

## 4. 料金計算

### 計算式

- **時間単価リソース**（EC2, RDS, ALBなど）
  ```
  月額 = 時間単価 × 24 × 30 × リソース数
  ```

- **GB単価リソース**（EBS, S3など）
  ```
  月額 = GB単価 × サイズ × リソース数
  ```

- **総コスト**
  ```
  月額総コスト = Σ(各リソースの月額料金)
  年額推定コスト = 月額総コスト × 12
  ```

---


## 5. レポートの生成

### Markdown形式での出力（推奨）

以下の内容を含むMarkdownレポートを生成：

```markdown
# AWS Terraform コスト推定レポート

**生成日時**: 2025-10-31
**リージョン**: ap-northeast-1
**抽出方法**: Terraform CLI

## サマリー

- 月額総コスト: $150.50 USD
- 年額推定コスト: $1,806.00 USD

## リソース詳細

### Compute

#### EC2 (aws_instance: web_server)
- 数量: 2台
- インスタンスタイプ: t3.medium
- 時間単価: $0.0544
- 月額コスト: $78.34

### Database

#### RDS (aws_rds_instance: database)
- 数量: 1個
- インスタンスクラス: db.t3.small
- エンジン: postgres
- ストレージ: 100GB
- 月額コスト: $52.97

## 注意事項

- データ転送料金は含まれていません
- 使用量ベースの料金（S3リクエスト、Lambda実行など）は除外
```

ファイル名: `cost-estimate-YYYY-MM-DD.md`

**オプション**: 必要に応じてJSON/CSV形式でも出力可能

---

## 制限事項と注意点

### 料金の精度

- 基本料金のみ計算（データ転送、APIコール、IOPSなどは含まない）
- 使用量ベースの料金は変動（S3リクエスト、Lambda実行時間など）
- AWS価格は変更される可能性がある

### Path B（手動パース）の制限

- 動的リソース（変数依存の`count`/`for_each`）は推定が必要
- モジュール展開は手動対応
- 複雑な条件式の評価が困難な場合がある

### セキュリティ

Terraformファイルやplanの出力には機密情報が含まれる可能性があるため、共有時は注意してください。

---

## トラブルシューティング

- **Terraform CLIが認識されない**: Path Bに切り替えて手動パースを実行
- **バージョン不一致**: プロジェクトの`required_version`を確認し、適切なバージョンを使用
- **MCP Server接続エラー**: Claude Codeを再起動し、AWS認証情報を確認

---

## 参考リンク

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Price List API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [AWS Pricing MCP Server (GitHub)](https://github.com/awslabs/mcp)
- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)
