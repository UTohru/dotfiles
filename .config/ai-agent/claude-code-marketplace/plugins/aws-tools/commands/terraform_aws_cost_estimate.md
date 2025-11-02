
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

Terraformファイルがあるディレクトリを特定します。

```bash
# Terraformファイルを検索
find . -name "*.tf" -type f

# ディレクトリ構造を確認
tree -L 2 -I 'node_modules|.terraform'
```

## 2. Terraform CLIの利用可能性チェック

```bash
# Terraformコマンドの存在確認
which terraform

# バージョン確認
terraform version

# プロジェクトの要件バージョンを確認
grep -r 'required_version' *.tf
# または
cat versions.tf | grep required_version
```

**判定基準:**

### オプション1: シンプルな判定（推奨）
```bash
# terraform planが実行できるか試す
terraform init && terraform plan -out=tfplan.binary

# 成功 → Path A
# 失敗 → Path B（エラーメッセージを確認して原因を判断）
```

### オプション2: 詳細な判定
1. **Terraformコマンドの存在**
   ```bash
   which terraform || echo "Terraform not found"
   ```

2. **プロジェクト要件の確認**
   - `versions.tf` または他の `.tf` ファイルから `required_version` を確認
   - 例: `required_version = ">= 1.0.0"`

3. **バージョン互換性の確認**
   - インストールされているバージョンが要件を満たすか確認
   - 満たす場合: **Path A**
   - 満たさない場合: **Path B**

4. **実行可能性の確認**
   - `terraform init` が成功するか
   - `terraform validate` が成功するか

**Path 選択:**
- ✅ Terraformコマンドが存在し、プロジェクト要件を満たし、実行可能 → **Path A**
- ❌ 上記のいずれかを満たさない → **Path B**

---

## Path A: Terraform CLIを使用（推奨）

Terraform CLIが利用可能な場合、このパスを使用します。

### A-1. Terraformの初期化

```bash
# 作業ディレクトリに移動
cd <terraform-directory>

# プロジェクトの要件バージョンを確認
cat versions.tf 2>/dev/null || grep -h 'required_version' *.tf 2>/dev/null

# インストールされているバージョンを確認
terraform version

# 初期化（まだの場合）
terraform init
```

**注意:**
- プロジェクトの `required_version` と異なるバージョンのTerraformを使用すると、初期化やplanが失敗する場合があります
- その場合は Path B に切り替えてください

### A-2. Terraform Planの実行

```bash
# planファイルを生成
terraform plan -out=tfplan.binary

# JSON形式で出力
terraform show -json tfplan.binary > tfplan.json
```

### A-3. リソース情報の抽出

`tfplan.json` から以下の情報を抽出します：

```bash
# jqを使ってリソース情報を抽出（例）
cat tfplan.json | jq '.planned_values.root_module.resources[] | {
  type: .type,
  name: .name,
  values: .values
}'
```

**抽出する主要情報:**
- リソースタイプ（`aws_instance`, `aws_rds_instance`, など）
- リソース属性（`instance_type`, `allocated_storage`, など）
- リージョン（`provider_config`から）
- 数量（`count`, `for_each`が展開済み）

### A-4. 抽出結果の構造化

```json
{
  "region": "ap-northeast-1",
  "extraction_method": "terraform_cli",
  "resources": [
    {
      "type": "aws_instance",
      "name": "web_server",
      "count": 2,
      "attributes": {
        "instance_type": "t3.medium",
        "ebs_block_device": [
          {
            "volume_size": 30,
            "volume_type": "gp3"
          }
        ]
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

---

## Path B: 手動パース

Terraform CLIが利用できない場合、.tfファイルを直接解析します。

### B-1. Terraformファイルの読み込み

プロジェクトのすべての `.tf` ファイルを読み込みます：

```bash
# 対象ディレクトリ内のすべての.tfファイルをリスト
find <terraform-directory> -name "*.tf" -type f
```

読み込むファイル：
- `main.tf` - メインのリソース定義
- `variables.tf` - 変数定義
- `terraform.tfvars` または `*.auto.tfvars` - 変数の値
- `provider.tf` - プロバイダー設定
- その他の `.tf` ファイル

### B-2. リソースブロックの抽出

各 `.tf` ファイルから `resource` ブロックを抽出します。

**HCL構文の例:**
```hcl
resource "aws_instance" "web_server" {
  ami           = "ami-xxxxx"
  instance_type = "t3.medium"
  count         = 2

  ebs_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "WebServer"
  }
}
```

**抽出する情報:**
1. リソースタイプ: `"aws_instance"`
2. リソース名: `"web_server"`
3. 属性:
   - `instance_type = "t3.medium"`
   - `count = 2`
   - `ebs_block_device { ... }`

### B-3. 変数参照の解決

`var.xxx` 形式の変数参照を解決します。

**変数定義（variables.tf）:**
```hcl
variable "instance_type" {
  default = "t3.medium"
}

