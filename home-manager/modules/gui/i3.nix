{ config, lib, pkgs, repoDir, ... }:
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

  home.sessionVariables.TERMINAL = "wezterm";
  systemd.user.sessionVariables.TERMINAL = "wezterm";

  home.activation.i3Session = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    sudo install -dm755 /usr/share/xsessions
    sudo tee /usr/share/xsessions/i3.desktop > /dev/null << EOF
[Desktop Entry]
Name=i3
Comment=improved dynamic tiling window manager
Exec=${pkgs.i3}/bin/i3
TryExec=${pkgs.i3}/bin/i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
EOF
  '';

  home.file.".config/i3".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/i3";
  home.file.".config/i3status".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/i3status";
}
