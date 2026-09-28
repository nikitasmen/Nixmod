{
  description = "NixOS configuration with Hyprland and UnixKit";

  inputs = {
    # Base inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    hyprland.url = "github:hyprwm/Hyprland";

    # UnixKit module inputs
    unixkit = {
      url = "github:nikitasmen/UnixKit";
      flake = false;
    };

    passman = {
      url = "github:nikitasmen/password-manager-";
      flake = false;
    };
    
    # Spicetify - Spotify themes and extensions
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unixkit, passman, home-manager, ... }@inputs: 
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
        imports = [ ./nixmod-system/unixkit.nix ];
        _module.args.unixkit = unixkit;
      };

      passmanModule = { config, ... }: {
        imports = [ ./nixmod-system/passman.nix ];
        _module.args.passman = passman;
      };
      
    in {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          inherit inputs;
          dotfiles-path = ./nixmod-dotfiles;
        };
        
        modules = [
          # Main configuration file
          ./nixmod-system/configuration.nix
          
          # Home Manager
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { 
              inherit inputs; 
              dotfiles-path = ./nixmod-dotfiles;
            };
            home-manager.users.nikmen = import ./nixmod-system/modules/users/nikmen-home.nix;
          }
          
          # UnixKit (provides unixkit input to unixkit.nix)
          unixkitModule
          passmanModule
          
          # Spicetify (Spotify themes)
          inputs.spicetify-nix.nixosModules.spicetify
          
          # You can add more modules here
        ];
      };
    };
}
