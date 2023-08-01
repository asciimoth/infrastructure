# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
{
  description = "Moth's NixOs configuration(s)";
  inputs = {
    stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    #agenix = {
    #  url = "github:ryantm/agenix";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    nixpkgs-wayland = {
      url = "github:colemickens/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stable,
    nur,
    #agenix,
    nixpkgs-wayland,
    stylix,
    sops-nix,
  } @ inputs: {
    nixosConfigurations = {
      # Moth`s PC (Thinkpad P1 G5 Laptop currently)
      pcLexell = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/pcLexell
          home-manager.nixosModules.home-manager
          nur.nixosModules.nur
          #agenix.nixosModules
          stylix.nixosModules.stylix
          sops-nix.nixosModules.sops
        ];
        specialArgs = {
          inherit inputs;
          hostname = "pcLexell";
        };
      };
    };
  };
}
