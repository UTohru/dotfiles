# ターミナルエミュレータ
{ pkgs, repoDir, config, ... }:
{
  home.packages = with pkgs; [
    wezterm
  ];

  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/wezterm";
  home.file.".config/alacritty".source =
    config.lib.file.mkOutOfStoreSymlink "${repoDir}/dotfiles/.config/alacritty";
}
