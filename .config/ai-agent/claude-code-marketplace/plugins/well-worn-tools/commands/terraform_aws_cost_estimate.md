
TerraformファイルからAWSインフラストラクチャの料金推定を行います。
Terraform CLIが利用可能な場合は自動解析、そうでない場合は手動パースのハイブリッドアプローチを採用します。

# 前提条件

## 必須
- **AWS Pricing MCP Server**: AWS価格情報の取得に必須
  - パッケージ: `awslabs.aws-pricing-mcp-server`
  - すべてのAPI呼び出しは無料

## オプション
- **Terraform CLI**: 利用可能な場合、より正確な解析が可能
  - バージョン: v0.12以上を推奨
  - 変数展開やモジュール解決が自動で行われる

# 実行フロー

```
1. Terraformディレクトリの確認
   ↓
2. Terraform CLIの利用可能性チェック
   ↓
   ├─ 利用可能（v0.12以上）→ [Path A] Terraform CLIを使用
   │
   └─ 利用不可 → [Path B] 手動パース
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

# バージョン確認（v0.12以上を推奨）
terraform version
```

**判定基準:**
- ✅ Terraformコマンドが存在し、バージョンがv0.12以上 → **Path A**
- ❌ コマンドが存在しない、またはv0.12未満 → **Path B**

---

## Path A: Terraform CLIを使用（推奨）

Terraform CLIが利用可能な場合、このパスを使用します。

### A-1. Terraformの初期化

```bash
# 作業ディレクトリに移動
cd <terraform-directory>

# 初期化（まだの場合）
terraform init
```

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

### 4.3 結果の出力

料金推定結果を以下の形式で出力：

```markdown
# AWS料金推定結果

**生成日時:** 2025-10-31 12:00:00 UTC
**解析方法:** Terraform CLI / 手動パース
**リージョン:** ap-northeast-1

---

## サマリー

| 項目 | 金額（USD） |
|------|-------------|
| 月額総コスト | $150.50 |
| 年額推定コスト | $1,806.00 |

---

## リソース別内訳

### 💻 Compute

#### EC2インスタンス
- **タイプ:** t3.medium × 2台
- **月額:** $78.34 USD
- **内訳:** $0.0544/時間 × 24h × 30日 × 2台 = $78.34

#### EBSボリューム（EC2添付）
- **タイプ:** gp3 30GB × 2個
- **月額:** $5.76 USD
- **内訳:** $0.096/GB × 30GB × 2個 = $5.76

**Compute 小計:** $84.10 USD

---

### 🗄️ Database

#### RDSインスタンス
- **クラス:** db.t3.small
- **エンジン:** PostgreSQL
- **月額:** $39.17 USD
- **内訳:** $0.0544/時間 × 24h × 30日 = $39.17

#### RDSストレージ
- **タイプ:** gp3 100GB
- **月額:** $13.80 USD
- **内訳:** $0.138/GB × 100GB = $13.80

**Database 小計:** $52.97 USD

---

### 🌐 Networking

#### Application Load Balancer
- **月額:** $27.01 USD
- **内訳:** $0.0243/時間 × 24h × 30日 + LCU料金 = $27.01

**Networking 小計:** $27.01 USD

---

## 注意事項

⚠️ **以下の料金は含まれていません:**
- データ転送料金（使用量により変動）
- S3リクエスト料金
- CloudWatch メトリクス・ログ
- APIコール料金
- バックアップストレージ

⚠️ **その他:**
- 実際の請求額は使用時間・使用量により変動します
- Reserved InstanceやSavings Plansによる割引は考慮されていません
- スポットインスタンスの場合、最大90%の割引が可能です
```

---

## 5. コスト最適化の提案

料金推定結果を基に、以下の最適化を提案します。

### 5.1 予約購入による削減

**Reserved Instances（1年契約、前払いなし）:**
- EC2 t3.medium × 2台: $78.34 → $48.00 (-39%)
- RDS db.t3.small: $39.17 → $24.00 (-39%)

**年間削減額:** 約$547 USD

