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
  #debash = pkgs.writeShellScriptBin "debash" ''
  #  export NO_DEBASH=true
  #  $1 ''${@: 2}
  #'';
in {
  home-manager.users."${constants.MainUser}" = {
    #home.file.".bashrc".text = lib.mkAfter ''
    #  # Debash!
    #  if [[ $IN_NIX_SHELL ]]; then
    #      if [[ "$NO_DEBASH" == "" ]]; then
    #          echo "debash: Loading default user shell"
    #          echo "debash: To prevent it, use 'export NO_DEBASH=true'"
    #          dshell=$(awk -F: -v user="$USER" '$1 == user {print $NF}' /etc/passwd)
    #          $dshell
    #          dcode=$?
    #          echo "debash: $dshell finished with $dcode"
    #          exit $dcode
    #      fi
    #  fi
    #  PS1="$(whoami)@$(hostname):$(pwd):\$(date) "
    #'';
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [
    distrobox
    hub
    #debash
  ];
}
