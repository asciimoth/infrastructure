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
  oneshot-chromium = pkgs.writeShellScriptBin "oneshot-chromium" ''
    # Run ungoogled-chromium in isolated container
    # and clean all it data after exit
    # It is intended for one-time logins to services.
    # Use it where the tor browser is not suitable because of cloudflare and so on
    RND=$(openssl rand -hex 30)
    TMPDIR="/tmp/oneshot-chromium-$RND"
    mkdir $TMPDIR
    mkdir -p "$TMPDIR/.config/chromium"
    mkdir -p "$TMPDIR/.cache/chromium"
    mkdir -p "$HOME/.config/chromium"
    mkdir -p "$HOME/.cache/chromium"
    echo "Tmp dir: $TMPDIR"
    ${pkgs.boxxy}/bin/boxxy --no-config --rule "$HOME/.cache/chromium:$TMPDIR/.cache/chromium" --rule "$HOME/.config/chromium:$TMPDIR/.config/chromium" ${pkgs.ungoogled-chromium}/bin/chromium
    rm -rf $TMPDIR
  '';
  oneshot-chromium-desktop = pkgs.makeDesktopItem {
    name = "Chromium";
    desktopName = "Chromium";
    exec = "${oneshot-chromium}/bin/oneshot-chromium";
    terminal = false;
  };
in {
  environment.systemPackages = with pkgs; [
    oneshot-chromium
    oneshot-chromium-desktop
  ];
}
