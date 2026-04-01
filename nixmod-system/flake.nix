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

    # Spicetify - Spotify themes and extensions
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unixkit, yt-x, nix-ai, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
      
      unixkitModule = { config, ... }: {
        imports = [ ./unixkit.nix ];
        _module.args.unixkit = unixkit;
      };
      
    in {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs;
          yt-x-pkg = yt-x.packages.${system}.default;
          dotfiles-path = ../nixmod-dotfiles;
        };
        
        modules = [
          # Main configuration file
          ./configuration.nix
          
          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { 
              inherit inputs; 
              dotfiles-path = ../nixmod-dotfiles;
            };
            home-manager.users.nikmen = import ./modules/users/nikmen-home.nix;
          }
          
          # UnixKit (provides unixkit input to unixkit.nix)
          unixkitModule
          
          # Spicetify (Spotify themes)
          inputs.spicetify-nix.nixosModules.spicetify
          
          # You can add more modules here
        ];
      };
    };
}
