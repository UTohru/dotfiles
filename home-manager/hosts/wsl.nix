# WSL (Ubuntu): GUI なし、CLI + Windows 連携
{ ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/rust.nix
    ../modules/cli/go.nix
    ../modules/cli/node.nix
    ../modules/cli/deno.nix
    ../modules/cli/editor.nix
    ../modules/cli/python.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
  python.uv.enable = true;
}
