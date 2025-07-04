{ config, pkgs, lib, ... }:

let
  # Fetch the latest commit from GitHub repo
  unixKitSrc = builtins.fetchGit {
    url = "https://github.com/nikitasmen/UnixKit.git";
    # Omitting 'rev' to always get the latest commit on rebuild
  };

  # Build the package
  unixKit = pkgs.stdenv.mkDerivation {
    name = "unixkit";
    version = "unstable-${builtins.substring 0 8 unixKitSrc.rev}";
    
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
