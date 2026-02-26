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

      # requires --impure; read from environment at runtime
      username = builtins.getEnv "USER";
      homeDirectory = builtins.getEnv "HOME";
      repoDir = builtins.getEnv "REPO_DIR";
      stateVersion = "25.11";

      mkHost = host: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit repoDir; };
        modules = [
          ./modules/nixpkgs.nix
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
