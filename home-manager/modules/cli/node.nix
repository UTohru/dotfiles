# npm-managed tools (not in nixpkgs or too slow to build):
# npm install -g @google/gemini-cli @github/copilot @openai/codex wrangler
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nodejs
    pnpm
  ];

  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "$HOME/.local";
  };
}
