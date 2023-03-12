# Infrastructure config by DomesticMoth
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
  fileSystems = {
    "/".options = ["noatime" "nodiratime"];
    #"/tmp" = {
    #  device = "tmpfs";
    #  fsType = "tmpfs";
    #  options = [
    #    "noatime"
    #    "nodiratime"
    #    #"noexec" # Exec permition need for nix pkgs build
    #    "nosuid"
    #    "nodev"
    #    "mode=1777"
    #  ];
    #};
  };

  #nix.settings.allowed-users = lib.mkForce [ "root" ];

  system.autoUpgrade.enable = lib.mkForce false;

  environment = {
    defaultPackages = lib.mkForce [];
    systemPackages = with pkgs; [
      #clamav
      #haveged
      firejail
    ];
    extraInit = ''
      umask 027
    '';
    etc = {
      ssh_banner.text = "Pls dont hack";
      tty_banner.text = "Pls dont hack";
    };
  };

  hardware.enableRedistributableFirmware = true;

  services = {
    fwupd.enable = true; # Frimware updates
    haveged.enable = true; # Entropy daemon
    chrony.enable = true; # Time sync
    openssh = {
      passwordAuthentication = lib.mkForce false;
      allowSFTP = false;
      kbdInteractiveAuthentication = false;
      # C2S/CIS: CCE-27471-2 (High), CCE-27082-7 (Medium),
      # CCE-27433-2 (Medium), CCE-27314-4 (Medium),
      # CCE-27455-5 (Medium), CCE-27363-1 (Medium),
      # CCE-27320-1 (High), CCE-27377-1 (Medium),
      # CCE-80645-5 (Medium), CCE-27295-5 (High).
      # CCE-80226-4 (High), CCE-27413-4 (Medium),
      # CCE-27445-6 (Medium)
      extraConfig = ''
        PermitRootLogin no
        AllowTcpForwarding yes
        X11Forwarding yes
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
        PermitEmptyPasswords no
        ClientAliveCountMax 0
        ClientAliveInterval 300
        Banner /etc/ssh_banner
        MACs hmac-sha2-512,hmac-sha2-256,hmac-sha1
        Ciphers aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,aes192-cbc,aes256-cbc
        PermitUserEnvironment no
        Protocol 2
        IgnoreRhosts yes
        LogLevel INFO
        HostbasedAuthentication no
        MaxAuthTries 4
      '';
    };
    #clamav = {
    #	daemon.enable = true;
    #	updater.enable = true;
    #};
  };

  security = {
    sudo.execWheelOnly = lib.mkForce true;
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        # Dark magik
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
    chromiumSuidSandbox.enable = lib.mkForce true;
    #allowSimultaneousMultithreading = false;
    #allowUserNamespaces = false;
    #lockKernelModules = false;
    # Prevent replacing the runing kernel image
    protectKernelImage = lib.mkForce true;
    forcePageTableIsolation = lib.mkForce true;
    # Reduce performance!
    virtualisation.flushL1DataCache = lib.mkForce "always";
  };

  # Disable coredump that could be exploited later
  # and also slow down the system when something crash
  systemd.coredump.enable = lib.mkForce false;

  programs = {
    ssh.askPassword = ""; # Ask with CLI but not GUI dialog
    gnupg.agent = {
      pinentryFlavor = "curses";
      #enableSSHSupport = true;
    };
  };

  boot = {
    cleanTmpDir = true;
    kernelParams = [
      "lockdown=confidentiality"
      "page_poison=1"
      "page_alloc.shuffle=1"
    ];
    kernel.sysctl = {
      #"max_user_watches" = 524288;
      "kernel.dmesg_restrict" = true;
      "kernel.unprivileged_bpf_disabled" = true;
      #"kernel.unprivileged_userns_clone" = false;
      "kernel.kexec_load_disabled" = true;
      "kernel.sysrq" = 4;
      "net.core.bpf_jit_harden" = true;
      "vm.swappiness" = 1;
      "vm.unprivileged_userfaultfd" = false;
      "dev.tty.ldisc_autoload" = false;
      "kernel.yama.ptrace_scope" = lib.mkOverride 500 1; # Allow ptrace only for parent->child proc
      "kernel.kptr_restrict" = lib.mkOverride 500 2; # Hide kptrs even for processes with CAP_SYSLOG
      "net.core.bpf_jit_enable" = false; # Disable ebpf jit
      #"kernel.ftrace_enabled" = false; # Disable debugging via ftrace
      # Ignore broadcast ICMP
      # C2S/CIS: CCE-80165-4
      "net.ipv4.icmp_echo_ignore_broadcasts" = true; # Ignore broadcast ICMP
      # Log Martian packets
      # C2S/CIS: CC0-80161-3 (Medium) and CC0-80160-5
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv6.conf.all.log_martians" = true;
      "net.ipv6.conf.default.log_martians" = true;
      # Strict reverse path filtering
      # C2S/CIS: CCE-80168-8 (Medium) and CCE-80167-0 (Medium)
      "net.ipv4.conf.all.rp_filter" = true;
      "net.ipv4.conf.default.rp_filter" = true;
      # Ignore incoming ICMP redirects
      # C2S/CIS: CCE-80183-7 (Medium), CCE-80181-1,
      # CCE-80158-9 (Medium), CCE-80163-9 (Medium)
      # CCE-80164-7 (Medium), CCE-80159-7 (Medium)
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;
      # Ignore illicit router advertisement
      # C2S/CIS: CCE-80181-1 and 80180-3 (Medium)
      "net.ipv6.conf.default.accept_ra" = false;
      "net.ipv6.conf.all.accept_ra" = false;
      # Ignore outgoing ICMP redirects
      # C2S/CIS: CCE-80156-3 (Medium)
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
      # Disable source routing
      # C2S/CIS: CCE-80262-1 (Medium) and CCE-27434-0 (Medium)
      "net.ipv4.conf.all.accept_source_route" = false;
      "net.ipv4.conf.default.accept_source_route" = false;
      "net.ipv6.conf.all.accept_source_route" = false;
      "net.ipv6.conf.default.accept_source_route" = false;
      # Enable TCP syncookies
      # C2S/CIS: CCE-27495-1 (Medium)
      "net.ipv4.tcp_syncookies" = true;
      "net.ipv6.tcp_syncookies" = true;
      # Keep sockets in FIN-WAIT-2 state time
      "net.ipv4.tcp_fin_timeout" = "30";
      "net.ipv6.tcp_fin_timeout" = "30";
    };
    blacklistedKernelModules = ["snd_pcsp"];
  };

  networking.firewall.logRefusedConnections = true;
}
