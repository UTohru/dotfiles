{ lib, config, pkgs, ... }:
{
  options.infra = {
    terraform.enable  = lib.mkEnableOption "terraform";
    aws.enable        = lib.mkEnableOption "aws cli (includes session-manager-plugin)";
    gcloud.enable     = lib.mkEnableOption "gcloud";
  };

  config = lib.mkMerge [
    (lib.mkIf config.infra.terraform.enable {
      allowUnfreePackages = [ "terraform" ];
      home.packages = with pkgs; [ terraform terraform-docs ];
    })
    (lib.mkIf config.infra.aws.enable {
      home.packages = with pkgs; [ awscli2 ssm-session-manager-plugin ];
    })
    (lib.mkIf config.infra.gcloud.enable {
      home.packages = with pkgs; [ google-cloud-sdk ];
    })
  ];
}
