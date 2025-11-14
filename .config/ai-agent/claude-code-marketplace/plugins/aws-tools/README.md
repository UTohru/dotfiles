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

The plugin and MCP server will be installed automatically when you enable this plugin.

### AWS Credentials (Required for Usage)

The AWS Pricing MCP Server requires AWS credentials to access pricing data. Use any standard AWS authentication method (environment variables, profiles, IAM roles, etc.).

**Required IAM permissions:**
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

**Notes:**
- All Pricing API calls are free (no AWS charges)
- Only accesses public pricing data (no user-specific information)
- You can use the Pricing API even if your AWS account has no resources

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

The plugin automatically configures the AWS Pricing MCP Server. The server uses your AWS credentials' default region.

To customize log level, edit `.mcp.json`:

```json
{
  "mcpServers": {
    "aws-pricing": {
      "command": "uvx",
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    }
  }
}
```

## Troubleshooting

### MCP Server Starts But No Pricing Data

```
Error: Unable to retrieve pricing data
Error: Authentication failed
```

**This is expected if AWS credentials are not configured.**

**Solutions:**
1. Configure AWS credentials using standard AWS methods
2. Verify IAM permissions include `pricing:*`
3. Test credentials: `aws sts get-caller-identity`

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
