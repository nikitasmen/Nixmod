{ config, pkgs, ... }:

{
  # Terminal emulators
  environment.systemPackages = with pkgs; [
    # kitty      # Feature-rich terminal emulator
    alacritty  # GPU-accelerated terminal emulator
    ghostty    # Modern terminal emulator
  ];
}
