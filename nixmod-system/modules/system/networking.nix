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
  
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  
  # Network related packages
  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
    kdePackages.kdeconnect-kde
  ];
}
