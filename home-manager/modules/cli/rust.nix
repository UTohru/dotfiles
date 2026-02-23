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
    dust
    sheldon
  ];
}
