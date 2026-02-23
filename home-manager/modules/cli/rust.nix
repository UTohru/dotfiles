# Rust ツール群
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
    eza
    fd
    ripgrep
    du-dust
    sheldon
  ];
}
