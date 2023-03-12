RIcing & other system customisation TODO

References:
- Nix/NixOS
-- My old configs
-- https://github.com/xenocorn/mynix
-- https://github.com/xenocorn/nixos_host_config
-- My snippets
--- https://gist.github.com/DomesticMoth/1943f8c8de3fc466eb64a0bca2c1d2ea
-- RuNixOs chat users
--- https://github.com/balsoft/nixos-config
--- https://github.com/cab404/homex
--- https://github.com/vyorkin/nixos-config
--- https://github.com/kanashimia/nixos-config
--- https://bitbucket.org/bzz/nixos/src/master/
-- Finded in web
--- https://github.com/rxyhn/yuki/blob/main/.github/README.md
--- https://github.com/Misterio77/nix-config
--- https://github.com/fortuneteller2k/nix-config
--- https://github.com/zoedsoupe/zoeyrinha
--- https://github.com/zoedsoupe/copper
-- My friends
--- https://github.com/cofob/nixos
-- Related projects
--- https://github.com/redcode-labs/RedNixOS
--- https://github.com/nix-community/impermanence
--- https://astro.github.io/microvm.nix/intro.html
-- Papers
--- https://dataswamp.org/~solene/2022-10-02-nixos-fail2ban.html
--- https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20
--- https://xeiaso.net/blog/paranoid-nixos-2021-07-18
--- https://elis.nu/blog/2020/05/nixos-tmpfs-as-root/
--- https://nixos.wiki/wiki/Systemd_Hardening
-- Sources about pentest on nixos 
--- https://fabaff.github.io/nix-security-box/
--- https://github.com/NixOS/nixpkgs/issues/81418
--- https://jjjollyjim.github.io/arewehackersyet/index.html
- Awesome WM
-- Others configs
--- https://config.phundrak.com/Deprecated/awesome.html
-- Libs
--- https://github.com/intrntbrn/icon_customizer
--- https://github.com/vladimir-g/awpwkb (per window layout)
--- https://github.com/intrntbrn/smart_borders
--- https://github.com/berlam/awesome-remember-geometry
--- https://github.com/lcpz/lain/tree/master/layout
--- https://github.com/pltanton/net_widgets
--- https://github.com/Elv13/tyrannical
--- https://github.com/AfoHT/taggrid
--- https://github.com/potamides/modalawesome
--- https://github.com/seberm/awesome-vim-bindings
--- https://github.com/intrntbrn/awesomewm-vim-tmux-navigator
- Hardening
-- https://static.open-scap.org/ssg-guides/ssg-rhel7-guide-C2S.html
-- https://www.stigviewer.com/stig/red_hat_enterprise_linux_7/
- Etc
-- https://grahamc.com/blog/erase-your-darlings/


Basic:
+ Remove all themes frome awesome config except one
+ Replace tmp on tmpfs with boot.cleanTmpDir = true;
+ Setup per window layout in awesome wm
+ Set micro as default editor
+ Setup locale, gpg
++ See old configs
- Replace builtin launcher with rofi
- Create scripts with notifications and shorcuts for
-- Sound +-
-- Screen light +-
- Create system bar/dashboard with eww
- At first does not make it as rich as possible
-- Add hotkey to switch it visibility
--- Also hide rofi or other launcher when showing it
-- Hide it when caling rofi or other launcher
- Firefox
-- Borrow firfox-hm-nur config from other nix users
-- Declarative plugins config
--- TreeStyleTab
--- Darkreader
--- Some adblocker
--- SponcorBlock
--- I dont care about cookies
--- Bypass Paywalls
--- Octotree
--- DecentralIEyse
--- Stylish (?)
--- OneTab (?)
--- bookmark-tree-for-tst (?)
--- grammarly (?)
- Add secrets keys managment via agenix
- Install daily soft
-- Terminal file manager (ranger?)
-- Image viever
-- Some telegram client
-- Nheko
-- Removable devices manager

Basic after installation:
- Disable auto login (?)
- Enable initrd.nix again
- Setup battary managmentd
-- See old config
-- tlp, upower
- Setup disk SMART watcher
-- See old config
- Setup xdg-desktop-portal
-- Setup my terminal file manager as system wide file picker
-- https://github.com/GermainZ/xdg-desktop-portal-termfilechooser
-- https://askubuntu.com/questions/1110803/replace-open-file-dialog-with-ranger
-- https://gist.github.com/vn-ki/e592daa2e429377a0640ba71051175e0
-- https://unix.stackexchange.com/questions/502112/use-ranger-as-my-default-file-manager-in-i3wm
- Setup CUPS & frontend for it
- Torrent client
-- Transmission backend
-- (?) Frontend

Etc:
- Clipboard notifications (clipnotify?)
- Write my own simple tui login manager
-- ncurces
-- Remember last selection
-- 3a ascii animations
- Tmp on zram
- Daemon that search system logs and show notifiction on errors / warnings
-- White & black list system based on regexp
-- Show command to search logs in notofocations
--- Should works correctly with containers

Config organisation:
- Allocate bash/fish script files to a separate directory in the root of the repo, shared to all machines
- Make configuration more structured
- Add comments

