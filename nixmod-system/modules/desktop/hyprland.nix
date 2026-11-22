{ config, pkgs, nixmod, lib, ... }:

{
  # Enable hyprland
  # nixpkgs' release Hyprland (prebuilt), not the git-master flake: master broke the NVIDIA+AMD dual-monitor setup
  programs.hyprland.enable = true;

   programs.hyprlock.enable = true;

  # XDG Portal configuration for Wayland
  # programs.hyprland adds xdg-desktop-portal-hyprland automatically
  # xdg-desktop-portal-gtk needed for Qt/KDE app portal registration (e.g. kdeconnect-indicator)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "hyprland" "gtk" ];
    };
  };

  # Hyprland related packages
  # Package list: hyprland.packages.json (edited by nixmod-gui or by hand)
  environment.systemPackages = nixmod.readPackages ./hyprland.packages.json;

  # Polkit agent - required for input-remapper-gtk, pkexec auth dialogs
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland PolicyKit Agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
  };
}
