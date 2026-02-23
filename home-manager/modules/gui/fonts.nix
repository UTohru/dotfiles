# フォント
# Cica / Firge は nixpkgs に存在しないため手動インストールが必要:
#   https://github.com/miiton/Cica/releases
#   https://github.com/yuru7/Firge/releases
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    udev-gothic
  ];
}