Network:
- Move network config to separate file(s)
- Write yggdrasil service with autopeering
- Write alfis service with sysd cpu & ram limits
-- Ygg only
- Patch meshname to work correctly
- Route regular dns requests through DOH/DOT
-- Rote them over tor if tor network is available
- Add OPENNIC, Alfis(local) and Meshname(Local) resolvers to related domains
- Route all dns request in system to local dns
- Drop all outgoing dns requests except requests from local dnscrypt

Awesome WM:
- Write custom theme
- Replace tag system with tyrannical & taggrid
- Create different shortcuts for walking through all workspaces an only active
- Bind laptop keyboard special keys to actions
- Write shell scripts to start multiple programs in predefinded workspaces
- Add screenlocker
-- Maybe custom lockscreen with 3a animation
- Fix firefox window overlapping other windows even in tilin mode
- Hide cursor when typing
+ Per window keyboard layout
++ Start new windows with US layout always
- Disable attaching floating windows to screen borders
- Fix focus stealing by sticky windows
- Replace focus stealing by other windows with notification about it
- Setup custom multiple screens handling
  - Maybe https://github.com/dluksza/screenful
- MacOS like >2 keyboard layouts managment
- Replace bar with minimlistic 2-3 pixel width line
-- Display all information in the form of short colored segments
- Setup vim-tmux-navigator
- Autsource library for floating windows layouts

Eww:
-- Create bar with notifications history
-- Create launcher

Firefox:
- Separate keyboard layout for each tab (or tab group maybe)
- Write plugin that replace all sites colorsheme by browser's one
- Write/found plugin that preventing to call ip/domains frome list X by page from ip/domain from list Y
- Write/found plugin that removes login via third-party resources buttons from pages
- Write plugin that hides builtin tab bar and show tree-style-tab when windodw is more then X pixels wide and otherwise does the opposite

My colorscheme managment system
- ?

Erase your darlings:
- ?

Audio:
- Mpd
-- Write custom sheduler
- Write sound sources managment system
-- All sound sources in the system form a stack
-- Only the source that is at the top of the stack is played (with a few exceptions)
--- All stack changes should trigger notifications
-- When a new source appears, it is placed at the top of the stack
-- When the source is not at the top of the stack it is paused or muted
-- Special rules may be described that define
--- Which of the sources should not be managed by this system
--- Which sources should be muted and which should be paused
--- etc
-- Write tui and eww frontends to it

Security:
- Set default umask to 027
- Restrict users to network interfaces access
-- https://dataswamp.org/~solene/2021-12-20-linux-forbid-user-except-vpn.html
- opensnitch
- Patch docker & docker relaited soft to work in separated namespace
-- See Mo's recomendations
- Wrap distrobox to nixos.container
- firejail / bubblewrap
-- https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html#_Enable_this_on_NixOS
-- Write owerlays for programs in nixpkjs with builtin wrapping
- Add honeypot sysytem into system nixos containers
- Use xpra / xephyr / other x11 proxy inside containers
- Move secutity kernel params from my old config
-- Ad comments
- Setup polkit
- Setup AppArmor rules
- Write service that collect all security info about system
-- Show dashboard
-- Notfications about security issues
-- Sources
--- https://github.com/flyingcircusio/vulnix
--- fwupdmgr security
--- systemd-analyze security
--- https://cisofy.com/lynis/
--- https://www.ossec.net
-- Malware scaners
--- YARA & Co (of cource)
--- http://www.chkrootkit.org/
--- rkhunter
- Alarmist service
-- On start mount all vfat filesystems on plugged USB disks in ro mode
-- Search files with definded pathes and hashes on them
-- Remember all devices where files was founded
-- Call a trigger script when one of remembered devices was unpluged and shut down system with RAM clearing
-- Remembered devices list may be regenerated by signal from userspace
- Write custom password asking cli tool
-- Random input remapping
- Fingerprint password manager
-- Input user password on fingerptint scanner signal
- Hide proc with hidepid
-- https://linux-audit.com/linux-system-hardening-adding-hidepid-to-proc/
- Write overlays to restrict privileges for sysd services
-- Sources
--- https://github.com/NixOS/nixpkgs/pull/104944/files
--- https://github.com/mautrix/docs/pull/18/files
--- https://github.com/NixOS/nixpkgs/pull/93305/files
--- https://github.com/thelounge/thelounge-deb/pull/78
- Disable DCCP and SCTP (maybe prevent kernel modules being loaded)
-- See https://static.open-scap.org/ssg-guides/ssg-rhel7-guide-C2S.html#xccdf_org.ssgproject.content_rule_kernel_module_dccp_disabled
-- See https://static.open-scap.org/ssg-guides/ssg-rhel7-guide-C2S.html#xccdf_org.ssgproject.content_rule_kernel_module_sctp_disabled
- Setup PAM
-- https://github.com/trimstray/the-practical-linux-hardening-guide/wiki/PAM-Module
- Do something with a bunch of files and directories without a user or group
-- find / -nouser && find / -nogroup && find / -perm -o+w && df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null
- Walk throw those sources and implement recomendations from them
