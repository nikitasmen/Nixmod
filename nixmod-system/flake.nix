{
  description = "NixOS configuration with Hyprland and UnixKit";

  inputs = {
    # Base inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # UnixKit module inputs
    unixkit = {
      url = "github:nikitasmen/UnixKit";
      flake = false;
    };
    
    # NixAi assistant 
    nix-ai.url = "github:olafkfreund/nix-ai-help";

    # yt-x - terminal YouTube client
    yt-x.url = "github:Benexl/yt-x";
    
  };

  outputs = { self, nixpkgs, unixkit, yt-x, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
      
      # Create UnixKit module directly
      unixkitModule = {
        module = { config, ... }: {
          imports = [ ./unixkit.nix ];
          _module.args.unixkit = unixkit;
        };
      };
      
    in {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs;
          yt-x-pkg = yt-x.packages.${system}.default;
        };
        
        modules = [
          # Main configuration file
          ./configuration.nix
          
          # Import modular flake components
          unixkitModule.module
          
          # You can add more modules here
        ];
      };
    };
}
