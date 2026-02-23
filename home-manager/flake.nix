{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # --impure で実行時の環境変数から取得する
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      repoDir = builtins.getEnv "REPO_DIR";

      # 初回 home-manager switch 時のバージョンに合わせて設定し、以後変更しない
      stateVersion = "24.11";

      mkHost = host: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit repoDir; };
        modules = [
          host
          {
            home.username = username;
            home.homeDirectory = homeDirectory;
            home.stateVersion = stateVersion;
          }
        ];
      };
    in
    {
      homeConfigurations = {
        i3       = mkHost ./hosts/i3.nix;
        hyprland = mkHost ./hosts/hyprland.nix;
        wsl     = mkHost ./hosts/wsl.nix;
        server  = mkHost ./hosts/server.nix;
      };
    };
}
