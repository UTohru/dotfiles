# エディタ: vim / nvim を host ごとに選択可能（両方 enable にもできる）
{ lib, config, pkgs, repoDir, ... }:
{
  options.editor = {
    vim.enable  = lib.mkEnableOption "vim";
    nvim.enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkMerge [
    (lib.mkIf config.editor.vim.enable {
      home.packages = [ pkgs.vim ];
      home.file = {
        ".vim".source   = config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/vim";
        ".vimrc".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.vimrc";
      };
    })
    (lib.mkIf config.editor.nvim.enable {
      home.packages = [ pkgs.neovim ];
      home.file = {
        ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/nvim";
      };
    })
  ];
}
