# NixMod Modules

This directory contains the modular configuration components for NixMod. Each module is responsible for a specific aspect of the system configuration.

## 📁 Module Structure

```
modules/
├── README.md              # This file
├── default.nix            # Main module imports
├── desktop/               # Desktop environment modules
│   ├── default.nix        # Desktop module imports
│   ├── hyprland.nix       # Hyprland configuration
│   └── terminals.nix      # Terminal configurations
├── programs/              # Application modules
│   ├── default.nix        # Program module imports
│   ├── applications.nix   # General applications
│   └── development.nix    # Development tools
├── system/                # System-level modules
│   ├── default.nix        # System module imports
│   ├── audio.nix          # Audio configuration
│   ├── boot.nix           # Boot configuration
│   ├── fonts.nix          # Font configuration
│   ├── input-remapper.nix # Mouse/key remapping (extra buttons)
│   ├── locale.nix         # Locale settings
│   ├── networking.nix     # Network configuration
│   └── power.nix          # Power management
└── users/                 # User management modules
    ├── default.nix        # User module imports
    └── nikmen.nix         # User-specific configuration
```

## 🎯 Module Categories

### Desktop Environment (`desktop/`)

Modules responsible for the graphical user interface and desktop experience.

| Module | Description | Key Features |
|--------|-------------|--------------|
| `hyprland.nix` | Hyprland Wayland compositor | Window management, animations, theming |
| `terminals.nix` | Terminal emulators | Kitty, Ghostty, Alacritty configurations |

### Applications (`programs/`)

Modules for user applications and software packages.

| Module | Description | Key Features |
|--------|-------------|--------------|
| `applications.nix` | General applications | Browsers, media players, productivity tools |
| `development.nix` | Development tools | IDEs, compilers, version control |

### System Configuration (`system/`)

Core system-level configuration modules.

| Module | Description | Key Features |
|--------|-------------|--------------|
| `audio.nix` | Audio system | Pipewire, PulseAudio compatibility |
| `boot.nix` | Boot configuration | Bootloader, kernel parameters |
| `fonts.nix` | Font management | System fonts, font configuration |
| `input-remapper.nix` | Input remapping | Extra mouse buttons, key mapping |
| `locale.nix` | Localization | Language, timezone, keyboard layout |
| `networking.nix` | Network setup | NetworkManager, firewall |
| `power.nix` | Power management | Battery, suspend, power policies |

### User Management (`users/`)

User-specific configuration and user account management.

| Module | Description | Key Features |
|--------|-------------|--------------|
| `nikmen.nix` | User configuration | User account, home directory setup |

## 🛠️ Creating New Modules

### Module Template

Use this template for new modules:

```nix
{ config, pkgs, lib, ... }:

{
  # Module description
  _module.args.description = "Description of what this module does";

  # Import other modules if needed
  imports = [
    # ./other-module.nix
  ];

  # Module configuration
  environment.systemPackages = with pkgs; [
    # Packages
  ];

  # Services
  services.example = {
    enable = true;
    # Configuration
  };

  # Programs
  programs.example = {
    enable = true;
    # Configuration
  };

  # System settings
  system.example = {
    # Configuration
  };
}
```

### Adding a New Module

1. **Create the module file**:
   ```bash
   touch modules/category/new-module.nix
   ```

2. **Add to the category's default.nix**:
   ```nix
   { ... }:
   
   {
     imports = [
       ./existing-module.nix
       ./new-module.nix  # Add this line
     ];
   }
   ```

3. **Test the module**:
   ```bash
   nixos-rebuild dry-activate
   ```

4. **Apply the changes**:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

## 🔧 Module Best Practices

### Organization

1. **Keep modules focused** on a single concern
2. **Use descriptive names** for modules and variables
3. **Group related functionality** in the same module
4. **Follow the existing structure** and naming conventions

### Documentation

1. **Add comments** explaining complex configurations
2. **Document module options** with descriptions
3. **Include examples** for common use cases
4. **Update this README** when adding new modules

### Testing

1. **Test modules individually** before committing
2. **Use dry-activate** to validate configuration
3. **Check for conflicts** with other modules
4. **Test on different hardware** when possible

### Dependencies

1. **Minimize dependencies** between modules
2. **Use conditional imports** when appropriate
3. **Handle missing dependencies** gracefully
4. **Document module dependencies** clearly

## 📋 Common Patterns

### Package Management

```nix
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core packages
    package1
    package2
    
    # Optional packages (conditional)
    (lib.mkIf config.services.example.enable package3)
  ];
}
```

### Service Configuration

```nix
{ config, pkgs, ... }:

{
  services.example = {
    enable = true;
    settings = {
      option1 = "value1";
      option2 = "value2";
    };
  };
}
```

### Program Configuration

```nix
{ config, pkgs, ... }:

{
  programs.example = {
    enable = true;
    settings = {
      theme = "dark";
      font = "monospace";
    };
  };
}
```

### Conditional Configuration

```nix
{ config, pkgs, lib, ... }:

{
  # Only enable if another service is enabled
  services.dependent = lib.mkIf config.services.main.enable {
    enable = true;
    # Configuration
  };
}
```

## 🔍 Module Debugging

### Common Issues

#### Module Not Loaded
```bash
# Check if module is imported
nixos-rebuild dry-activate

# Verify module path
ls modules/category/module.nix
```

#### Configuration Conflicts
```bash
# Check for conflicts
nixos-rebuild dry-activate --verbose

# Validate configuration
nix flake check
```

#### Missing Dependencies
```bash
# Check package availability
nix search nixpkgs package-name

# Verify service dependencies
nixos-rebuild dry-activate
```

### Debugging Tips

1. **Use verbose output**:
   ```bash
   nixos-rebuild switch --verbose
   ```

2. **Check module evaluation**:
   ```bash
   nix-instantiate --eval --strict configuration.nix
   ```

3. **Test individual modules**:
   ```bash
   nixos-rebuild dry-activate -I nixos-config=./modules/category/module.nix
   ```

## 📚 Additional Resources

- [NixOS Manual - Modules](https://nixos.org/manual/nixos/stable/#sec-modularity)
- [NixOS Options Search](https://search.nixos.org/options)
- [NixOS Package Search](https://search.nixos.org/packages)
- [NixOS Wiki - Modules](https://nixos.wiki/wiki/Module)

## 🤝 Contributing

When adding new modules:

1. **Follow the existing patterns** and structure
2. **Add proper documentation** and comments
3. **Test thoroughly** before committing
4. **Update this README** with new module information
5. **Consider backward compatibility** when modifying existing modules

---

**Need help with modules?** Check the debugging section or create an issue on GitHub. 