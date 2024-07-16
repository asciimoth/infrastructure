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
  programs.ssh = {
    knownHostsFiles = [
      ../../known_hosts
    ];
    extraConfig = ''
      Host hearty-health
          User toast
      Host nas
          HostName pinas
          IdentityFile /home/${constants.MainUser}/.ssh/pinas_id
          IdentitiesOnly yes
    '';
  };
  environment.systemPackages = with pkgs; [sshfs];
  #fileSystems."/home/${constants.MainUser}/nas_priv" = {
  #  device = "sftp${constants.MainUser}@pinas:/${constants.MainUser}";
  #  fsType = "sshfs";
  #  options =
  #    [ # Filesystem options
  #      "allow_other"          # for non-root access
  #      "default_permissions"
  #      "user"
  #      "idmap=user"
  #      "follow_symlinks"
  #      "uid=1000"
  #      "_netdev"              # this is a network fs
  #      "x-systemd.automount"  # mount on demand
  #     # SSH options
  #      "reconnect"              # handle connection drops
  #      "ServerAliveInterval=15" # keep connections alive
  #      "IdentityFile=/etc/pinas_id"
  #      #"subdir=${constants.MainUser}"
  #    ];
  #};
  #fileSystems."/home/${constants.MainUser}/nas_shared" = {
  #  device = "sftpshared@pinas:/shared";
  #  fsType = "sshfs";
  #  options =
  #    [ # Filesystem options
  #      "allow_other"          # for non-root access
  #      "default_permissions"
  #      "user"
  #      "idmap=user"
  #      "follow_symlinks"
  #      "uid=1000"
  #      "_netdev"              # this is a network fs
  #      "x-systemd.automount"  # mount on demand
  #     # SSH options
  #      "reconnect"              # handle connection drops
  #      "ServerAliveInterval=15" # keep connections alive
  #      "IdentityFile=/etc/pinas_id"
  #      #"subdir=${constants.MainUser}"
  #    ];
  #};
}
