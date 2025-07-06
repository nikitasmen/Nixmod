# Flake Templates for NixOS Configuration

This directory contains template files for flake modules that can be used to extend your NixOS configuration.

## Structure

The directory is organized as follows:

```nix
flakes/
└── templates/       # Templates for new flake modules
    └── generic-flake.nix
```

## Simplified Approach

We now use a more direct approach for flake inputs in the main `flake.nix` file:

1. Define inputs directly in the main flake.nix
2. Pass them to modules via specialArgs or _module.args
3. Use the module pattern shown in the templates as a reference

## Adding a New Flake Input

To add a new flake input, follow these steps:

1. Add the input directly to your main flake.nix:

   ```nix
   inputs = {
     # Existing inputs
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     
     # New input
     new-input = {
       url = "github:owner/repo";
       flake = true; # or false for non-flake repos
     };
   };
   ```

2. Create a module that uses the input:

   ```nix
   outputs = { self, nixpkgs, new-input, ... }@inputs: 
     let
       # Create a module that passes the input to your config
       newInputModule = {
         module = { config, ... }: {
           imports = [ ./path/to/module.nix ];
           _module.args.newInput = new-input;
         };
       };
     in {
       # Rest of your flake output
     };
   ```

## Benefits

- **Modularity**: Each flake is isolated in its own file
- **Maintainability**: Easier to update individual components
- **Scalability**: Add new flakes without cluttering the main `flake.nix`
- **Reusability**: Modules can be shared across different NixOS configurations
