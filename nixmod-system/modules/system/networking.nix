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
  
  # Network related packages
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    networkmanagerapplet  # nm-connection-editor for Waybar network right-click
    kdePackages.kdeconnect-kde
  ];
}
