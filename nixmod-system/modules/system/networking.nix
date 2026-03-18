{ config, pkgs, ... }:

{
  # Enable networking
  networking = {
    hostName = "nixos";  # Define hostname
    networkmanager.enable = true;
    # wireless.enable = true;  # Uncomment to enable wireless via wpa_supplicant
  };
  
  # KDE Connect services
  services.dbus.enable = true;
  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    publish.addresses = true;
  };
  
services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;
  };
  
  # Desktop entry for kdeconnect-indicator (fixes "App info not found" portal error on Wayland)
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    networkmanagerapplet  # nm-connection-editor for Waybar network right-click
    kdePackages.kdeconnect-kde
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
