{ config, pkgs, ... }:

{
  # Terminal emulators
  environment.systemPackages = with pkgs; [
    ghostty    # Modern terminal emulator
  ];
}
