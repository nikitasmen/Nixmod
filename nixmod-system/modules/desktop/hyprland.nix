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
  
  services.ollama = {
    enable = true;
    # acceleration = "cuda";  # Uncomment for GPU
  };
  
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
    git          # Required for dotfiles installation
    #eww          # Widget system
    jq           # Command-line JSON processor
  ];

  # Install dotfiles once per user on first graphical login (runs as the logged-in user)
  systemd.user.services.install-dotfiles = {
    description = "Install NixMod dotfiles";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -d $HOME/.config/dotfiles ]; then git clone https://github.com/nikitasmen/Nixmod.git $HOME/.config/dotfiles; fi && cd $HOME/.config/dotfiles && ./toolkit/dotfiles.sh install'";
    };
  };
}
