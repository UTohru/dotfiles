{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zsh
    jq
    libsixel
  ];
}
