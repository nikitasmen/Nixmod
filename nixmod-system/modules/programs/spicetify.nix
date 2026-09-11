{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
  # Stats app: top artists, tracks, genres, library & playlist analysis
  # https://github.com/harbassan/spicetify-apps/blob/main/projects/stats/README.md
  statsAppSrc = pkgs.fetchFromGitHub {
    owner = "harbassan";
    repo = "spicetify-apps";
    rev = "c39fef2b9ac9e9dbcdcd7c851b77c19a9a2eb8c1";
    sha256 = "10g671kj8q105wgcwp820z31bpvbzwadxiiykflxmifc823mncj0";
  };
in
{
  
  programs.nix-ld.enable = true ;
  
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;  # TUI-like terminal aesthetic
    colorScheme = "CatppuccinMacchiato";  # Matches waybar, helix, superfile
    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      shuffle
      # Statistics
      skipStats      # Track skips per playlist/album, view via profile menu
      songStats      # Show song stats (danceability, tempo, key)
      sessionStats   # Track listening stats for current session
      history        # Listening history page
    ];
    enabledCustomApps = (with spicePkgs.apps; [
      marketplace      # Browse themes, extensions, apps in sidebar (install from UI may not work with Nix)
      ]);
    enabledSnippets = with spicePkgs.snippets; [
      oneko
    ]; 
    experimentalFeatures = true;  # Required for marketplace and other features
    # Wayland support can be buggy on NVIDIA with offload, so we use XWayland (default)
    wayland = false;
  };
}
