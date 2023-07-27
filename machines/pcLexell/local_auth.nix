# Infrastructure config by ASCIIMoth
#
# To the extent possible under law, the person who associated CC0 with
# this work has waived all copyright and related or neighboring rights
# to it.
#
# You should have received a copy of the CC0 legalcode along with this
# work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  constants = import ./constants.nix;
in {

  environment.systemPackages = with pkgs; [
    pam_u2f
  ];
  environment.etc."chownd/pam_yubikey_${constants.MainUser}" = {
    text="root /home/${constants.MainUser}/.config/Yubico/u2f_keys";
    mode = "744";
  };
  home-manager.users."${constants.MainUser}" = {
    home.file.".config/Yubico/u2f_keys".text="moth:gXHGuXRnsYbUF1BfKb5xSC7r+i+uAmbBjfewm0vI/OFNk+TJrHCdbFvI3g2+hj4NLo75/6QUJJ2oasdxeU7uDQ==,79Hf8fzAhAl2ZyDlSJXc8rmfHBstAVxMK8g9KuXrsLa0eahM8n0g9pPGLYXWL3egZpfYhI6MKVnDZfTPfXLEJw==,es256,+presencemoth:MRbRS5FudZJMlORvvOAzxXDjcvaMPWirRifxDLwc5W5rscH+7buQOyvFq7zYx2BkIa5alzjX+bukxbaP28xEIQ==,tVu11SR+plTarazBCkSr/MwKQi+486+oC8warrXmqS6maHTt7wx9iVuG4VkDUGFChlvj6TcA0rTO6OMcsa0wzA==,es256,+presence";
  };
  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };
  #home-manager.users.moth = {lib, ...}: { 
  #  home.activation = {
  #    pamActivation = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #      echo "AAA"
  #    '';
  #  };
  #};
}
