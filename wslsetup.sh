#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check required commands
for cmd in git nix; do
  command -v "$cmd" &>/dev/null || { echo "Error: $cmd is required but not found" >&2; exit 1; }
done

# git skip-worktree for local config files
git -C "$SCRIPT_DIR" update-index --skip-worktree \
  .config/zsh/localconf/rc.zsh \
  .config/zsh/localconf/profile.zsh \
  2>/dev/null || true

# home-manager switch
export REPO_DIR="$(dirname "$SCRIPT_DIR")"
nix run nixpkgs#home-manager -- switch --flake "$SCRIPT_DIR/home-manager#wsl" --impure -b backup

mkdir -p "$HOME/.config/zsh/localconf"
grep -q '^export NPM_CONFIG_PREFIX=' "$HOME/.config/zsh/localconf/profile.zsh" 2>/dev/null \
  || echo 'export NPM_CONFIG_PREFIX="$HOME/.local"' >> "$HOME/.config/zsh/localconf/profile.zsh"

# default shell
ZSH="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$ZSH" && "$SHELL" != "$ZSH" ]]; then
  grep -qxF "$ZSH" /etc/shells || echo "$ZSH" | sudo tee -a /etc/shells
  chsh -s "$ZSH"
fi

# copilot mcp config: overwrite from tracked on every run
mkdir -p "$HOME/.copilot"
cp "$SCRIPT_DIR/.config/ai-agent/mcp-servers.json" "$HOME/.copilot/mcp-config.json"

# claude settings.json: overwrite from tracked on every run (claude-config + mcpServers)
mkdir -p "$HOME/.claude"
rm -f "$HOME/.claude/settings.json"
if command -v jq &>/dev/null; then
  mcp_servers=$(jq '.mcpServers' "$SCRIPT_DIR/.config/ai-agent/mcp-servers.json")
  jq --argjson mcp "$mcp_servers" '. + { mcpServers: $mcp }' \
    "$SCRIPT_DIR/.config/ai-agent/claude-config.json" > "$HOME/.claude/settings.json"
else
  cp "$SCRIPT_DIR/.config/ai-agent/claude-config.json" "$HOME/.claude/settings.json"
fi

# codex config: overwrite from tracked on every run (tracked is source of truth; CLI runtime writes are reset)
if command -v codex &>/dev/null; then
  mkdir -p "$HOME/.codex"
  rm -f "$HOME/.codex/config.toml"
  cp "$SCRIPT_DIR/.config/ai-agent/codex-config.toml" "$HOME/.codex/config.toml"
  codex plugin marketplace add "$SCRIPT_DIR/.config/ai-agent"
fi

if command -v gemini &>/dev/null; then
  # gemini settings.json: overwrite from tracked on every run
  mkdir -p "$HOME/.gemini"
  cp "$SCRIPT_DIR/.config/ai-agent/mcp-servers.json" "$HOME/.gemini/settings.json"
  if [ ! -d "${HOME}/.gemini/extensions/review-response" ]; then
    gemini extensions link --consent "$SCRIPT_DIR/.config/ai-agent/plugins/review-response"
  fi
fi
