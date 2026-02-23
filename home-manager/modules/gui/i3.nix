# i3 (X11) 環境
{ config, pkgs, repoDir, ... }:
{
  home.packages = with pkgs; [
    i3
    feh
    dunst
    picom
    maim
    arandr
    pasystray
  ];

  home.file.".config/i3".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/i3";
  home.file.".config/i3status".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/i3status";
}
