# Docker (rootless)
{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    rootlesskit
    slirp4netns
  ];

  systemd.user.services.docker = {
    Unit = {
      Description = "Docker Application Container Engine (Rootless)";
      After = [ "default.target" "network.target" ];
    };
    Service = {
      Type = "notify";
      Environment = [
        "PATH=${lib.makeBinPath (with pkgs; [ docker rootlesskit slirp4netns iptables ])}:/usr/bin:/bin"
      ];
      ExecStart = "${pkgs.docker}/bin/dockerd-rootless.sh";
      TimeoutStopSec = "infinity";
      Restart = "on-failure";
      RestartSec = 2;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.sessionVariables.DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/docker.sock";
  systemd.user.sessionVariables.DOCKER_HOST = "unix://%t/docker.sock";
}
