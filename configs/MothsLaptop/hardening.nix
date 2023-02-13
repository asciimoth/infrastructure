{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  fileSystems = {
    "/".options = ["noatime" "nodiratime"];
    "/tmp" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "noatime"
        "nodiratime"
        #"noexec" # Exec permition need for nix pkgs build
        "nosuid"
        "nodev"
        "mode=1777"
      ];
    };
  };

  #nix.settings.allowed-users = lib.mkForce [ "root" ];
  
  system.autoUpgrade.enable = lib.mkForce false;

  environment = {
    defaultPackages = lib.mkForce [];
    systemPackages = with pkgs; [
      #clamav
    ];
  };

  services = {
    openssh = {
      passwordAuthentication = lib.mkForce false;
      allowSFTP = false;
      kbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
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

  boot = {
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
      "net.ipv4.icmp_echo_ignore_broadcasts" = true; # Ignore broadcast ICMP
      # Strict reverse path filtering
      "net.ipv4.conf.all.log_martians" = true;
      "net.ipv4.conf.all.rp_filter" = true;
      "net.ipv4.conf.default.log_martians" = true;
      "net.ipv4.conf.default.rp_filter" = true;
      # Ignore incoming ICMP redirects
      "net.ipv4.conf.all.accept_redirects" = false;
      "net.ipv4.conf.all.secure_redirects" = false;
      "net.ipv4.conf.default.accept_redirects" = false;
      "net.ipv4.conf.default.secure_redirects" = false;
      "net.ipv6.conf.all.accept_redirects" = false;
      "net.ipv6.conf.default.accept_redirects" = false;
      # Ignore outgoing ICMP redirects
      "net.ipv4.conf.all.send_redirects" = false;
      "net.ipv4.conf.default.send_redirects" = false;
    };
    blacklistedKernelModules = [ "snd_pcsp" ];
  };
}
