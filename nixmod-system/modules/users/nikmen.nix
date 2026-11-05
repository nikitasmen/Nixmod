{ config, pkgs, ... }:

{
  # Enable Steam
  programs.steam.enable = true;

  # RPCS3 locks guest memory; the 8 MB default makes it fail ("Failed to lock sudo memory")
  security.pam.loginLimits = [
    { domain = "nikmen"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  # Define user account
  users.users.nikmen = {
    isNormalUser = true;
    description = "nikmen";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "video"
      "audio"
      "input"
      "dialout"
    ];
    packages = with pkgs; [
      slack # Communication
      viber # Communication
      discord-ptb # Communication

      tlauncher # TLauncher (JAR in ~/Downloads/)
      heroic # Heroic Game launcher
      rpcs3 # PS3 emulator
      xenia-canary # Xbox 360 emulator
    ];
  };
}
