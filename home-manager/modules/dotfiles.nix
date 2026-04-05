{ config, lib, pkgs, repoDir, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/${path}";
  mcpServers = (builtins.fromJSON (builtins.readFile "${repoDir}/dotfiles/.config/ai-agent/mcp-servers.json")).mcpServers;
  claudeConfig = builtins.fromJSON (builtins.readFile "${repoDir}/dotfiles/.config/ai-agent/claude-config.json");
in
{
  home.file = {
    ".claude/settings.json".text = builtins.toJSON (claudeConfig // { inherit mcpServers; });
    ".gemini/settings.json".text = builtins.toJSON { inherit mcpServers; };
    ".copilot/mcp-config.json".text = builtins.toJSON { inherit mcpServers; };
    ".zshenv".source                          = link ".zshenv";
    ".xprofile".source                        = link ".xprofile";
    ".dircolors".source                       = link "_shell/dircolors";
    ".textlintrc".source                      = link "others/.textlintrc";
    ".local/share/deno_ts/textlint.ts".source = link "others/textlint.ts";

    # AI agent config
    ".claude/CLAUDE.md".source      = link ".config/ai-agent/AGENTS.md";
    ".claude/commands".source       = link ".config/ai-agent/commands";
    ".codex/AGENTS.md".source       = link ".config/ai-agent/AGENTS.md";
    ".codex/config.toml".source     = link ".config/ai-agent/codex-config.toml";

    ".config/zsh".source           = link ".config/zsh";
    ".config/sheldon".source       = link ".config/sheldon";
    ".config/tmux".source          = link ".config/tmux";
    ".config/efm-langserver".source = link ".config/efm-langserver";
    ".config/ai-agent".source      = link ".config/ai-agent";
  };

  home.activation.lefthookInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (cd "${repoDir}/dotfiles" && PATH="${pkgs.git}/bin:$PATH" ${pkgs.lefthook}/bin/lefthook install)
  '';
}
