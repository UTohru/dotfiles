# GUI 共通パッケージ（X11/Wayland 問わず使用）
# pipewire はシステムレベルのサービスのため管理外
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    fcitx5-mozc
    imagemagick
    ffmpeg
    pavucontrol
    blueman
    i3status-rust
    alacritty
    pandoc
  ];
}
