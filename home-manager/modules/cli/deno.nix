# Deno ランタイム（vim プラグインのランタイム用途）
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deno
  ];
}
