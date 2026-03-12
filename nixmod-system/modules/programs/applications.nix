{ config, pkgs, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true;  
  
  # Other applications
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    
    # Media
    spotify
    spicetify-cli
    freetube
    # stremio #Insecure dependencies
    
    # Communication
    webcord
    
    # Productivity
    logseq
    
    # File management
    yazi
    superfile
    
    # System tools
    # neofetch
    fastfetch
    htop
    nwg-look
        
    # Screenshots
    flameshot

    # ScreenSaver
    pipes-rs
  ];
}
