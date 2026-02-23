{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    pipewire
    imagemagick
    ffmpeg
    pavucontrol
    blueman
    networkmanagerapplet
    i3status-rust
    ulauncher
    pandoc
  ];

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [ fcitx5-mozc fcitx5-gtk fcitx5-nord ];
    };
  };

  systemd.user.services.ulauncher = {
    Unit = {
      Description = "Linux Application Launcher";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1";
      ExecStart = "${pkgs.ulauncher}/bin/ulauncher --hide-window";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  home.activation.pipewireService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    systemctl --user enable --now pipewire pipewire-pulse wireplumber || true
  '';
}
