#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST="${1:?'Usage: setup.sh <host>'}"

# git skip-worktree for local config files
git -C "$SCRIPT_DIR" update-index --skip-worktree \
  .config/zsh/localconf/rc.zsh \
  .config/zsh/localconf/profile.zsh \
  .config/i3/enable/local.conf \
  .config/sway/enable/local.conf \
  .config/hypr/local.conf \
  2>/dev/null || true

# home-manager switch
export REPO_DIR="$(dirname "$SCRIPT_DIR")"
nix run nixpkgs#home-manager -- switch --flake "$SCRIPT_DIR/home-manager#$HOST" --impure

# default shell
ZSH="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$ZSH" && "$SHELL" != "$ZSH" ]]; then
  grep -qxF "$ZSH" /etc/shells || echo "$ZSH" | sudo tee -a /etc/shells
  chsh -s "$ZSH"
fi

# docker group
if command -v docker &>/dev/null; then
  getent group docker &>/dev/null || sudo groupadd docker
  sudo usermod -aG docker "$USER"
fi
