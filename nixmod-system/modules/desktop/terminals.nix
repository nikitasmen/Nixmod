{ config, pkgs, ... }:

{
  # Terminal emulators
  environment.systemPackages = with pkgs; [
    kitty      # Feature-rich terminal emulator
    ghostty    # Modern terminal emulator
  ];
}
