# Docker (system daemon)
{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
  ];

  home.activation.dockerService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="/usr/bin:/usr/sbin:$PATH"
    sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
    [Unit]
    Description=Docker Application Container Engine
    Documentation=https://docs.docker.com
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=notify
    ExecStart=${pkgs.docker}/bin/dockerd
    ExecReload=/bin/kill -s HUP \$MAINPID
    TimeoutStartSec=0
    RestartSec=2
    Restart=always
    StartLimitBurst=3
    StartLimitInterval=60s
    LimitNOFILE=1048576
    LimitNPROC=infinity
    LimitCORE=infinity
    TasksMax=infinity
    Delegate=yes
    KillMode=process

    [Install]
    WantedBy=multi-user.target
    EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now docker
  '';
}
