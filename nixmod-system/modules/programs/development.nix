{ config, pkgs, nixmod, ... }:

{
  virtualisation.docker.enable = true;

  # Git, bat, delta config in dotfiles: ~/.config/git/config
  programs.git.enable = true;

  # Package list: development.packages.json (edited by nixmod-gui or by hand)
  # Not installed: xclip (X11 clipboard; wl-clipboard is used on Wayland).
  environment.systemPackages = nixmod.readPackages ./development.packages.json;
}