**Savings Plans（1年契約）:**
- より柔軟な適用範囲
- Lambdaやfargateにも適用可能

### 5.2 リソースサイズの見直し

**現在の構成:**
- EC2 t3.medium (2 vCPU, 4GB RAM) × 2台

**提案:**
- 使用率が50%以下の場合: t3.small (2 vCPU, 2GB RAM) に変更
  - 月額削減: 約$39 USD

### 5.3 ストレージ最適化

**EBS:**
- gp2 → gp3 に変更済み（20%削減達成済み）✅
- スナップショットのライフサイクル管理

**S3:**
- ライフサイクルポリシーの設定
  - Standard → Standard-IA (30日後): -46%
  - Standard-IA → Glacier (90日後): -68%

### 5.4 リージョン最適化

**価格比較（EC2 t3.medium）:**
- ap-northeast-1（東京）: $0.0544/時間
- us-east-1（バージニア）: $0.0416/時間 (-24%)
- ap-northeast-2（ソウル）: $0.0504/時間 (-7%)

**注意:** レイテンシーとコンプライアンス要件を考慮

### 5.5 アーキテクチャの見直し

**スポットインスタンス:**
- 中断可能なワークロード向け
- 最大90%の割引
- Auto Scalingと組み合わせ

**Serverlessの検討:**
- Lambda: イベント駆動処理
- Fargate: コンテナワークロード
- Aurora Serverless: 間欠的なDBアクセス

**Auto Scaling:**
- 需要に応じた自動スケーリング
- 夜間・週末のスケールダウン

---

## 6. レポートの生成

### 6.1 Markdown形式

上記の推定結果をMarkdownファイルとして保存：
```
cost-estimate-YYYY-MM-DD.md
```

### 6.2 JSON形式（プログラム処理用）

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

### 6.3 CSV形式（スプレッドシート用）

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

### terraform plan が失敗する

```
エラー: Error: Missing required argument
```

**対処:**
1. `terraform.tfvars`に必要な変数が定義されているか確認
2. `-var-file`オプションで明示的に指定
3. Path Bに切り替えて手動パース

### AWS Pricing MCP Serverが利用できない

```
エラー: MCP connection failed
```

**対処:**
1. MCP設定を確認（`claude_desktop_config.json`など）
2. `awslabs.aws-pricing-mcp-server`がインストールされているか確認
3. AWS認証情報を確認（`pricing:*` 権限が必要）

### 価格情報が取得できない

```
エラー: Price not found for resource type
```

**対処:**
1. リソースタイプ名が正しいか確認
2. リージョンが正しいか確認
3. 新しいサービスの場合、AWS公式サイトで手動確認
4. 類似リソースの価格で代用

### HCL構文の解析エラー（Path B）

```
エラー: Invalid HCL syntax
```

**対処:**
1. Terraform CLIが利用可能な場合、Path Aに切り替え
2. `terraform fmt`でフォーマット
3. `terraform validate`で構文チェック
4. 問題のある箇所を手動で修正

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

### Path A: Terraform CLIを使用した実装

```bash
#!/bin/bash

# 1. バージョンチェック
TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
echo "Terraform version: $TF_VERSION"

# 2. 初期化
terraform init

# 3. Planの生成
terraform plan -out=tfplan.binary

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
rm tfplan.binary
```

### Path B: 手動パースの実装例

```python
# HCL解析の擬似コード
import re

def parse_terraform_file(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

    # resourceブロックを抽出
    resource_pattern = r'resource\s+"([^"]+)"\s+"([^"]+)"\s*{([^}]+)}'
    resources = []

    for match in re.finditer(resource_pattern, content, re.DOTALL):
        resource_type = match.group(1)
        resource_name = match.group(2)
        resource_body = match.group(3)

        # 属性を抽出
        attributes = parse_attributes(resource_body)

        resources.append({
            'type': resource_type,
            'name': resource_name,
            'attributes': attributes
        })

    return resources

def parse_attributes(body):
    # 属性のパース処理
    # ...
    return attributes
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
