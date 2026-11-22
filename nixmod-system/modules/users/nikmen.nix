{ config, pkgs, nixmod, ... }:

{
  # Enable Steam
  programs.steam.enable = true;

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
    # Package list: nikmen.packages.json (edited by nixmod-gui and `nixmod.sh packages`)
    packages = nixmod.readPackages ./nikmen.packages.json;
  };
}
