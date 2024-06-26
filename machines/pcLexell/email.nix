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
  read-or-value = pkgs.writeShellScriptBin "read-or-value" ''
    RET=$(cat $1 2> /dev/null)
    STATUS=$?
    if [ $STATUS -ne 0 ]; then
        RET=$2
    fi
    echo "$RET"
  '';
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
    ISSYNC=$(${pkgs.coreutils-full}/bin/cat ~/.config/himalaya/config.toml | ${pkgs.toml2json}/bin/toml2json | ${pkgs.jq}/bin/jq '."ASCII Moth".sync')
    if [[ "$s1" == "$s2" ]]; then
      ${pkgs.himalaya}/bin/himalaya list -o json -f Inbox | ${pkgs.jq}/bin/jq '[.[] | select(.flags | index("Seen") | not)] | length'
    else
      ${pkgs.himalaya}/bin/himalaya --output json search --folder Inbox "NOT SEEN" | ${pkgs.jq}/bin/jq -r '.|length'
    fi
  '';
  notifybyname = pkgs.writeShellScriptBin "notify-by-name" (builtins.readFile ./notify-by-name.sh);
  new-emails-notify = pkgs.writeShellScriptBin "new-emails-notify" ''
    COUNT=$(/nix/store/4qq7gqzppvxn05g4gmzcgrxbqqzv0p0j-new-emails-count/bin/new-emails-count)
    LATESTIDFILE="/tmp/$USER-email-notifications-latest-id"
    LATESTUNREADID=$(${pkgs.himalaya}/bin/himalaya --output json search -f "Inbox" "NOT SEEN" | ${pkgs.jq}/bin/jq -r ".[0].id")
    SAVED=$(${read-or-value}/bin/read-or-value $LATESTIDFILE "0")
    if [ "$SAVED" -ge "$LATESTUNREADID" ]; then
        exit 0
    fi
    if [ "$COUNT" != "0" ] ; then
      /nix/store/r8fcc765iy69gas7fdfjf29jbly4rh80-notify-by-name/bin/notify-by-name -n NEW_EMAILS -u critical -t 1800 -b "📫 $COUNT unread emails into inbox" >/dev/null 2>&1
      sleep 0.1
      /nix/store/r8fcc765iy69gas7fdfjf29jbly4rh80-notify-by-name/bin/notify-by-name -n NEW_EMAILS -u normal -t 50000 -b "📫 $COUNT unread emails into inbox" >/dev/null 2>&1
      EXT=$?
      if [ "$EXT" == "0" ] ; then
        echo "$LATESTUNREADID" > $LATESTIDFILE
      fi
    else
      /nix/store/r8fcc765iy69gas7fdfjf29jbly4rh80-notify-by-name/bin/notify-by-name -n NEW_EMAILS -u normal -t 1 -b " " >/dev/null 2>&1
    fi
  '';
  watchcmd = pkgs.writeShellScriptBin "watchcmd" ''
    ${pkgs.himalaya}/bin/himalaya --account "${constants.Nicknames.Full}" account sync
    ${new-emails-notify}/bin/new-emails-notify
  '';
  gui-waiter = pkgs.writeShellScriptBin "gui-waiter" ''
    while true; do
      ${pkgs.inotify-tools}/bin/inotifywait -e create,moved_to,attrib --include 'graphical-notifyer' /tmp
      sleep 1
      ${new-emails-notify}/bin/new-emails-notify
    done
  '';
in {
  environment.systemPackages = with pkgs; [
    new-emails-count
    new-emails-notify
    thunderbird
    #kmail
  ];
  environment.shellAliases."email" = ''fish -C "source /etc/email-shell.fish"'';
  environment.etc."email-shell.fish".text = ''
    set -x ASCIIMOTH_PASSWORD (pass show email/disroot.org/asciimoth | head -1 | cut -d' ' -f2)
  '';
  home-manager.users."${constants.MainUser}" = {
    programs = {
      himalaya = {
        enable = true;
        settings = let
          maildir = "/home/${constants.MainUser}/.mail";
        in {
          email-listing-page-size = 0;
          downloads-dir = "/home/${constants.MainUser}/Downloads/email";
          email-listing-datetime-local-tz = true;
          email-listing-datetime-fmt = "%H:%M %d.%m.%Y";
          #email-reading-verify-cmd = "gpg --verify -q";
          #email-reading-decrypt-cmd = "gpg -dq";
          #email-writing-sign-cmd = "gpg -o - -saq";
          #email-writing-encrypt-cmd = "gpg -o - -eqar <recipient>";
          "${constants.Nicknames.Full}" = let
            login = "${constants.Nicknames.Lower}";
            host = "disroot.org";
            passcmd = ''${ors}/bin/OR "echo \$ASCIIMOTH_PASSWORD"  "${pkgs.pass}/bin/pass show email/disroot.org/asciimoth | head -1 | cut -d' ' -f2"'';
          in {
            email = "${constants.Email}";
            display-name = "ASCII Moth";
            default = true;
            signature = ''
              ASCII Moth
              ^0w0^
            '';
            sync = false;
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
              "${watchcmd}/bin/watchcmd"
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
    enable = true;
    #wantedBy = ["default.target"];
    wantedBy = ["graphical-session.target"];
    after = ["graphical-session.target"];
    description = "Load email updates via imap and himalaya";
    serviceConfig = {
      #Type = "oneshot";
      User = "root";
      ExecStart = toString (pkgs.writeShellScript "imap-loader" ''
        export ASCIIMOTH_PASSWORD=$(${pkgs.coreutils-full}/bin/cat /etc/emailpassword)
        export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
        ${pkgs.sudo}/bin/sudo --preserve-env=ASCIIMOTH_PASSWORD --preserve-env=DBUS_SESSION_BUS_ADDRESS -i -u moth bash << EOF
        ${gui-waiter}/bin/gui-waiter &
        ${pkgs.himalaya}/bin/himalaya watch
        EOF
      '');
      Restart = "always";
      RestartSec = 10;
    };
  };
}
