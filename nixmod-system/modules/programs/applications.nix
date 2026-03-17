{ config, pkgs, lib, yt-x-pkg ? null, ... }:

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
  ] ++ lib.optional (yt-x-pkg != null) yt-x-pkg ++ [
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
    btop
    bottom   # btm - system monitor (executable: btm)
    nwg-look
        
    # Screenshots
    flameshot

    # ScreenSaver
    pipes-rs
  ];
}
