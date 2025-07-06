# UnixKit flake module
{
  # This exposes two functions: 
  # - inputs: to be used in your main flake.nix for input declarations
  # - outputs: to be used to create the actual module
  
  # Define UnixKit inputs
  inputs = {
    unixkit = {
      url = "github:nikitasmen/UnixKit";
      flake = false; # Set to true if UnixKit becomes a flake in the future
    };
  };
  
  # Define the output function that creates the module
  outputs = { unixkit, pkgs, lib, ... }: {
    # This function returns a NixOS module
    module = { config, ... }: {
      environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
          name = "unixkit";
          version = "unstable";
          
          src = unixkit;
          
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
        })
      ];
    };
  };
}
