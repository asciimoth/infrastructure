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
    git
  ];

  environment.shellAliases = {
    poop = ''git push origin "$(git branch | grep "\*" | cut -d " " -f2)"'';
  };

  environment.etc.gitignore.text = ''
    # Example: windows executable files; For crosscompilation cases
    #*.exe

    # Local files
    local
    local/

    # Env files
    env
    .env

    # SublimeText files
    .sublime-workspace
    .sublime-project
    *.sublime-workspace
    *.sublime-project
    *.sublime-workspace*
    *.sublime-project*

    # VScode(ium)
    .vscode
    .codium
    .vscodium
  '';
  environment.etc.gitconfig.text = ''
    [http]
    	proxy =
    [user]
    	name = ${constants.Nicknames.Git}
    	email = ${constants.Email}
    [core]
    	excludesfile = /etc/gitignore
    [init]
    	defaultBranch = master
    [pull]
      rebase = false
  '';
}
