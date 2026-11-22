{ config, pkgs, nixmod, ... }:

{
  # Fonts configuration
  # Package list: fonts.packages.json (edited by nixmod-gui or by hand)
  fonts.packages = nixmod.readPackages ./fonts.packages.json;
}
