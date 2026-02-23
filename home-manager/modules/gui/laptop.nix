# ラップトップ向け電源管理
# tlp サービスの有効化はシステムレベルの設定が必要:
#   sudo systemctl enable --now tlp
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tlp
    brightnessctl
    powertop
  ];
}
