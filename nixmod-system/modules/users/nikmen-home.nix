{ config, pkgs, dotfiles-path, ... }:

{
  home.username = "nikmen";
  home.homeDirectory = "/home/nikmen";
  home.stateVersion = "25.05"; # Match NixOS state version
  home.enableNixpkgsReleaseCheck = false; # Disable version mismatch warning when using unstable branch

  # This is the "DRY" way to manage dotfiles.
  # Instead of a bash script creating symlinks, Home Manager manages them.
  # If you change the files in the repo, HM will update the symlinks in ~/.config.
  
  xdg.configFile = {
    # Hyprland: individual files to allow scripts to write to ~/.config/hypr/ (e.g. hyprpaper.conf)
    "hypr/hyprland.conf" = { source = "${dotfiles-path}/hypr/hyprland.conf"; force = true; };
    "hypr/hypridle.conf" = { source = "${dotfiles-path}/hypr/hypridle.conf"; force = true; };
    "hypr/hyprlock.conf" = { source = "${dotfiles-path}/hypr/hyprlock.conf"; force = true; };
    "hypr/random-wallpaper.sh" = { source = "${dotfiles-path}/hypr/random-wallpaper.sh"; force = true; };
    "hypr/set-wallpaper.sh" = { source = "${dotfiles-path}/hypr/set-wallpaper.sh"; force = true; };
    
    # Other directories are managed as complete folders
    # 'force = true' ensures Home Manager replaces existing files without needing backups
    "waybar" = { source = "${dotfiles-path}/waybar"; force = true; };
    "kitty" = { source = "${dotfiles-path}/kitty"; force = true; };
    "ghostty" = { source = "${dotfiles-path}/ghostty"; force = true; };
    "wofi" = { source = "${dotfiles-path}/wofi"; force = true; };
    "wlogout" = { source = "${dotfiles-path}/wlogout"; force = true; };
    "fastfetch" = { source = "${dotfiles-path}/fastfetch"; force = true; };
    "cava" = { source = "${dotfiles-path}/cava"; force = true; };
    "starship" = { source = "${dotfiles-path}/starship"; force = true; };
    "superfile" = { source = "${dotfiles-path}/superfile"; force = true; };
    "bat" = { source = "${dotfiles-path}/bat"; force = true; };
    "helix" = { source = "${dotfiles-path}/helix"; force = true; };
    "tmux" = { source = "${dotfiles-path}/tmux"; force = true; };
    "clipse" = { source = "${dotfiles-path}/clipse"; force = true; };
    "aichat" = { source = "${dotfiles-path}/aichat"; force = true; };
    "waypaper" = { source = "${dotfiles-path}/waypaper"; force = true; };
    
    # Git config replacement
    "git/config" = { source = "${dotfiles-path}/git/config"; force = true; };
  };

  # Enable programs managed by Home Manager
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.starship.enable = true;
}
