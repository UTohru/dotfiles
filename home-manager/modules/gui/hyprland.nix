# Hyprland (Wayland) 環境
{ pkgs, lib, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    hyprland
    xdg-desktop-portal-hyprland
    greetd
    regreet
    cage
  ];

  home.activation.greetdService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/usr/bin:/usr/sbin:$PATH"
    sudo systemctl enable --now greetd
  '';

  home.sessionVariables.TERMINAL = "alacritty";
  systemd.user.sessionVariables.TERMINAL = "alacritty";

  home.file.".config/hypr".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/hypr";
}
