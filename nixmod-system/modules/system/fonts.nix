{ config, pkgs, nixmod, ... }:

{
  # Fonts configuration
  # Package list: fonts.packages.json (edited by nixmod-gui and `nixmod.sh packages`)
  fonts.packages = nixmod.readPackages ./fonts.packages.json;
}
