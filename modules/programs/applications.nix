{ config, pkgs, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true;
  
  # Enable Steam
  programs.steam.enable = true;
  
  # Other applications
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    
    # Media
    spotify
    spicetify-cli
    freetube
    stremio
    
    # Communication
    webcord
    
    # Productivity
    logseq
    
    # File management
    yazi
    superfile
    
    # System tools
    neofetch
    htop
    nwg-look
        
    # Screenshots
    flameshot
  ];
}
