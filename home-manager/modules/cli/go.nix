# Go ランタイムとツール群
# pike (github.com/jameswoolfenden/pike) は nixpkgs に存在しないため除外
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    efm-langserver
    terraform-docs
    lefthook
  ];
}
