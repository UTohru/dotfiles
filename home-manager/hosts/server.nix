# Minimal CLI server configuration
{ ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/editor.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
}
