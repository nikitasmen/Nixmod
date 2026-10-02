{ config, pkgs, lib, ... }:

{
  # Enable Firefox
  programs.firefox.enable = true;
  # Block every AI feature (chatbot, smart window, link previews, smart tab
  # groups, PDF alt-text, speech recognition, translations) and lock it so the
  # settings page can't turn it back on.
  programs.firefox.policies.AIControls.Default = { Value = "blocked"; Locked = true; };
  # Stop the on-device ML engine from loading or downloading models at all
  programs.firefox.preferences."browser.ml.enable" = false;
  programs.firefox.preferencesStatus = "locked";
  # Firefox enables speech-dispatcher by default (~1 GB of voices); not needed
  services.speechd.enable = false;
  
  # Other applications
  environment.systemPackages = with pkgs; [
    # Browsers
    qutebrowser
    
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
