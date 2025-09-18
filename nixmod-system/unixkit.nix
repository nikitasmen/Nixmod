{ config, pkgs, lib, unixkit ? null, ... }:

let
  # If unixkit is provided as an input from flake.nix, use that
  # Otherwise, fetch it directly (for non-flake usage)
  unixKitSrc = if unixkit != null 
    then unixkit
    else builtins.fetchGit {
      url = "https://github.com/nikitasmen/UnixKit.git";
      # For non-flake usage, we use fetchGit without rev to get latest commit
      # However, this is cached by Nix and doesn't update on every build
      # The flake-based approach is better for getting latest commits
    };

  # Build the package
  unixKit = pkgs.stdenv.mkDerivation {
    name = "unixkit";
    version = "unstable";
    
    src = unixKitSrc;
    
    # No build phase needed if these are just scripts
    dontBuild = true;
    
    installPhase = ''
      mkdir -p $out/bin
      cp -r $src/* $out/bin/
      chmod -R +x $out/bin
    '';
    
    meta = with lib; {
      description = "Collection of Unix utility scripts";
      homepage = "https://github.com/nikitasmen/UnixKit";
      license = licenses.mit;  # Adjust according to the actual license
      platforms = platforms.all;
      maintainers = [ "nikitasmen" ];
    };
  };
in {
  environment.systemPackages = [
    unixKit
  ];
}
