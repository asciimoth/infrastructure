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
  theme = "${pkgs.base16-schemes}/share/themes/catppuccin.yaml";
  #theme = pkgs.fetchurl {
  #  url = "https://raw.githubusercontent.com/tined-theming/base16/main/catppuccin-latte.yaml";
  #};
  wallpaper = pkgs.runCommand "image.png" {} ''
        COLOR=$(${pkgs.yq}/bin/yq -r .base00 ${theme})
        COLOR="#"$COLOR
        ${pkgs.imagemagick}/bin/magick convert -size 1x1 xc:$COLOR $out
  '';
  nfonts = (pkgs.nerdfonts.override {fonts = ["FiraCode" "FiraMono"];});
in {
  fonts = {
    enableDefaultFonts = true;
    #fontDir.enable = true; #Will force recompile some programs
    fonts = with pkgs; [
      nfonts
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["FiraCode Nerd Font Serif"];
        sansSerif = ["FiraCode Nerd Font Mono"];
        monospace = ["FiraCode Nerd Font Mono"];
      };
    };
  };
  stylix = {
    image = wallpaper;
    base16Scheme = theme;
  };
  environment.etc = {
    "walpaperpath".text = "${wallpaper}";
    "themespath".text = "${pkgs.base16-schemes}/share/themes/";
    "b16theme.yaml".source = theme;
  };
  home-manager.users."${constants.MainUser}".home.file = {
    ".b16theme.yaml".source = theme;
  };
}
