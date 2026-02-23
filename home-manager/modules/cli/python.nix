{ lib, config, pkgs, ... }:
{
  options.python = {
    uv.enable = lib.mkEnableOption "uv";
  };

  config = lib.mkIf config.python.uv.enable {
    home.packages = [ pkgs.uv ];
  };
}
