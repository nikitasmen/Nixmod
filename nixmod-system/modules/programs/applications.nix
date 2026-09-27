{ config, pkgs, lib, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true; 
  
  # Other applications
  environment.systemPackages = with pkgs; [
    # Browsers
    google-chrome
    
    # stremio #Insecure dependencies
    
    # Communication
    # webcord
    # Use DiscordPtb as is not electron dependable 
    
    # Productivity
    # logseq
    # Use DiscordPtb as is not electron dependable
    
    # File management
    superfile
    
    # System tools
    # neofetch
    fastfetch
    btop
    bottom   # btm - system monitor (executable: btm)
    lsof
    wl-screenrec
    nwg-look
    wdisplays   # Monitor layout GUI
    ffmpeg   # Multimedia framework       
    gum      # Tool for  glamorous shell scripts
    chafa    # Cli image converter
    tigervnc # VNC client (vncviewer)
    # Screenshots
    flameshot

    # ScreenSaver
    pipes-rs

    # Silly / boredom killers
    fortune       # Random quotes: fortune
    cowsay        # ASCII art animals: fortune | cowsay -f dragon
    cmatrix       # Matrix rain: cmatrix
    figlet        # ASCII art text: figlet "NixOS"
    hollywood     # Fake hacker terminal: hollywood
  ];
}
