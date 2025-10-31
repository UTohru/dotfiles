# AWS Tools Plugin

AWS infrastructure management and cost estimation tools for Claude Code.

## Features

### Commands

- **`/terraform_aws_cost_estimate`**: Estimate AWS infrastructure costs from Terraform files
  - Hybrid approach: Uses Terraform CLI if available, otherwise parses .tf files manually
  - Integrates with AWS Pricing MCP Server for real-time pricing data
  - Generates detailed cost reports in Markdown, JSON, and CSV formats

## Requirements

### Required MCP Servers

This plugin requires the following MCP server:

- **AWS Pricing MCP Server** (`awslabs.aws-pricing-mcp-server`)
  - ✅ Automatically configured when this plugin is enabled
  - ✅ Installation and startup: No AWS credentials required
  - ❌ **Actual pricing data retrieval: Requires AWS credentials**
  - Provides real-time AWS pricing information via AWS Query API
  - All API calls are free of charge (no AWS billing)

### Optional Dependencies

- **Terraform CLI**: For more accurate cost estimation
  - Version: Must match project's `required_version`
  - Not required; plugin falls back to manual parsing if unavailable

## Installation

### Plugin Installation

The plugin and MCP server will be installed automatically when you enable this plugin.

**No AWS credentials are required for installation.**

### AWS Credentials Setup (Required for Usage)

To actually use the cost estimation feature, you need AWS credentials:

**Why credentials are needed:**
- The AWS Pricing MCP Server uses the AWS Price List Query API
- This API requires authentication (unlike the public Bulk API)
- Credentials remain on your local machine
- Only accesses public pricing data (no user-specific information)

**Setup methods:**

```bash
# Option 1: AWS CLI configuration (recommended)
aws configure

# Option 2: Environment variables
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_REGION=us-east-1

# Option 3: AWS Profile
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
```

### IAM Permissions

Your AWS user/role needs the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["pricing:*"],
      "Resource": "*"
    }
  ]
}
```

**Note:** Even if your AWS account has no resources, you can still use the Pricing API to get pricing information. The API is free to use.

## Usage

### Terraform AWS Cost Estimation

```bash
# Use the slash command
/terraform_aws_cost_estimate

# Or ask Claude directly
"Estimate the cost of the Terraform infrastructure in ./terraform"
```

The command will:
1. Check if Terraform CLI is available and compatible
2. If available: Use `terraform plan` for accurate resource extraction
3. If not: Parse `.tf` files manually
4. Query AWS Pricing MCP Server for current pricing
5. Calculate monthly and yearly costs
6. Generate detailed cost reports

## Configuration

### MCP Server Configuration

The plugin automatically configures the AWS Pricing MCP Server. You can customize the configuration by editing `.mcp.json`:

```json
{
  "mcpServers": {
    "aws-pricing": {
      "command": "uvx",
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_REGION": "ap-northeast-1"
      }
    }
  }
}
```

### Customizing AWS Region

To change the default region for pricing queries, update the `AWS_REGION` environment variable in `.mcp.json`.

## Troubleshooting

### MCP Server Starts But No Pricing Data

```
Error: Unable to retrieve pricing data
Error: Authentication failed
```

**This is expected if AWS credentials are not configured.**

**Solutions:**
1. Configure AWS credentials (see "AWS Credentials Setup" above)
2. Verify IAM permissions include `pricing:*`
3. Check AWS_REGION is set correctly
4. Test credentials: `aws pricing describe-services --region us-east-1`

### MCP Server Connection Issues

```
Error: MCP connection failed
Error: Server failed to start
```

**Solutions:**
1. Restart Claude Code to reload MCP servers
2. Verify `uvx` is installed: `which uvx`
3. Verify Python 3.10+ is available: `python3 --version`
4. Check MCP server logs for detailed errors

### Pricing Data Not Available

```
Error: Price not found for resource type
```

**Solutions:**
1. Verify the resource type name is correct
2. Check if the region is supported
3. For new AWS services, pricing data may not be immediately available

## Links

- [AWS Pricing MCP Server](https://github.com/awslabs/mcp)
- [AWS Pricing API Documentation](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/price-changes.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This plugin is part of the personal dotfiles collection.

## Author

UTohru
