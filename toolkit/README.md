# NixMod Toolkit

A comprehensive collection of tools for installing, managing, and maintaining your NixOS configuration with NixMod.

## 🛠️ Available Tools

### `nixmod.sh` - Main Management Script

The primary script for managing your NixOS configuration installation and updates.

```bash
./toolkit/nixmod.sh [command] [options]
```

#### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `install` | Install the configuration to the system | `sudo ./toolkit/nixmod.sh install` |
| `update` | Update the system with current configuration | `sudo ./toolkit/nixmod.sh update` |
| `test` | Test configuration without applying changes | `./toolkit/nixmod.sh test` |
| `status` | Show current system status and health | `./toolkit/nixmod.sh status` |
| `backup` | Create backup of current configuration | `sudo ./toolkit/nixmod.sh backup` |
| `flake-init` | Initialize flake configuration | `./toolkit/nixmod.sh flake-init` |
| `flake-update` | Update flake inputs to latest versions | `./toolkit/nixmod.sh flake-update` |
| `help` | Show help message and available commands | `./toolkit/nixmod.sh help` |

#### Examples

```bash
# Install NixMod on a new system
sudo ./toolkit/nixmod.sh install

# Update system with latest configuration
sudo ./toolkit/nixmod.sh update

# Test configuration before applying
./toolkit/nixmod.sh test

# Update flake inputs and rebuild
sudo ./toolkit/nixmod.sh flake-update
```

### `helper.sh` - Maintenance Utilities

A collection of utility scripts for system maintenance and configuration management.

```bash
./toolkit/helper.sh [command] [options]
```

#### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `health` | Check system health (disk, memory, etc.) | `./toolkit/helper.sh health` |
| `clean` | Clean Nix store and remove old generations | `sudo ./toolkit/helper.sh clean` |
| `sync-dotfiles` | Sync dotfiles from home to repository | `./toolkit/helper.sh sync-dotfiles` |
| `create-module` | Create new module template | `./toolkit/helper.sh create-module NAME` |
| `setup-configs` | Set up user configuration files | `./toolkit/helper.sh setup-configs` |
| `validate` | Validate configuration syntax | `./toolkit/helper.sh validate` |

#### Examples

```bash
# Check system health
./toolkit/helper.sh health

# Clean up old Nix generations
sudo ./toolkit/helper.sh clean

# Create a new module
./toolkit/helper.sh create-module my-custom-app

# Set up user configurations
./toolkit/helper.sh setup-configs
```

### `dotfiles.sh` - Dotfiles Management

Script for installing, syncing, and managing user dotfiles from `nixmod-dotfiles/`.

```bash
./toolkit/dotfiles.sh [command] [config-name]
```

#### Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `install` | Install all or specific dotfiles (symlinks) | `./toolkit/dotfiles.sh install` or `./toolkit/dotfiles.sh install hypr` |
| `sync` | Sync configs from ~/.config back to nixmod-dotfiles | `./toolkit/dotfiles.sh sync` |
| `list` | List available configurations | `./toolkit/dotfiles.sh list` |
| `status` | Check dotfiles symlink status | `./toolkit/dotfiles.sh status` |
| `update-paths` | Update hardcoded paths for another user | `./toolkit/dotfiles.sh update-paths /home/username` |
| `help` | Show help message | `./toolkit/dotfiles.sh help` |

#### Examples

```bash
# Install all dotfiles
./toolkit/dotfiles.sh install

# Install only Hyprland config
./toolkit/dotfiles.sh install hypr

# Sync changes back to repo
./toolkit/dotfiles.sh sync

# Update paths for another user
./toolkit/dotfiles.sh update-paths /home/newuser
```

### `add-flake.sh` - Flake Management

Script for adding new flake inputs to your configuration.

```bash
./toolkit/add-flake.sh [flake-url] [flake-name]
```

#### Examples

```bash
# Add a new flake input
./toolkit/add-flake.sh github:owner/repo my-flake

# Add with specific branch
./toolkit/add-flake.sh github:owner/repo/branch my-flake
```

### `update-unixkit.sh` - UnixKit Updates

Script for updating UnixKit utility scripts.

```bash
./toolkit/update-unixkit.sh
```

#### Examples

```bash
# Update UnixKit to latest version
./toolkit/update-unixkit.sh

# Check for updates
./toolkit/update-unixkit.sh --check
```

## 🚀 Quick Start Guide

### First-Time Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nikitasmen/Nixmod.git
   cd Nixmod
   ```

2. **Install the configuration**:
   ```bash
   sudo ./toolkit/nixmod.sh install
   ```

3. **Set up user configurations**:
   ```bash
   ./toolkit/helper.sh setup-configs
   ```

4. **Rebuild the system**:
   ```bash
   sudo nixos-rebuild switch
   ```

### Daily Usage

#### Updating Your System

```bash
# Update using flakes (recommended)
sudo ./toolkit/nixmod.sh flake-update

# Or traditional method
sudo ./toolkit/nixmod.sh update
```

#### System Maintenance

```bash
# Check system health
./toolkit/helper.sh health

# Clean up old generations
sudo ./toolkit/helper.sh clean

# Sync your changes back to repo
./toolkit/helper.sh sync-dotfiles
```

## 📋 Workflow Examples

### Adding a New Application

1. **Create a new module**:
   ```bash
   ./toolkit/helper.sh create-module my-app
   ```

2. **Edit the module** in `modules/programs/my-app.nix`

3. **Test the configuration**:
   ```bash
   ./toolkit/nixmod.sh test
   ```

4. **Apply the changes**:
   ```bash
   sudo ./toolkit/nixmod.sh update
   ```

### Customizing Your Setup

1. **Modify configuration files** in `nixmod-dotfiles/`

2. **Set up user configs**:
   ```bash
   ./toolkit/helper.sh setup-configs
   ```

3. **Test changes**:
   ```bash
   ./toolkit/helper.sh validate
   ```

4. **Sync changes to repo**:
   ```bash
   ./toolkit/helper.sh sync-dotfiles
   ```

### Wallpaper Management

```bash
# Set a new wallpaper (script lives in nixmod-dotfiles/hypr)
./nixmod-dotfiles/hypr/set-wallpaper.sh /path/to/new/wallpaper.jpg

# Or if dotfiles are installed: ~/.config/hypr/set-wallpaper.sh
```

### UnixKit Updates

```bash
# Update UnixKit utilities
./toolkit/update-unixkit.sh

# Check for available updates
./toolkit/update-unixkit.sh --check
```

### Backup and Recovery

```bash
# Create a backup
sudo ./toolkit/nixmod.sh backup

# List available generations
nix-env --list-generations -p /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
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
