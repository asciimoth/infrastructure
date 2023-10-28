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
    master.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      #inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {
    self,
    nixpkgs,
    home-manager,
    stable,
    master,
    nur,
    stylix,
    sops-nix,
    pre-commit-hooks,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    checks = {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          nixfmt.enable = false;
          statix.enable = true;
        };
      };
    };
  in {
    nixosConfigurations = {
      # Moth`s PC (Thinkpad P1 G5 Laptop currently)
      pcLexell = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./machines/pcLexell
          home-manager.nixosModules.home-manager
          nur.nixosModules.nur
          stylix.nixosModules.stylix
          sops-nix.nixosModules.sops
          {
            nixpkgs.overlays = [nur.overlay];
            _module.args.master = import inputs.master {inherit (pkgs.stdenv.targetPlatform) system;};
            _module.args.stable = import inputs.stable {inherit (pkgs.stdenv.targetPlatform) system;};
          }
        ];
        specialArgs = {
          inherit inputs;
          hostname = "pcLexell";
        };
      };
    };
    devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux;
      mkShell {
        inherit (checks.pre-commit-check) shellHook;
        buildInputs = [
          alejandra
          statix
        ];
      };
  };
}
