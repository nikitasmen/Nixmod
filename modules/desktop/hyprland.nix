{ config, pkgs, lib, ... }:

{
  # Enable hyprland
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;

  # XDG Portal configuration for Wayland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config = {
      common.default = "wlr";
    };
  };
  
  # Enable required services for Hyprland
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = false;
  
  # Hyprland related packages
  environment.systemPackages = with pkgs; [
    kitty        # Terminal emulator
    waybar       # Status bar
    wofi         # Application launcher
    wlogout      # Logout menu
    hyprpaper    # Wallpaper utility
    hypridle     # Idle management
    hyprlock     # Screen locking
    mako         # Notification daemon
    grim         # Screenshot utility (backend)
    slurp        # Area selection for screenshots
    eww          # Widget system
    jq           # Command-line JSON processor
  ];
}
