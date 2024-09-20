{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-24.url = "nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim.url = "./home/nixvim";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-24,
    home-manager,
    nix-darwin,
    nixvim,
    ...
  }: let
    pkgs-24 = nixpkgs-24.legacyPackages.${"x86_64-darwin"};
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit pkgs-24;};
        modules = [
          ./hosts/desktop
          ./modules/zsh

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.users.evanaze = import ./home/nixos;
          }
        ];
      };
    };

    darwinConfigurations = {
      cooper = nix-darwin.lib.darwinSystem {
        system = "x86_64-darwin";
        specialArgs = {inherit pkgs-24;};
        modules = [
          ./hosts/mac
          ./modules/zsh
          ./modules/mac

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {inherit inputs;};
            home-manager.users.evanazevedo = import ./home/mac;
          }
        ];
      };
    };
  };
}
