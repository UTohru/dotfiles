# デスクトップアプリケーション
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "zoom"
    "discord"
  ];

  home.packages = with pkgs; [
    firefox
    ulauncher
    zoom-us
    discord
  ];
}
