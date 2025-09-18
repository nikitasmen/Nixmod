{ config, pkgs, ... }:

{
  # Fonts configuration
  fonts.packages = with pkgs; [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
  ];
}
