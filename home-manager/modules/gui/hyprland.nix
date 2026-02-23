# Hyprland (Wayland) 環境
{ pkgs, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
  ];

  home.sessionVariables.TERMINAL = "alacritty";
  systemd.user.sessionVariables.TERMINAL = "alacritty";

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/hypr";
}
