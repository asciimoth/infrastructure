{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [];
  users.users.moth = {
    #openssh.authorizedKeys.keys = [];
  };
  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    kbdInteractiveAuthentication = lib.mkForce true;
    permitRootLogin = lib.mkForce "yes";
  };
}
