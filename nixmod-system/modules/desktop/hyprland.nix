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
    git          # Required for dotfiles installation
    #eww          # Widget system
    #jq           # Command-line JSON processor
  ];

  # Create a systemd service to install dotfiles after user login
  systemd.user.services.install-dotfiles = {
    description = "Install NixMod dotfiles";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'if [ ! -d $HOME/.config/dotfiles ]; then git clone https://github.com/yourusername/nixmod-dotfiles.git $HOME/.config/dotfiles; fi && cd $HOME/.config/dotfiles && ./install.sh'";
      User = "nikmen";
    };
  };
}
