{ pkgs, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    sway
    swayidle
    swaybg
    swaynotificationcenter
    xdg-desktop-portal-wlr
    wdisplays
  ];

  home.file.".config/sway".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/sway";
}
