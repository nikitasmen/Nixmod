{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;  # TUI-like terminal aesthetic
    colorScheme = "CatppuccinMacchiato";  # Matches waybar, helix, superfile
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    enabledCustomApps = with spicePkgs.apps; [
      marketplace  # Browse themes, extensions, apps in sidebar (install from UI may not work with Nix)
    ];
    experimentalFeatures = true;  # Required for marketplace and other features
    # Native Wayland support for Hyprland
    wayland = true;
  };
}