variable "environment" {
  type = string
}
```

**変数値（terraform.tfvars）:**
```hcl
environment = "production"
```

**解決手順:**
1. `variables.tf` から変数定義を読み込む
2. `terraform.tfvars` から値を読み込む
3. デフォルト値がある場合はそれを使用
4. `var.xxx` を実際の値に置換

### B-4. リージョン情報の取得

`provider.tf` または `main.tf` からリージョンを取得します。

```hcl
provider "aws" {
  region = "ap-northeast-1"
}
```

### B-5. 数量の計算

- `count` パラメータ: 指定された数値
- `for_each` パラメータ: セットのサイズ（変数の場合は推定）
- 何もない場合: 1

**注意:** 変数に依存する `count` や `for_each` は推定が必要です。

```hcl
# 固定値の場合
count = 3  # → 3個

# 変数の場合（推定が必要）
count = var.instance_count  # → variables.tfとtfvarsから値を取得
```

### B-6. 抽出結果の構造化

Path Aと同じJSON形式で構造化します。

```json
{
  "region": "ap-northeast-1",
  "extraction_method": "manual_parse",
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
    }
  ]
}
```

---

## 3. AWS料金情報の取得

抽出したリソース情報を基に、AWS Pricing MCP Serverで価格を取得します。

### 3.1 AWS Pricing MCP Serverの使用

各リソースタイプに対して、適切な価格情報を取得します。

#### EC2インスタンスの料金

```
リージョン: ap-northeast-1
インスタンスタイプ: t3.medium
OS: Linux
価格モデル: オンデマンド
→ 時間単価を取得
```

**AWS Pricing MCP Serverへのクエリ例:**
```
"What is the on-demand hourly price for EC2 t3.medium instance in ap-northeast-1 region running Linux?"
```

#### RDSインスタンスの料金

```
リージョン: ap-northeast-1
インスタンスクラス: db.t3.small
エンジン: postgres
デプロイメント: Single-AZ
→ 時間単価を取得
```

#### EBSボリュームの料金

```
リージョン: ap-northeast-1
ボリュームタイプ: gp3
→ GB/月単価を取得
```

#### S3ストレージの料金

```
リージョン: ap-northeast-1
ストレージクラス: Standard
→ GB/月単価を取得（最初の50TB）
```

#### Application Load Balancerの料金

```
リージョン: ap-northeast-1
タイプ: Application Load Balancer
→ 時間単価を取得
```

#### その他の主要リソース

- **Elastic IP**: 未使用時の課金
- **NAT Gateway**: 時間単価 + データ転送料
- **VPN Connection**: 時間単価
- **CloudWatch Logs**: GB単価

### 3.2 データ転送料金の考慮

データ転送は使用量ベースのため、注意点として記載：

**含まれない料金:**
- インターネットへのデータ転送（Out to Internet）
- リージョン間データ転送
- AZ間データ転送
- CloudFrontへのオリジン転送

**推定方法:**
- 一般的な使用パターンから推定値を提示
- または除外することを明記

---

## 4. 料金計算

取得した価格情報を基に月額・年額料金を計算します。

### 4.1 月額料金の計算式

#### 時間単価リソース（EC2, RDS, ALB等）
```
月額料金 = 時間単価 × 24時間 × 30日 × リソース数
```

**例: EC2 t3.medium**
```
時間単価: $0.0544 USD
月額 = $0.0544 × 24 × 30 × 2台 = $78.34 USD
```

#### GB単価リソース（EBS, S3等）
```
月額料金 = GB単価 × サイズ × リソース数
```

**例: EBS gp3 30GB**
```
GB単価: $0.096 USD/GB
月額 = $0.096 × 30GB × 2個 = $5.76 USD
```

#### RDSストレージ
```
月額料金 = GB単価 × サイズ
```

**例: RDS gp3 100GB**
```
GB単価: $0.138 USD/GB
月額 = $0.138 × 100GB = $13.80 USD
```

### 4.2 総コストの集計

```
月額総コスト = Σ(各リソースの月額料金)
年額推定コスト = 月額総コスト × 12
```

---


## 5. レポートの生成

### 5.1 Markdown形式

上記の推定結果をMarkdownファイルとして保存：
```
cost-estimate-YYYY-MM-DD.md
```

### 5.2 JSON形式（プログラム処理用）

```json
{
  "generated_at": "2025-10-31T12:00:00Z",
  "extraction_method": "terraform_cli",
  "region": "ap-northeast-1",
  "summary": {
    "monthly_cost_usd": 150.50,
    "yearly_cost_usd": 1806.00
  },
  "resources": [
    {
      "category": "compute",
      "type": "aws_instance",
      "name": "web_server",
      "count": 2,
      "attributes": {
        "instance_type": "t3.medium"
      },
      "pricing": {
        "hourly_rate_usd": 0.0544,
        "monthly_cost_usd": 78.34
      }
    },
    {
      "category": "database",
      "type": "aws_rds_instance",
      "name": "database",
      "count": 1,
      "attributes": {
        "instance_class": "db.t3.small",
        "engine": "postgres",
        "allocated_storage": 100
      },
      "pricing": {
        "instance_hourly_rate_usd": 0.0544,
        "storage_gb_rate_usd": 0.138,
        "monthly_cost_usd": 52.97
      }
    }
  ],
  "optimization_suggestions": [
    {
      "type": "reserved_instances",
      "potential_savings_yearly_usd": 547
    },
    {
      "type": "right_sizing",
      "potential_savings_monthly_usd": 39
    }
  ]
}
```

### 5.3 CSV形式（スプレッドシート用）

```csv
Category,Resource Type,Name,Count,Instance Type,Monthly Cost (USD)
Compute,aws_instance,web_server,2,t3.medium,78.34
Compute,aws_ebs_volume,web_server_ebs,2,gp3 30GB,5.76
Database,aws_rds_instance,database,1,db.t3.small,39.17
Database,aws_rds_storage,database_storage,1,gp3 100GB,13.80
Networking,aws_lb,app_lb,1,ALB,27.01
```

---

## 制限事項と注意点

### 料金の精度について

1. **基本料金のみ**
   - 本推定は基本的なリソース料金のみを計算
   - データ転送、APIコール、IOPSなどは含まない

2. **使用量ベースの料金**
   - 実際の使用量により変動
   - S3のリクエスト料金
   - Lambda実行時間
   - データ転送量
   - RDS IOPSとバックアップストレージ

3. **価格変動**
   - AWS価格は変更される場合がある
   - 最新価格はAWS公式サイトで確認

### Path B（手動パース）の制限事項

1. **動的リソース**
   - `count`や`for_each`が変数に依存する場合、値の推定が必要
   - 複雑な条件式の評価が困難な場合がある

2. **モジュール**
   - Terraformモジュールの展開は手動で行う必要がある
   - ネストしたモジュールの解析は複雑

3. **条件付きリソース**
   - `count = var.enabled ? 1 : 0`のような条件式
   - 環境変数による分岐

### セキュリティ

- Terraformファイルには機密情報が含まれる可能性がある
- `.tfvars`ファイルには特に注意
- `terraform plan`の出力にも機密情報が含まれる可能性
- 推定結果の共有時も機密情報に注意

---

## トラブルシューティング

### Terraform CLIが認識されない

```bash
# PATHの確認
echo $PATH

