# AI CLI tools (@google/gemini-cli, @github/copilot, @openai/codex) are not in nixpkgs;
# install separately: npm install -g @google/gemini-cli @github/copilot @openai/codex
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    pnpm
  ];
}
