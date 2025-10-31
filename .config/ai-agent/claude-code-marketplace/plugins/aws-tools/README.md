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

This plugin requires the following MCP server to be installed and configured:

- **AWS Pricing MCP Server** (`awslabs.aws-pricing-mcp-server`)
  - Automatically configured when this plugin is enabled
  - Provides real-time AWS pricing information
  - All API calls are free of charge
  - Requires AWS credentials with `pricing:*` permissions

### Optional Dependencies

- **Terraform CLI**: For more accurate cost estimation
  - Version: Must match project's `required_version`
  - Not required; plugin falls back to manual parsing if unavailable

## Installation

### AWS Credentials Setup

The AWS Pricing MCP Server requires AWS credentials with pricing permissions:

```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_PROFILE=your-profile
export AWS_REGION=us-east-1
```

### IAM Permissions

Ensure your AWS user/role has the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "pricing:*"
      ],
      "Resource": "*"
    }
  ]
}
```

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

### MCP Server Connection Issues

```
Error: MCP connection failed
```

**Solutions:**
1. Verify AWS credentials are configured
2. Check IAM permissions include `pricing:*`
3. Restart Claude Code to reload MCP servers
4. Verify `uvx` and Python are installed

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
