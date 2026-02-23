# デスクトップアプリケーション
{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (pkgs.lib.getName pkg) [
    "zoom"
    "discord"
  ];

  home.packages = with pkgs; [
    ulauncher
    zoom-us
    discord
  ];
}
