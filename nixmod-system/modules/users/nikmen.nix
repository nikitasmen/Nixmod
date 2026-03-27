{ config, pkgs, ... }:

{
  # Enable Steam
  programs.steam.enable = true;
    
  # Define user account
  users.users.nikmen = {
    isNormalUser = true;
    description = "nikmen";
    extraGroups = [ "networkmanager" "wheel" "docker" "input" ];
    packages = with pkgs; [
      slack   # Communication
      viber   # Communication
      discord-ptb # Communication
      
      tlauncher      # TLauncher (JAR in ~/Downloads/)
      heroic         # Heroic Game launcher 
    ];
  };
}
