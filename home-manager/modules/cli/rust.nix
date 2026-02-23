# Rust ツール群
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    cargo
    rustc
    rustfmt
    clippy
    eza
    fd
    ripgrep
    du-dust
    sheldon
  ];
}
