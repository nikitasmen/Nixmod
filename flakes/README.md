# Nix Flakes Management

This directory contains templates and documentation for managing Nix flakes in your NixMod configuration.

## 📁 Structure

```
flakes/
├── README.md              # This file
└── templates/             # Flake templates
    └── generic-flake.nix  # Generic flake template
```

## 🎯 Overview

Nix flakes provide a more reproducible and composable way to manage NixOS configurations. This directory contains:

- **Templates** for creating new flake modules
- **Documentation** on flake best practices
- **Examples** of common flake patterns

## 🚀 Quick Start

### Adding a New Flake Input

1. **Add to main flake.nix**:
   ```nix
   inputs = {
     # Existing inputs
     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
     
     # New input
     my-flake = {
       url = "github:owner/repo";
       flake = true; # or false for non-flake repos
     };
   };
   ```

2. **Create a module** that uses the input:
   ```nix
   outputs = { self, nixpkgs, my-flake, ... }@inputs: 
     let
       myFlakeModule = {
         module = { config, ... }: {
           imports = [ ./modules/my-flake.nix ];
           _module.args.myFlake = my-flake;
         };
       };
     in {
       nixosConfigurations.nixos = lib.nixosSystem {
         inherit system;
         modules = [
           ./configuration.nix
           myFlakeModule.module
         ];
       };
     };
   ```

3. **Use the flake in your module**:
   ```nix
   { config, pkgs, myFlake, ... }:
   
   {
     environment.systemPackages = [
       (pkgs.callPackage myFlake { })
     ];
   }
   ```

## 📋 Flake Templates

### Generic Flake Template

Use `templates/generic-flake.nix` as a starting point for new flake modules:

```nix
{
  description = "Generic flake template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Add your inputs here
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
    in {
      # Define your outputs here
      packages.${system} = {
        # Your packages
      };
      
      # Or NixOS modules
      nixosModules.default = { config, ... }: {
        # Your module configuration
      };
    };
}
```

## 🔧 Common Patterns

### Package Flakes

For flakes that provide packages:

```nix
{
  description = "My custom package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system} = {
        my-package = pkgs.stdenv.mkDerivation {
          name = "my-package";
          src = ./.;
          # Build configuration
        };
      };
    };
}
```

### Module Flakes

For flakes that provide NixOS modules:

```nix
{
  description = "My NixOS module";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosModules.default = { config, pkgs, ... }: {
      # Your module configuration
      environment.systemPackages = with pkgs; [
        # Packages
      ];
      
      services.my-service = {
        enable = true;
        # Configuration
      };
    };
  };
}
```

### Development Flakes

For development environments:

```nix
{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Development tools
        ];
        
        shellHook = ''
          # Setup commands
        '';
      };
    };
}
```

## 🛠️ Management Commands

### Using the Toolkit

The NixMod toolkit provides commands for flake management:

```bash
# Add a new flake (run from project root)
./toolkit/add-flake.sh github:owner/repo my-flake

# Update all flake inputs
./toolkit/nixmod.sh flake-update

# Lock flake inputs
nix flake lock

# Show flake info
nix flake show
```

### Manual Flake Commands

```bash
# Update specific input
nix flake update my-flake

# Update all inputs
nix flake update

# Lock inputs
nix flake lock

# Show dependencies
nix flake metadata

# Validate flake
nix flake check
```

## 📚 Best Practices

### Input Management

1. **Pin versions** for stability:
   ```nix
   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/23.11";
   };
   ```

2. **Use specific revisions** for reproducibility:
   ```nix
   inputs = {
     nixpkgs = {
       url = "github:NixOS/nixpkgs";
       rev = "abc123...";
     };
   };
   ```

3. **Follow naming conventions**:
   - Use descriptive names for inputs
   - Use kebab-case for flake names
   - Use camelCase for variable names

### Module Organization

1. **Keep modules focused** on a single concern
2. **Use descriptive names** for modules
3. **Document module options** with comments
4. **Test modules** before committing

### Error Handling

1. **Validate flake syntax**:
   ```bash
   nix flake check
   ```

2. **Test configuration**:
   ```bash
   nixos-rebuild dry-activate
   ```

3. **Check for conflicts**:
   ```bash
   nix flake show
   ```

## 🔍 Troubleshooting

### Common Issues

#### Flake Not Found
```bash
# Check if flake exists
nix flake metadata github:owner/repo

# Verify URL format
nix flake show
```

#### Version Conflicts
```bash
# Check input versions
nix flake show

# Update specific input
nix flake update input-name
```

#### Build Failures
```bash
# Check build logs
nix build --verbose

# Validate flake
nix flake check
```

### Debugging Tips

1. **Use verbose output**:
   ```bash
   nix flake update --verbose
   ```

2. **Check flake metadata**:
   ```bash
   nix flake metadata
   ```

3. **Validate configuration**:
   ```bash
   nixos-rebuild dry-activate
   ```

## 📖 Additional Resources

- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Nix Flakes RFC](https://github.com/NixOS/rfcs/pull/49)
- [NixOS Manual - Flakes](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html)
- [Flake Templates](https://github.com/NixOS/templates)

## 🤝 Contributing

When adding new flake templates:

1. **Follow the existing pattern** in `templates/generic-flake.nix`
2. **Add documentation** for the template
3. **Test the template** before committing
4. **Update this README** with new examples

---

**Need help with flakes?** Check the troubleshooting section or create an issue on GitHub.
