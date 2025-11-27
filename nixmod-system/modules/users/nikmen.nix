{ config, pkgs, ... }:

{
  # Define user account
  users.users.nikmen = {
    isNormalUser = true;
    description = "nikmen";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      slack   # Communication
      viber   # Communication
      discord-ptb # Communication
      
      prismlauncher  #Minecraft launcher
    ];
  };
}
