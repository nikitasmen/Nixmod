{ config, pkgs, nixmod, ... }:

{
  # Terminal emulators
  # Package list: terminals.packages.json (edited by nixmod-gui or by hand)
  environment.systemPackages = nixmod.readPackages ./terminals.packages.json;
}
