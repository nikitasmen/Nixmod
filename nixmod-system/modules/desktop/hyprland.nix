{ config, pkgs, lib, inputs,  ... }:

{
  # Enable hyprland
  programs.hyprland = {
    enable = true; 
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  }; 

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
  
  # Minimal login manager that launches Hyprland directly (no GDM/GNOME)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
      user = "greeter";
    };
  };
  
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; 
    # ollama_vulkan = pkgs.ollama-vulkan; 
    # acceleration = "cuda";  # Uncomment for GPU
  };
  
  # Hyprland related packages
  environment.systemPackages = with pkgs; [
    waybar       # Status bar
    wofi         # Application launcher
    wlogout      # Logout menu
    hyprpaper    # Wallpaper utility
    waypaper     # GUI wallpaper utility
    swaybg       # Backend for waypaper (optional but good to have)
    hypridle     # Idle management
    hyprlock     # Screen locking
    hyprutils
    hyprlang
    hyprpolkitagent  # Polkit agent for pkexec/auth dialogs (input-remapper, etc.)
    mako         # Notification daemon
    grim         # Screenshot utility (backend)
    slurp        # Area selection for screenshots
    git          # Required for dotfiles installation
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
