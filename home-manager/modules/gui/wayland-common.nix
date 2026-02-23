{ pkgs, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    waybar
    grim
    slurp
  ];

  home.file.".config/waybar".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/waybar";
}
