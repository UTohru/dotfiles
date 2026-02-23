{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    fcitx5
    fcitx5-mozc
    pipewire
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

  home.activation.pipewireService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
  '';
}
