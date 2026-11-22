{ config, pkgs, nixmod, ... }:

{
  # Terminal emulators
  # Package list: terminals.packages.json (edited by nixmod-gui and `nixmod.sh packages`)
  environment.systemPackages = nixmod.readPackages ./terminals.packages.json;
}
