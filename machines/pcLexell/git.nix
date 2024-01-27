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
}: {
  environment.systemPackages = with pkgs; [
    git
    hub
  ];

  environment.shellAliases = {
    poop = ''git push origin "$(git branch | grep "\*" | cut -d " " -f2)"'';
  };

  environment.etc.gitignore.text = ''
    # Windows executable files; For crosscompilation cases
    *.exe

    # Local files
    local
    local/
    env
    .env
    .sublime-workspace
    .sublime-project
    *.sublime-workspace
    *.sublime-project
    *.sublime-workspace*
    *.sublime-project*
  '';
  environment.etc.gitconfig.text = ''
    [http]
    	proxy =
    [user]
    	name = AsciiMoth
    	email = ascii@moth.contact
    	signingkey = C3A35C9F
    [core]
    	excludesfile = /etc/gitignore
    	editor = micro
    [init]
    	defaultBranch = master
    [pull]
      rebase = false
    [commit]
    	gpgsign = true
    [tag]
    	forceSignAnnotated = true
  '';
}
