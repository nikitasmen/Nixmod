{ config, pkgs, ... }:

{
  # Enable Docker for containerization
  virtualisation.docker.enable = true;
  
  # Git configuration
  programs.git = { 
    enable = true; 
    config = {  
      user.name = "nikitasmen";
      user.email = "menounosnikitas@gmail.com";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      merge.conflictStyle = "zdiff3";

      # Delta: syntax-highlighted diffs
      delta = {
        navigate = true;   # n/N to move between hunks
        dark = true;       # dark theme (matches Tokyo Night)
        line-numbers = true;
      };
    };
  };

  # delta ./file -> git diff for that file (delta used as pager)
  environment.shellAliases.delta = "git diff --";
  
  # Development tools
  environment.systemPackages = with pkgs; [
    git          # Version control
    delta        # Better git diff
    lazygit      # Git TUI
    bat          # cat with syntax highlighting
    eza          # Better ls
    docker       # Container platform
    helix        # Text editor
    vim          # Text editor
    tmux         # Terminal multiplexer
    tree         # Directory display
    findutils    # File search utilities
    coreutils    # Basic utilities
    # xclip      # Clipboard controll X11 based
    wl-clipboard # Clipboard controll Waylad based
    clipse       # Clipboard manager 
    scc          # Code counter
  ];
}
