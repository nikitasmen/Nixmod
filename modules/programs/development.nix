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
    };
  };
  
  # Development tools
  environment.systemPackages = with pkgs; [
    git          # Version control
    docker       # Container platform
    helix        # Text editor
    vim          # Text editor
    tmux         # Terminal multiplexer
    tree         # Directory display
    findutils    # File search utilities
    coreutils    # Basic utilities
    xclip        # Clipboard controll
    scc          # Code counter
  ];
}
