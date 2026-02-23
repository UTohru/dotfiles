# Docker
# dockerd デーモンはシステムレベルの設定が必要なため home-manager の管理外:
#   sudo systemctl enable --now docker
#   sudo usermod -aG docker $USER
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
  ];
}
