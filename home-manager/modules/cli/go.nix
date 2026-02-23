# pike (github.com/jameswoolfenden/pike) is not in nixpkgs
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    efm-langserver
    terraform-docs
    lefthook
  ];
}
