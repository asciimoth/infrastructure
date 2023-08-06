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
in {
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
          passcmd = ''OR "echo \$ASCIIMOTH_PASSWORD"  "pass show email/disroot.org/asciimoth | head -1 | cut -d' ' -f2"'';
        in {
          email = "${constants.Email}";
          default = true;
          sync = true;
          sync-dir = "${maildir}/${host}/${login}";
          sync-folders-strategy.exclude = ["Junk" "Trash"];
          # Backend
          backend = "imap";
          imap-host = "${host}";
          imap-port = 993;
          imap-login = "${login}@${host}";
          imap-auth = "passwd";
          imap-passwd = {
            cmd = passcmd;
          };
          imap-ssl = true;
          imap-starttls = false;
          # Sender
          sender = "smtp";
          smtp-host = "${host}";
          smtp-port = 465;
          smtp-login = "${login}@${host}";
          smtp-auth = "passwd";
          smtp-passwd = {
            cmd = ["pass show email/${host}/${login}" "head -1" "cut -d' ' -f2"];
          };
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
}
