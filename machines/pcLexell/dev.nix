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
  codewrap = pkgs.writeShellScriptBin "code-wrap" (builtins.readFile ./code-wrap.sh);
  #https://stackoverflow.com/a/67799667
  ide = pkgs.writers.writePython3Bin "ide" {} (builtins.readFile ./ide.py);
  ide-desktop = pkgs.makeDesktopItem {
    name = "IDE";
    desktopName = "IDE";
    exec = "${ide}/bin/ide";
    terminal = false;
  };
in {
  home-manager.users."${constants.MainUser}" = {
    programs = {
      direnv = {
        enable = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      vscode = {
        # https://mynixos.com/home-manager/options/programs.vscode
        enable = true;
        package = pkgs.vscodium;
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
        #extensions = [];
        #extensions = extensions;
        extensions = with pkgs.vscode-extensions;
          [
            catppuccin.catppuccin-vsc-icons
            ms-ceintl.vscode-language-pack-ru
            # https://github.com/ChristianKohler/PathIntellisense
            #stephlin.vscode-tmux-keybinding
            #jamesyang999.vscode-emacs-minimum
            #github.vscode-pull-request-github
            bierner.markdown-mermaid
            #yzhang.markdown-all-in-one
            bierner.markdown-checkbox
            #shd101wyy.markdown-preview-enhanced
            #ms-vsliveshare.vsliveshare
            #ms-vscode.live-server
            #ms-vscode-remote.remote-ssh
            #redhat.vscode-yaml
            #bungcip.better-toml
            tamasfe.even-better-toml
            #usernamehw.errorlens
            #bbenoist.nix
            #arrterian.nix-env-selector
            mkhl.direnv
            jnoortheen.nix-ide
            #kamadorueda.alejandra
            #kahole.magit
            #mhutchie.git-graph
            #waderyan.gitblame
            #codezombiech.gitignore
            #donjayamanne.githistory
            #skyapps.fish-vscode
            #bmalehorn.vscode-fish
            #mads-hartmann.bash-ide-vscode
            sumneko.lua
            #skellock.just
            #ziglang.vscode-zig
            #tiehuis.zig
            #mattn.lisp
            #golang.go
            #jock.svg
            #tomoki1207.pdf
            #github.copilot
            #serayuzgur.crates
            #nvarner.typst-lsp
            #mgt19937.typst-preview
            #humao.rest-client
            #bodil.file-browser
            #bierner.emojisense
            #bierner.markdown-emoji
            #wmaurer.change-case
            #irongeek.vscode-env
            #eugleo.magic-racket
            #rust-lang.rust-analyzer
            #graphql.vscode-graphql-syntax
            #asciidoctor.asciidoctor-vscode
            #theangryepicbanana.language-pascal
            ms-python.python
            ms-python.vscode-pylance
          ]
          ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            #https://marketplace.visualstudio.com/items?itemName=yoshi389111.markdown-table-rainbow
            {
              name = "vscode-custom-css";
              publisher = "be5invis";
              version = "7.2.1";
              sha256 = "sha256-vNEVfDR4hGFXoElGqSNcmCyGi0vxN9gvPO9xkMhEfu8=";
              # https://github.com/be5invis/vscode-custom-css
              # https://github.com/robb0wen/synthwave-vscode/blob/master/synthwave84.css
              # https://gist.github.com/js2me/dfccef039e1ce727eafce4145c0bb4cb
            }
            {
              name = "mermaid-markdown-syntax-highlighting";
              publisher = "bpruitt-goddard";
              version = "1.6.0";
              sha256 = "sha256-XYGQk5zCStBzHVW0Kqs44vI0SyPx20ve3dtegRScc5M=";
            }
            #{
            #  name = "";
            #  publisher = "";
            #  version = "";
            #  #sha256 = "";
            #}
            {
              name = "graphviz-interactive-preview";
              publisher = "tintinweb";
              version = "0.3.5";
              sha256 = "sha256-5A+RXGGVF/LY2IQ9jDvmS2/G6/T9BBqDPIx+7SXNeTo=";
            }
            #{
            #  name = "nix-extension-pack";
            #  publisher = "pinage404";
            #  version = "3.0.0";
            #  sha256 = "sha256-cWXd6AlyxBroZF+cXZzzWZbYPDuOqwCZIK67cEP5sNk=";
            #}
          ];
        # https://code.visualstudio.com/docs/getstarted/tips-and-tricks#_tune-your-settings
        userSettings = {
          # [Theming]
          # TODO: mo
          "vscode_custom_css.imports" = [""];
          #https://github.com/tonsky/FiraCode/wiki/VS-Code-Instructions
          "editor.fontFamily" = lib.mkForce "FiraCode Nerd Font Mono Ret";
          "editor.fontLigatures" = true;
          "terminal.integrated.fontFamily" = lib.mkForce "FiraCode Nerd Font Mono Ret";
          "workbench.iconTheme" = "catppuccin-mocha";
          # [Minification]
          #"workbench.editor.tabActionCloseVisibility" = false;
          #"workbench.activityBar.location" = "hidden";
          #"window.menuBarVisibility" = "hidden"; # Top bar with "File Edit Selection ..."
          #"workbench.layoutControl.enabled" = false;
          #"workbench.layoutControl.type" = "menu";
          #"editor.scrollbar.verticalScrollbarSize" = 3;
          #"editor.scrollbar.horizontalScrollbarSize" = 3;
          #"editor.minimap.enabled" = false;
          ##"window.title" = " ";
          #"window.titleBarStyle" = "native";
          #"workbench.sideBar.location" = "right";
          "breadcrumbs.enabled" = false;
          "breadcrumbs.icons" = false;
          #"editor.lightbulb.enabled" = false;
          #"editor.overviewRulerBorder" = false;
          ##Explorer ctrl+shift+E
          ##Source Control ctrl+shift+G
          ##Extensions ctrl+shift+X
          #"workbench.editor.pinnedTabSizing" = "compact";
          #"workbench.editor.tabSizing" = "shrink";
          #"editor.glyphMargin" = false;
          #"workbench.editor.showTabs" = "single";
          "editor.guides.indentation" = false;
          "editor.stickyScroll.enabled" = false;
          "workbench.editor.enablePreview" = false;
          "workbench.editor.enablePreviewFromQuickOpen" = false;
          "terminal.integrated.stickyScroll.enabled" = true;
          # [Nix]
          "nix.serverSettings" = {
            # settings for 'nixd' LSP
            "nixd" = {
              "eval" = {
                # stuff
              };
              "formatting" = {
                "command" = "nixpkgs-fmt";
              };
              "options" = {
                "enable" = true;
                "target" = {
                  # tweak arguments here
                  "args" = [];
                  # NixOS options
                  "installable" = "<flakeref>#nixosConfigurations.<name>.options";
                  # Flake-parts options
                  # "installable": "<flakeref>#debug.options"
                  # Home-manager options
                  # "installable": "<flakeref>#homeConfigurations.<name>.options"
                };
              };
            };
          };
          # [Etc]
          "terminal.integrated.tabs.enabled" = true;
          "graphviz-interactive-preview.renderLockAdditionalTimeout" = -1;
          "explorer.confirmDelete" = false;
          "workbench.startupEditor" = "none";
          "telemetry.telemetryLevel" = "off";
          "telemetry.enableCrashReporter" = false;
          "telemetry.enableTelemetry" = true;
          "editor.emptySelectionClipboard" = false;
          "editor.insertSpaces" = true;
          "editor.renderWhitespace" = "trailing"; # boundary
          "editor.rulers" = [
            80
            {
              "column" = 100;
              "color" = "#997777";
            }
          ];
          "editor.unicodeHighlight.allowedCharacters" = {
            "у" = true;
          };
        };
      };
    };
  };
  environment = {
    systemPackages = with pkgs; [
      distrobox
      hub
      codewrap
      ide
      ide-desktop
      nixpkgs-fmt
      nixd
      vimgolf
    ];
    shellAliases = {
      code = "codium";
    };
  };
}
