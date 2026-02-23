# Hyprland (Wayland) 環境
{ pkgs, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
  ];

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/hypr";
}
