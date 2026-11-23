{ config, pkgs, nixmod, ... }:

{
  virtualisation.docker.enable = true;

  # Git, bat, delta config in dotfiles: ~/.config/git/config
  programs.git.enable = true;

  # ssh-agent as a systemd user service (sets SSH_AUTH_SOCK); keys get added on
  # first use, so a key's passphrase is asked once per login. System-wide
  # client config so lazyssh's ~/.ssh/config stays untouched.
  programs.ssh.startAgent = true;
  programs.ssh.extraConfig = "AddKeysToAgent yes";

  # Package list: development.packages.json (edited by nixmod-gui or by hand)
  # Not installed: xclip (X11 clipboard; wl-clipboard is used on Wayland).
  environment.systemPackages = nixmod.readPackages ./development.packages.json;
}
