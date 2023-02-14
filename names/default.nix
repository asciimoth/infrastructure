{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.etc.naming.source = ../names;
}
