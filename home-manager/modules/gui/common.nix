{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fcitx5-mozc
    imagemagick
    ffmpeg
    pavucontrol
    blueman
    networkmanagerapplet
    i3status-rust
    wezterm
    alacritty
    ulauncher
    pandoc
  ];
}
