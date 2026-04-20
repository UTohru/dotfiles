# ai-agent

Shared configuration and plugins for AI coding agents (Claude Code / Codex / Gemini CLI).

## Layout

```
.config/ai-agent/
├── AGENTS.md              # Shared instructions for all agents
├── claude-config.json     # Claude Code settings
├── codex-config.toml      # Codex settings
├── mcp-servers.json       # MCP server definitions
├── .claude-plugin/        # Claude Code marketplace definition
├── .agents/plugins/       # Codex marketplace definition
└── plugins/
    └── review-response/   # GitHub PR review response plugin
```

## Plugin installation

### Codex / Gemini

Registered automatically by `setup.sh` (non-WSL) or `wslsetup.sh` (WSL).

### Claude Code

Not auto-registered. Run the following inside Claude Code once:

```
/plugin marketplace add <path-to-dotfiles>/.config/ai-agent
/plugin install review-response@<marketplace-name>
```

- `<path-to-dotfiles>`: local path where this repo is cloned.
- `<marketplace-name>`: the name displayed after running `/plugin marketplace add`. Auto-assigned because `.claude-plugin/marketplace.json` has no explicit `name` field.

Run `/plugin` inside Claude Code to inspect installed plugins and their enablement.
