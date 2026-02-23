# サーバー: 最小 CLI 構成
{ ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/editor.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
}
