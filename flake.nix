{
  description = "Moth's NixOs configuration(s)";
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "gitlab:rycee/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stable,
    nur,
    agenix,
    nixpkgs-wayland,
  } @ inputs: {
    nixosConfigurations = {
      # Old Moth`s PC 
      MothsLaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/MothsLaptop
          home-manager.nixosModules.home-manager
          nur.nixosModules.nur
          agenix.nixosModule
        ];
        specialArgs = { 
          inputs = inputs;
          hostname = "MothsLaptop";
        };
      };
      # Current Moth`s PC (Thinkpad P1 Laptop currently)
      pcLexell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/pcLexell
          home-manager.nixosModules.home-manager
          nur.nixosModules.nur
          agenix.nixosModule
        ];
        specialArgs = { 
          inputs = inputs;
          hostname = "pcLexell";
        };
      };
    };
  };
}
