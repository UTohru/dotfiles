{ lib, config, pkgs, ... }:
{
  options.infra = {
    terraform.enable  = lib.mkEnableOption "terraform";
    aws.enable        = lib.mkEnableOption "aws cli (includes session-manager-plugin)";
    gcloud.enable     = lib.mkEnableOption "gcloud";
    cloudflare.enable = lib.mkEnableOption "cloudflare wrangler";
  };

  config = lib.mkMerge [
    (lib.mkIf config.infra.terraform.enable {
      home.packages = with pkgs; [ terraform terraform-docs ];
    })
    (lib.mkIf config.infra.aws.enable {
      home.packages = with pkgs; [ awscli2 session-manager-plugin ];
    })
    (lib.mkIf config.infra.gcloud.enable {
      home.packages = with pkgs; [ google-cloud-sdk ];
    })
    (lib.mkIf config.infra.cloudflare.enable {
      home.packages = with pkgs; [ nodePackages.wrangler ];
    })
  ];
}
