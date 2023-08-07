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
  ors = pkgs.writeShellScriptBin "OR" ''
    # Return output of first command with non empty stdout
    # Usage:
    # OR COMMAND1 COMMAND2 COMMANDN
    for ___CMD in "$@"
    do
        RESULT=$(eval $___CMD)
        if [ -n "$RESULT" ]; then
            echo "$RESULT"
            exit 0
        fi
    done
  '';
  new-emails-count = pkgs.writeShellScriptBin "new-emails-count" ''
    ${pkgs.himalaya}/bin/himalaya list -o json -f Inbox | ${pkgs.jq}/bin/jq '[.[] | select(.flags | index("Seen") | not)] | length'
  '';
  notifybyname = pkgs.writeShellScriptBin "notify-by-name" (builtins.readFile ./notify-by-name.sh);
  new-emails-notify = pkgs.writeShellScriptBin "new-emails-notify" ''
    COUNT=$(${new-emails-count}/bin/new-emails-count)
    if [ "$COUNT" != "0" ] ; then
      ${notifybyname}/bin/notify-by-name -n NEW_EMAILS -u critical -t 1800 -b "📫 $COUNT unread emails into inbox" >/dev/null 2>&1
      sleep 0.1
      ${notifybyname}/bin/notify-by-name -n NEW_EMAILS -u normal -t 4000 -b "📫 $COUNT unread emails into inbox" >/dev/null 2>&1
    fi
  '';
  runer = pkgs.writeShellScriptBin "runer" ''
    export ASCIIMOTH_PASSWORD=$(${pkgs.coreutils-full}/bin/cat /etc/emailpassword)
    export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
    cd /home/${constants.MainUser}
    ${pkgs.sudo}/bin/sudo -EH --user ${constants.MainUser} ${pkgs.himalaya}/bin/himalaya watch
    #${pkgs.sudo}/bin/sudo -EH --user ${constants.MainUser} ${pkgs.bash}/bin/bash
  '';
in {
  environment.systemPackages = with pkgs; [
    new-emails-count
    new-emails-notify
    runer
  ];
  home-manager.users."${constants.MainUser}".programs = {
    himalaya = {
      enable = true;
      settings = let
        maildir = "/home/${constants.MainUser}/.mail";
      in {
        email-listing-page-size = 0;
        "${constants.Nicknames.Full}" = let
          login = "${constants.Nicknames.Lower}";
          host = "disroot.org";
          passcmd = ''${ors}/bin/OR "echo \$ASCIIMOTH_PASSWORD"  "${pkgs.pass}/bin/pass show email/disroot.org/asciimoth | head -1 | cut -d' ' -f2"'';
        in {
          email = "${constants.Email}";
          default = true;
          sync = true;
          sync-dir = "${maildir}/${host}/${login}";
          #sync-folders-strategy.exclude = ["Junk" "Trash"];
          # Backend
          backend = "imap";
          imap-host = "${host}";
          imap-port = 993;
          imap-login = "${login}@${host}";
          imap-auth = "passwd";
          imap-passwd = {cmd = passcmd;};
          imap-ssl = true;
          imap-starttls = false;
          imap-watch-cmds = [
            ''${pkgs.himalaya}/bin/himalaya --account "${constants.Nicknames.Full}" account sync''"echo 'Something changed'"
            ''${new-emails-notify}/bin/new-emails-notify''
          ];
          #imap-notify-cmd = ''notify-desktop "Nem email from <sender>" "<subject>"'';
          imap-notify-query = "NOT SEEN";
          # Sender
          sender = "smtp";
          smtp-host = "${host}";
          smtp-port = 465;
          smtp-login = "${login}@${host}";
          smtp-auth = "passwd";
          smtp-passwd = {cmd = passcmd;};
          smtp-ssl = true;
          smtp-starttls = false;
        };
      };
    };
    thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
      settings = {
        "privacy.donottrackheader.enabled" = true;
      };
    };
  };
  sops.secrets."email-asciimoth-key" = {
    path = "/etc/emailpassword";
    owner = "root";
    group = "root";
    mode = "600";
    sopsFile = ../../secrets/email-asciimoth-key.txt;
    format = "binary";
  };
  systemd.services.imap-loader = {
    enable = false;
    #wantedBy = ["default.target"];
    wantedBy = ["network.target"];
    after = ["network.target"];
    description = "Load email updates via imap and himalaya";
    serviceConfig = {
      User = "root";
      ExecStart = "${runer}/bin/runer";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
