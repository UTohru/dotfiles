# Hyprland (Wayland) desktop with full CLI toolchain
{ ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/rust.nix
    ../modules/cli/go.nix
    ../modules/cli/node.nix
    ../modules/cli/deno.nix
    ../modules/cli/docker.nix
    ../modules/cli/editor.nix
    ../modules/cli/python.nix
    ../modules/gui/common.nix
    ../modules/gui/wayland-common.nix
    ../modules/gui/hyprland.nix
    ../modules/gui/fonts.nix
    ../modules/gui/apps.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
  python.uv.enable = true;
}
