let
  ConfigRoot = "/etc/infrastructure";
  MainUser = "moth";
in {
  inherit
    MainUser
    ConfigRoot;
}
