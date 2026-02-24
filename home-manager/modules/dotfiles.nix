{ config, lib, pkgs, repoDir, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/${path}";
in
{
  home.file = {
    ".zshenv".source                          = link ".zshenv";
    ".xprofile".source                        = link ".xprofile";
    ".dircolors".source                       = link "_shell/dircolors";
    ".textlintrc".source                      = link "others/.textlintrc";
    ".local/share/deno_ts/textlint.ts".source = link "others/textlint.ts";

    # AI agent config
    ".claude/CLAUDE.md".source    = link ".config/ai-agent/AGENTS.md";
    ".codex/AGENTS.md".source     = link ".config/ai-agent/AGENTS.md";
    ".codex/config.toml".source   = link ".config/ai-agent/codex-config.toml";

    ".config/zsh".source           = link ".config/zsh";
    ".config/sheldon".source       = link ".config/sheldon";
    ".config/tmux".source          = link ".config/tmux";
    ".config/efm-langserver".source = link ".config/efm-langserver";
    ".config/zathura".source       = link ".config/zathura";
    ".config/latexmk".source       = link ".config/latexmk";
    ".config/environment.d/wayland.conf".source = link ".config/environment.d/wayland.conf";
    ".config/wezterm".source       = link ".config/wezterm";
    ".config/alacritty".source     = link ".config/alacritty";
    ".config/greetd".source        = link ".config/greetd";
    ".config/ai-agent".source      = link ".config/ai-agent";
    ".config/conky".source         = link ".config/conky";
  };

  home.activation.lefthookInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (cd "${repoDir}/dotfiles" && PATH="${pkgs.git}/bin:$PATH" ${pkgs.lefthook}/bin/lefthook install)
  '';
}