# Terraformの場所を確認
which terraform

# 手動でパスを指定
/usr/local/bin/terraform version
```

**対処:** Path Bに切り替えて手動パースを実行

---

## 参考リンク

- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Price List API](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [AWS Pricing MCP Server (GitHub)](https://github.com/awslabs/mcp)
- [Terraform Language Documentation](https://developer.hashicorp.com/terraform/language)

---

## 実装例

### Path A: Terraform CLIを使用したコマンド

```bash
#!/bin/bash

# 1. バージョン確認（情報表示のみ）
TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
echo "Terraform version: $TF_VERSION"

# プロジェクトの要件確認
grep -h 'required_version' *.tf 2>/dev/null || echo "No version requirement found"


# 3. Planの生成
# 必要に応じてterraform init
terraform plan -out=tfplan.binary || { echo "plan failed, switching to Path B"; exit 1; }

# 4. JSON形式で出力
terraform show -json tfplan.binary > tfplan.json

# 5. リソース情報の抽出
cat tfplan.json | jq '.planned_values.root_module.resources[] | {
  type: .type,
  name: .name,
  count: (.values.count // 1),
  attributes: .values
}' > resources.json

# 6. AWS Pricing MCP Serverで価格取得
# （Claude Codeで実行）

# 7. クリーンアップ
```


### AWS価格取得の例

AWS Pricing MCP Serverを使用した自然言語クエリ：

```
# EC2の価格取得
"What is the on-demand hourly price for EC2 t3.medium instance
in ap-northeast-1 region running Linux?"

# RDSの価格取得
"Get the hourly price for RDS db.t3.small PostgreSQL instance
in Tokyo region with Single-AZ deployment"

# EBSの価格取得
"What is the monthly price per GB for EBS gp3 volumes
in ap-northeast-1?"
```
