{
  description = "Home Manager Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixGL = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input  
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: let
      inherit (inputs) nixpkgs nixpkgs-stable home-manager nixGL nix-index-database;

      system = "x86_64-linux";

      pkgsConfig = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
      pkgs = import nixpkgs {
        inherit system;
        config = pkgsConfig;
      };
      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config = pkgsConfig;
      };
    in {
      homeConfigurations."thomasung" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit pkgs-stable;
          inherit nixGL;
        };
        # Useful stuff for managing modules between hosts
        # https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration
        modules = [
          nix-index-database.hmModules.nix-index
          inputs.zen-browser.homeModules.beta
          ./modules/home.nix
          ./modules/gui
          ./modules/applications
        ];
      };
  };
}
