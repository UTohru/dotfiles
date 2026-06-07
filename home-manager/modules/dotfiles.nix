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

    ".config/zsh".source           = link ".config/zsh";
    ".config/sheldon".source       = link ".config/sheldon";
    ".config/tmux".source          = link ".config/tmux";
    ".config/efm-langserver".source = link ".config/efm-langserver";
  };

  home.activation.lefthookInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (cd "${repoDir}/dotfiles" && PATH="${pkgs.git}/bin:$PATH" ${pkgs.lefthook}/bin/lefthook install)
  '';
}
