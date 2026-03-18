{ config, pkgs, lib, yt-x-pkg ? null, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true;  
  
  # Other applications
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    
    # Media (Spotify installed via spicetify.nix with themes)
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
    lsof
    wl-screenrec
    geoclue2 
    nwg-look
    wdisplays   # Monitor layout GUI
    ffmpeg   # Multimedia framework       
    gum      # Tool for  glamorous shell scripts
    mpv      # Cli media player
    yt-dlp   # Youtube downloader
    chafa    # Cli image converter
    # Screenshots
    flameshot

    # ScreenSaver
    pipes-rs
  ];
}
