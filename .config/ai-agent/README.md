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
Codex uses `codex plugin marketplace add <path-to-dotfiles>/.config/ai-agent`.

### Claude Code

Not auto-registered. Run the following inside Claude Code once:

```
/plugin marketplace add <path-to-dotfiles>/.config/ai-agent
/plugin install review-response@dotfiles
```

- `<path-to-dotfiles>`: local path where this repo is cloned.

Run `/plugin` inside Claude Code to inspect installed plugins and their enablement.
