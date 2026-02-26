{ pkgs, ... }:
{
  allowUnfreePackages = [ "zoom" "discord" ];

  home.packages = with pkgs; [
    firefox
    zoom-us
    discord
  ];
}
