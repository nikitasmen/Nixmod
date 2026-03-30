{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # Git, bat, delta config in dotfiles: ~/.config/git/config
  programs.git.enable = true;

  environment.systemPackages = with pkgs; [
    git          # Version control
    delta        # Better git diff
    lazygit      # Git TUI
    bat          # cat with syntax highlighting
    eza          # Better ls
    docker       # Container platform
    helix        # Text editor
    claude-code  # AI coding assistant
    vim          # Text editor
    tmux         # Terminal multiplexer
    tree         # Directory display
    findutils    # File search utilities
    fd           # Faster find alternative
    tealdeer     # Fast tldr implementation
    coreutils    # Basic utilities
    # xclip      # Clipboard controll X11 based
    wl-clipboard # Clipboard controll Waylad based
    clipse       # Clipboard manager 
    scc          # Code counter
    p7zip        # zipping tool 
  ];
}
