{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wezterm
    alacritty
  ];
}
