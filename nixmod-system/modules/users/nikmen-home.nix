{ config, pkgs, dotfiles-path, ... }:

{
  home.username = "nikmen";
  home.homeDirectory = "/home/${config.home.username}";
  home.stateVersion = "25.05"; # Match NixOS state version

  # This is the "DRY" way to manage dotfiles.
  # Instead of a bash script creating symlinks, Home Manager manages them.
  # If you change the files in the repo, HM will update the symlinks in ~/.config.
  
  xdg.configFile = {
    # Hyprland: individual files to allow scripts to write to ~/.config/hypr/ (e.g. hyprpaper.conf)
    "hypr/hyprland.conf".source = "${dotfiles-path}/hypr/hyprland.conf";
    "hypr/hypridle.conf".source = "${dotfiles-path}/hypr/hypridle.conf";
    "hypr/hyprlock.conf".source = "${dotfiles-path}/hypr/hyprlock.conf";
    "hypr/random-wallpaper.sh".source = "${dotfiles-path}/hypr/random-wallpaper.sh";
    "hypr/set-wallpaper.sh".source = "${dotfiles-path}/hypr/set-wallpaper.sh";
    
    # Other directories are managed as complete folders
    "waybar".source = "${dotfiles-path}/waybar";
    "kitty".source = "${dotfiles-path}/kitty";
    "ghostty".source = "${dotfiles-path}/ghostty";
    "wofi".source = "${dotfiles-path}/wofi";
    "wlogout".source = "${dotfiles-path}/wlogout";
    "fastfetch".source = "${dotfiles-path}/fastfetch";
    "cava".source = "${dotfiles-path}/cava";
    "starship".source = "${dotfiles-path}/starship";
    "superfile".source = "${dotfiles-path}/superfile";
    "bat".source = "${dotfiles-path}/bat";
    "helix".source = "${dotfiles-path}/helix";
    "tmux".source = "${dotfiles-path}/tmux";
    "clipse".source = "${dotfiles-path}/clipse";
    "aichat".source = "${dotfiles-path}/aichat";
    "waypaper".source = "${dotfiles-path}/waypaper";
  };

  # Enable programs managed by Home Manager
  programs.home-manager.enable = true;
  programs.git.enable = true;
  programs.zsh.enable = true;
  programs.starship.enable = true;
}
