{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    git
  ];

  environment.etc.gitignore.text = ''
    # Windows executable files; For crosscompilation cases
    *.exe

    # Local files
    local
    local/
    env
    .env
  '';
  environment.etc.gitconfig.text = ''
    [http]
    	proxy =
    [user]
    	name = John Doe
    	email =
    [core]
    	excludesfile = /etc/gitignore
    	editor = nano
    [init]
    	defaultBranch = master
  '';
}
