# ラップトップ向け電源管理
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    tlp
    brightnessctl
    powertop
  ];

  home.activation.tlpService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/usr/bin:/usr/sbin:$PATH"
    sudo tee /etc/systemd/system/tlp.service > /dev/null <<EOF
    [Unit]
    Description=TLP system startup/shutdown
    After=multi-user.target

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    ExecStart=${pkgs.tlp}/bin/tlp start
    ExecStop=${pkgs.tlp}/bin/tlp stop

    [Install]
    WantedBy=multi-user.target
    EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now tlp
  '';
}
