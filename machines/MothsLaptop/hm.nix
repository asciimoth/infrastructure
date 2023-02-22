{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.moth.home.stateVersion = config.system.stateVersion;
  home-manager.users.root.home.stateVersion = config.system.stateVersion;
}
