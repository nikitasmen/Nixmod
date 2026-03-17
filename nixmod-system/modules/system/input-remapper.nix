# Input Remapper - map extra mouse buttons and keyboard keys
# GUI: run `input-remapper-gtk` to configure presets
# Presets are stored in ~/.config/input-remapper/

{ config, pkgs, ... }:

{
  services.input-remapper = {
    enable = true;
    enableUdevRules = true;  # Handle hotplugged devices (e.g. USB mice)
  };

  environment.systemPackages = [ pkgs.input-remapper ];
}
