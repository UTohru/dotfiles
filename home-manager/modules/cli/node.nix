# Node.js ランタイム
# AI CLI ツール（@google/gemini-cli, @github/copilot, @openai/codex）は
# 更新頻度が高く nixpkgs 管理外のため npm で別途インストールする:
#   npm install -g @google/gemini-cli @github/copilot @openai/codex
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    pnpm
  ];
}
