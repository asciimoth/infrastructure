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
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
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
  } @ inputs: {
    nixosConfigurations = {
      # Moth`s PC (Thinkpad P1 G5 Laptop currently)
      pcLexell = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
      in
        nixpkgs.lib.nixosSystem {
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
            stateVersion = "23.11";
          };
        };
      # Laptop used as VPN router
      istvaan = let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
      in
        nixpkgs.lib.nixosSystem {
          modules = [
            ./machines/istvaan
            home-manager.nixosModules.home-manager
            nur.nixosModules.nur
            sops-nix.nixosModules.sops
            {
              nixpkgs.overlays = [nur.overlay];
              _module.args.master = import inputs.master {inherit (pkgs.stdenv.targetPlatform) system;};
              _module.args.stable = import inputs.stable {inherit (pkgs.stdenv.targetPlatform) system;};
            }
          ];
          specialArgs = {
            inherit inputs;
            hostname = "istvaan";
            stateVersion = "23.11";
          };
        };
    };
    # idk why I use two devShells for x86 and aarh instead of one crossplatform
    # I just copy-paste this template from somewhere
    devShells = {
      x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux;
        mkShell {
          inherit
            (pre-commit-hooks.lib.x86_64-linux.run {
              src = ./.;
              hooks = {
                alejandra.enable = true;
                statix.enable = true;
              };
            })
            shellHook
            ;
          buildInputs = [
            alejandra
            statix
          ];
        };
      aarch64-linux.default = with nixpkgs.legacyPackages.aarch64-linux;
        mkShell {
          inherit
            (pre-commit-hooks.lib.aarch64-linux.run {
              src = ./.;
              hooks = {
                alejandra.enable = true;
                statix.enable = true;
              };
            })
            shellHook
            ;
          buildInputs = [
            alejandra
            statix
          ];
        };
    };
  };
}
