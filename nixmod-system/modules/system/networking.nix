{ config, pkgs, ... }:

{
  # Enable networking
  networking = {
    hostName = "nixos";  # Define hostname
    networkmanager.enable = true;
    # wireless.enable = true;  # Uncomment to enable wireless via wpa_supplicant

    # Pi-hole on the Raspberry Pi. NM stops writing the router's DNS into resolv.conf.
    # glibc tries servers in order, so 1.1.1.1 is only hit if the Pi is down.
    networkmanager.dns = "none";
    nameservers = [ "192.168.2.7" "1.1.1.1" ];

    # Static wired address (DHCP on the LAN stopped answering). Priority beats the
    # auto-generated "Wired connection 1" DHCP profile.
    networkmanager.ensureProfiles.profiles.wired-static = {
      connection = {
        id = "wired-static";
        type = "ethernet";
        interface-name = "enp3s0";
        autoconnect-priority = 100;
      };
      ipv4 = {
        method = "manual";
        address1 = "192.168.2.186/24,192.168.2.1";
      };
      ipv6.method = "auto";
    };
  };
  
  programs.kdeconnect = {
    enable = true;
  };

  # KDE Connect services
  services.dbus.enable = true;
  services.avahi = {
    enable = true;
    settings.publish = {
      disable-publishing = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
    };
  };
  
  # Systemd user service for KDE Connect (programs.kdeconnect only adds package + firewall)
  systemd.user.services.kdeconnect = {
    description = "KDE Connect daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.Restart = "on-failure";
    serviceConfig.ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd";
  };

  # netscanner needs raw sockets. Capability wrapper instead of the README's setuid-root.
  # security.wrappers rejects script targets, so wrap the real ELF behind nixpkgs'
  # launcher script and provide `iw` (which that script added to PATH) system-wide.
  # Installed at /run/wrappers/bin/netscanner.
  security.wrappers.netscanner = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_raw,cap_net_admin+ep";
    source = "${pkgs.netscanner}/bin/.netscanner-wrapped";
  };

  # Desktop entry for kdeconnect-indicator (fixes "App info not found" portal error on Wayland)
  # programs.kdeconnect already adds kdeconnect-kde; no need to duplicate
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    iw  # netscanner shells out to it (see wrapper above)
    networkmanagerapplet  # nm-connection-editor for Waybar network right-click
    (writeTextFile {
      name = "org.kde.kdeconnect-indicator.desktop";
      destination = "/share/applications/org.kde.kdeconnect-indicator.desktop";
      text = ''
        [Desktop Entry]
        Name=KDE Connect Indicator
        Exec=kdeconnect-indicator
        Type=Application
        NoDisplay=true
        X-Desktop-File-Install-Version=0.26
      '';
    })
  ];
}
