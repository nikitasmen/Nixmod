{ config, pkgs, lib, ... }:

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
  
  services.ollama = {
    enable = true;
    # Vulkan (still GPU): prebuilt on cache.nixos.org, unlike unfree ollama-cuda which compiles locally
    package = pkgs.ollama-vulkan;
  };

  # Hyprland related packages
  environment.systemPackages = with pkgs; [
    waybar       # Status bar
    wofi         # Application launcher
    wlogout      # Logout menu
    hyprpaper    # Wallpaper utility
    waypaper     # GUI wallpaper utility
    hypridle     # Idle management
    hyprlock     # Screen locking
    hyprpolkitagent  # Polkit agent for pkexec/auth dialogs (input-remapper, etc.)
    mako         # Notification daemon
    #eww          # Widget system
    jq           # Command-line JSON processor
  ];

  # Polkit agent - required for input-remapper-gtk, pkexec auth dialogs
  systemd.user.services.hyprpolkitagent = {
    description = "Hyprland PolicyKit Agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig.Type = "simple";
    serviceConfig.ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
  };
}
