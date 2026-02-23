# i3 (X11) desktop with full CLI toolchain
{ ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/base.nix
    ../modules/cli/rust.nix
    ../modules/cli/go.nix
    ../modules/cli/node.nix
    ../modules/cli/deno.nix
    ../modules/cli/docker.nix
    ../modules/cli/editor.nix
    ../modules/cli/python.nix
    ../modules/gui/common.nix
    ../modules/gui/i3.nix
    ../modules/gui/fonts.nix
    ../modules/gui/apps.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
  python.uv.enable = true;
}
