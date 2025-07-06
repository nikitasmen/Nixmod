{
  description = "NixOS configuration with Hyprland and UnixKit";

  inputs = {
    # Base inputs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Import flake inputs from modules
    # UnixKit module inputs
    unixkit = (import ./flakes/unixkit).inputs.unixkit;
    
    # You can add more modular inputs here
  };

  outputs = { self, nixpkgs, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
      
      # Import module outputs
      unixkitModule = (import ./flakes/unixkit).outputs inputs;
      
    in {
      nixosConfigurations.nixos = lib.nixosSystem {
        inherit system;
        
        specialArgs = { 
          # Pass all inputs to modules
          inherit inputs;
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
