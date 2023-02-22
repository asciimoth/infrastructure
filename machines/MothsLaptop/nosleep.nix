{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Force disable sleep/hibenation/suspendion
  services.logind.lidSwitch = lib.mkForce "ignore";
  systemd.targets = {
    sleep.enable = lib.mkForce false;
    suspend.enable = lib.mkForce false;
    hibernate.enable = lib.mkForce false;
    hybrid-sleep.enable = lib.mkForce false;
  };
  boot.kernelParams = ["nohibernate"];
}
