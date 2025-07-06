# Modular Flakes for NixOS Configuration

This directory contains modular flake components that are composed in the main `flake.nix`.

## Structure

Each subdirectory represents a separate flake input and its corresponding NixOS module:

```nix
flakes/
├── unixkit/         # Custom Unix utilities
│   └── default.nix  # Defines inputs and outputs
└── templates/       # Templates for new flake modules
    └── generic-flake.nix
```

## How It Works

Each module exports two functions:

- `inputs`: Defines the flake inputs required by the module
- `outputs`: Creates the actual NixOS module using those inputs

The main `flake.nix` imports and composes these modules, avoiding duplication and keeping the configuration clean.

## Adding a New Flake Module

1. Create a new directory for your module:

   ```bash
   mkdir -p flakes/new-module
   ```

2. Copy the template:

   ```bash
   cp flakes/templates/generic-flake.nix flakes/new-module/default.nix
   ```

3. Edit the new `default.nix` to define your flake inputs and outputs.

4. Update the main `flake.nix`:

   ```nix
   inputs = {
     # ...existing inputs
     new-module = (import ./flakes/new-module).inputs.new-module;
   };
   
   outputs = { self, nixpkgs, ... }@inputs: 
     let
       # ...existing setup
       newModuleModule = (import ./flakes/new-module).outputs inputs;
     in {
       nixosConfigurations.nixos = lib.nixosSystem {
         # ...existing config
         modules = [
           # ...existing modules
           newModuleModule.module
         ];
       };
     };
   ```

## Benefits

- **Modularity**: Each flake is isolated in its own file
- **Maintainability**: Easier to update individual components
- **Scalability**: Add new flakes without cluttering the main `flake.nix`
- **Reusability**: Modules can be shared across different NixOS configurations
