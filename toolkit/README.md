# NixMod Toolkit

This directory contains tools for installing, managing, and maintaining your NixOS configuration.

## Available Tools

### `nixmod.sh` - Main Installation Tool

This script handles the installation and updating of your NixOS configuration.

```bash
./nixmod.sh [command]
```

Commands:
- `install`: Install the configuration to the system
- `update`: Update the system with the current configuration
- `test`: Test the configuration without applying it
- `status`: Show the current system status
- `backup`: Create a backup of the current system configuration
- `flake-init`: Initialize flake configuration
- `flake-update`: Update flake inputs
- `help`: Show the help message

### `helper.sh` - Maintenance Tasks

This script provides useful utilities for maintaining your NixOS system.

```bash
./helper.sh [command]
```

Commands:
- `health`: Check system health (disk space, memory usage, etc.)
- `clean`: Clean the Nix store and remove old generations
- `sync-dotfiles`: Sync dotfiles from your home directory to the repo
- `create-module NAME`: Create a new module template

## Examples

### Installing NixMod on a new system

```bash
# Clone the repository
git clone https://github.com/yourusername/nixmod.git
cd nixmod

# Install the configuration
sudo ./toolkit/nixmod.sh install
```

### Updating your system

```bash
# Update using traditional method
sudo ./toolkit/nixmod.sh update

# If using flakes
sudo ./toolkit/nixmod.sh flake-update
sudo nixos-rebuild switch --flake .#nixos
```

### Creating a new module

```bash
./toolkit/helper.sh create-module my-new-module
```

### Checking system health and cleaning up

```bash
# Check system health
./toolkit/helper.sh health

# Clean up the system
sudo ./toolkit/helper.sh clean
```
