# Generic Flake Module Template
# Copy this file to create a new flake module
{
  # Define your flake inputs
  inputs = {
    example-flake = {
      url = "github:example/repository";
      # Uncomment if this is not a flake
      # flake = false;
      
      # Uncomment to make it follow the same nixpkgs as your system
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  # Define the output function that creates the module
  outputs = inputs@{ example-flake, ... }: {
    # This function returns a NixOS module
    module = { config, pkgs, lib, ... }: {
      # Your module configuration goes here
      # For example:
      # imports = [ example-flake.nixosModules.default ];
      
      # Or direct configuration:
      # programs.example.enable = true;
      # environment.systemPackages = [ example-flake.packages.${pkgs.system}.default ];
    };
    
    # Expose any other useful outputs from the flake
    # nixosModules = example-flake.nixosModules or {};
    # packages = example-flake.packages or {};
  };
}
