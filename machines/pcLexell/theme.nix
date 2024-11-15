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
  theme = "${pkgs.base16-schemes}/share/themes/${constants.theme}.yaml";
  jsonTheme = pkgs.runCommand "yml2json" {} ''
    ${pkgs.yq}/bin/yq -Mc '. + .palette' ${theme} > $out
  '';
  yamlTheme = pkgs.runCommand "yml2stylixYml" {} ''
    ${pkgs.yq}/bin/yq -Mcy '. + .palette' ${theme} > $out
  '';
  terminalThemeBuilderPy = pkgs.writeText "terminalThemeBuilder.py" (builtins.readFile ./terminalThemeBuilder.py);
  fishThemeTemplate = pkgs.writeText "fishThemeTemplate" (builtins.readFile ./fish.mustache);
  terminalTheme = pkgs.runCommand "terminalThemeBuilder" {} ''
    mkdir $out
    ${pkgs.python312}/bin/python ${terminalThemeBuilderPy} ${jsonTheme} 0x05 ${fishThemeTemplate} $out/theme.fish
  '';
  #wallpaper = pkgs.runCommand "image.png" {} ''
  #  COLOR=$(${pkgs.yq}/bin/yq -r .base00 ${theme})
  #  COLOR="#"$COLOR
  #  ${pkgs.imagemagick}/bin/magick convert -size 1x1 xc:$COLOR $out
  #'';
  wallpaper = config.lib.stylix.pixel "base0A";
  nfonts = pkgs.nerdfonts.override {fonts = ["FiraCode" "FiraMono"];};
in {
  fonts = {
    enableDefaultPackages = true;
    #fontDir.enable = true; #Will force recompile some programs
    packages = with pkgs; [
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
    # TODO: replace with https://github.com/danth/stylix/blob/master/stylix/pixel.nix
    image = wallpaper;
    #image = config.lib.stylix.pixel "base0A";
    base16Scheme = theme;
    #base16Scheme = theme;
    polarity = "dark";
    fonts = {};
  };
  environment.etc = {
    "walpaperpath".text = "${wallpaper}";
    "themespath".text = "${pkgs.base16-schemes}/share/themes/";
    "b16theme.yaml".source = yamlTheme;
    "theme.fish".source = "${terminalTheme}/theme.fish";
  };
  home-manager.users."${constants.MainUser}".home.file = {
    ".b16theme.yaml".source = yamlTheme;
    ".b16theme.json".source = jsonTheme;
  };
}
