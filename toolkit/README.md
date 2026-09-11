# NixMod Toolkit

A comprehensive collection of tools for installing, managing, and maintaining your NixOS configuration with NixMod. This toolkit is designed to be **DRY (Don't Repeat Yourself)** and stays out of the way of your Nix configuration.

## 🛠️ Available Tools

### `nixmod.sh` - Main Management Script

The primary script for managing your NixOS configuration. It works directly with the local flake in this repository, ensuring that your configuration is always "DRY".

```bash
./toolkit/nixmod.sh [command]
```

#### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `install` | Install/Apply configuration from the local repo | `sudo ./toolkit/nixmod.sh install` |
| `update` | Update the system with current configuration | `sudo ./toolkit/nixmod.sh update` |
| `test` | Test configuration without applying changes | `sudo ./toolkit/nixmod.sh test` |
| `status` | Show current system status and health | `./toolkit/nixmod.sh status` |
| `flake-update` | Update flake inputs to latest versions | `sudo ./toolkit/nixmod.sh flake-update` |
| `help` | Show help message and available commands | `./toolkit/nixmod.sh help` |

### 🎨 Dotfiles Management (Home Manager)

Dotfiles are now managed natively via **Home Manager** in `nixmod-system/modules/users/nikmen-home.nix`. 

- **No manual symlinking**: Nix handles the creation of symlinks in `~/.config`.
- **DRY source**: The source of truth is the `nixmod-dotfiles/` directory in this repository.
- **Automatic updates**: When you rebuild the system with `./toolkit/nixmod.sh update`, your dotfiles are automatically updated.

### `helper.sh` - Maintenance Utilities

A collection of utility scripts for system maintenance.

```bash
./toolkit/helper.sh [command]
```

#### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `health` | Check system health (disk, memory, etc.) | `./toolkit/helper.sh health` |
| `clean` | Clean Nix store and remove old generations | `sudo ./toolkit/helper.sh clean` |
| `create-module` | Create new module template | `./toolkit/helper.sh create-module NAME` |

---

## 🚀 Quick Start

1. **Install System & Dotfiles**:
   ```bash
   sudo ./toolkit/nixmod.sh install
   ```

2. **Update Everything**:
   ```bash
   sudo ./toolkit/nixmod.sh update
   ```

## 🔧 Advanced Usage

### Custom Scripts

You can extend the toolkit by adding your own scripts:

```bash
# Create a custom script
touch ./toolkit/my-custom-script.sh
chmod +x ./toolkit/my-custom-script.sh

# Use it
./toolkit/my-custom-script.sh
```

### Environment Variables

The toolkit respects these environment variables:

- `NIXMOD_CONFIG_PATH` - Path to configuration directory
- `NIXMOD_BACKUP_PATH` - Path for backups
- `NIXMOD_VERBOSE` - Enable verbose output

### Integration with Other Tools

The toolkit can be integrated with other NixOS management tools:

```bash
# Use with home-manager
./toolkit/helper.sh setup-configs && home-manager switch

# Use with nix-darwin (if applicable)
./toolkit/nixmod.sh update && darwin-rebuild switch
```

## 🐛 Troubleshooting

### Common Issues

#### Permission Denied
```bash
# Make scripts executable
chmod +x ./toolkit/*.sh

# Run with sudo if needed
sudo ./toolkit/nixmod.sh install
```

#### Configuration Errors
```bash
# Validate configuration
./toolkit/helper.sh validate

# Test without applying
./toolkit/nixmod.sh test
```

#### Missing Dependencies
```bash
# Check if NixOS is available
which nixos-rebuild

# Install missing tools
nix-env -iA nixpkgs.missing-tool
```

### Getting Help

1. **Check script help**: `./toolkit/nixmod.sh help`
2. **View logs**: `journalctl -xe`
3. **Validate flake**: `nix flake check`
4. **Check NixOS manual**: `nixos-help`

## 📚 Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [NixMod Documentation](https://github.com/nikitasmen/Nixmod/wiki)

---

**Need help?** Create an issue on GitHub or check the troubleshooting section above.
