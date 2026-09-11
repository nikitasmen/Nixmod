# NixMod System Configuration

A comprehensive NixOS system configuration with Hyprland, modern tooling, and developer-friendly utilities.

[![NixOS](https://img.shields.io/badge/NixOS-23.11-blue.svg)](https://nixos.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green.svg)](https://hyprland.org/)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-orange.svg)](https://nixos.wiki/wiki/Flakes)

## ✨ Features

### 🖥️ **System Configuration**
- **NixOS**: Declarative system configuration with flakes
- **Hyprland**: Modern tiling Wayland compositor
- **Pipewire**: Modern audio system
- **Modular Design**: Clean separation of system components
- **UnixKit Integration**: Custom utility scripts

### 🛠️ **Development Tools**
- **Multiple Terminals**: Kitty, Ghostty, and Alacritty support
- **Text Editors**: Helix editor with language server support
- **Version Control**: Git with custom configuration
- **Containerization**: Docker and Podman support

### 🎵 **Media & Communication**
- **Browsers**: Firefox and Google Chrome
- **Music**: Spotify with Spicetify (TUI-style text theme, Catppuccin Macchiato, top artists/tracks/genres stats, listening history)
- **Video**: FreeTube (YouTube alternative)
- **Communication**: WebCord (Discord), Viber
- **Productivity**: Logseq for note-taking

## 🚀 Quick Start

### Prerequisites
- NixOS system (or NixOS Live USB)
- Basic knowledge of NixOS and Linux
- Git installed

## ⚠️ Hardware Configuration (New Machines)

`hardware-configuration.nix` and `nvidia-configuration.nix` contain **machine-specific** data (disk UUIDs, GPU bus IDs for NVIDIA Prime). When setting up a different machine:

```bash
sudo nixos-generate-config
# Merge or replace hardware-configuration.nix and nvidia-configuration.nix with the generated output
```

Do not copy these files directly to another machine—they will break boot or graphics.

## 📁 Project Structure

```
nixmod-system/
├── README.md                     # This documentation
├── flake.nix                     # Nix flake configuration
├── configuration.nix             # Main system configuration
├── hardware-configuration.nix    # Hardware-specific settings
├── nvidia-configuration.nix      # NVIDIA driver configuration
├── unixkit.nix                   # UnixKit integration
├── playwrightConfig.nix          # Playwright configuration
├── modules/                      # Modular configuration components
│   ├── default.nix              # Module imports
│   ├── desktop/                 # Desktop environment modules
│   │   ├── default.nix          # Desktop module imports
│   │   ├── hyprland.nix         # Hyprland configuration
│   │   └── terminals.nix        # Terminal configurations
│   ├── programs/                # Application configurations
│   │   ├── default.nix          # Program module imports
│   │   ├── applications.nix     # General applications
│   │   ├── development.nix      # Development tools
│   │   └── spicetify.nix        # Spotify theming & statistics
│   ├── system/                  # System-level configurations
│   │   ├── default.nix          # System module imports
│   │   ├── audio.nix            # Audio system (Pipewire)
│   │   ├── boot.nix             # Boot configuration
│   │   ├── fonts.nix            # Font configuration
│   │   ├── input-remapper.nix   # Mouse/key remapping (extra buttons)
│   │   ├── locale.nix           # Locale settings
│   │   ├── networking.nix       # Network configuration
│   │   └── power.nix            # Power management
│   ├── users/                   # User management
│   │   ├── default.nix          # User module imports
│   │   └── nikmen.nix           # User configuration
│   └── README.md                # Module documentation
└── overlays/                    # Custom package overlays
    └── flameshot.nix            # Flameshot overlay
```

## 🔧 Configuration

### Core Components

| Component | Description | Configuration File |
|-----------|-------------|-------------------|
| **Hyprland** | Wayland compositor | `modules/desktop/hyprland.nix` |
| **Terminals** | Terminal configurations | `modules/desktop/terminals.nix` |
| **Pipewire** | Audio system | `modules/system/audio.nix` |
| **Fonts** | System fonts | `modules/system/fonts.nix` |
| **Networking** | Network configuration | `modules/system/networking.nix` |
| **Boot** | Boot configuration | `modules/system/boot.nix` |
| **Power** | Power management | `modules/system/power.nix` |
| **Input Remapper** | Mouse/key remapping | `modules/system/input-remapper.nix` |
| **Locale** | Locale settings | `modules/system/locale.nix` |
| **Applications** | General applications | `modules/programs/applications.nix` |
| **Development** | Development tools | `modules/programs/development.nix` |
| **Spicetify** | Spotify theming & statistics | `modules/programs/spicetify.nix` |
| **User Management** | User configuration | `modules/users/nikmen.nix` |

### Customization Guide

#### Adding Applications
1. Edit `modules/programs/applications.nix`
2. Add packages to `environment.systemPackages`
3. Rebuild: `sudo nixos-rebuild switch --flake .#nixos`

#### System Configuration
1. Edit `modules/system/` files for system-level changes
2. Edit `modules/desktop/` files for desktop environment changes
3. Rebuild: `sudo nixos-rebuild switch --flake .#nixos`

## 🛠️ Management Tools

### NixMod Toolkit

The `toolkit/` directory contains scripts for managing your configuration:

```bash
# Main management script (run from parent directory)
../toolkit/nixmod.sh [command]

# Available commands:
# install    - Install configuration
# update     - Update system
# test       - Test configuration
# status     - Show system status
# backup     - Create backup
# flake-update - Update flake inputs
```

### Helper Scripts

```bash
# System maintenance (run from parent directory)
../toolkit/helper.sh health    # Check system health
../toolkit/helper.sh clean     # Clean Nix store
../toolkit/helper.sh sync-dotfiles  # Sync configurations
```

### Flake Management

```bash
# Add new flake input
../toolkit/add-flake.sh [flake-url] [flake-name]

# Update flake inputs
../toolkit/nixmod.sh flake-update
```

## 🔄 Updates

### Updating the System

```bash
# Update flake inputs (recommended)
nix flake update
sudo nixos-rebuild switch --flake .#nixos

# Or use the toolkit
sudo ../toolkit/nixmod.sh flake-update

# Update system configuration
sudo ../toolkit/nixmod.sh update
```

## 🐛 Troubleshooting

### Common Issues

#### Configuration Not Applied
```bash
# Check for syntax errors
nixos-rebuild dry-activate

# Validate flake
nix flake check
```

#### Missing Applications
```bash
# Rebuild with verbose output
sudo nixos-rebuild switch --flake .#nixos --verbose

# Check package availability
nix search nixpkgs package-name
```

### Getting Help

1. **Check Logs**: `journalctl -xe`
2. **NixOS Manual**: `nixos-help`
3. **Hyprland Wiki**: [wiki.hyprland.org](https://wiki.hyprland.org/)
4. **Issues**: Create an issue on GitHub

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test your configuration: `nixos-rebuild dry-activate`
5. Commit your changes: `git commit -m 'Add feature'`
6. Push to the branch: `git push origin feature-name`
7. Submit a pull request

### Development Guidelines

- Follow NixOS best practices
- Test changes before committing
- Update documentation for new features
- Use meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - The amazing Wayland compositor
- [NixOS](https://nixos.org/) - The declarative Linux distribution
- [UnixKit](https://github.com/nikitasmen/UnixKit) - Custom utility scripts

## 📞 Support

- **GitHub Issues**: [Create an issue](https://github.com/nikitasmen/Nixmod/issues)
- **Documentation**: Check the [Wiki](https://github.com/nikitasmen/Nixmod/wiki)

---
