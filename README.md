# NixMod - Modern NixOS Configuration with Hyprland

A comprehensive NixOS desktop environment configuration centered around the Hyprland Wayland compositor, featuring modern tooling, beautiful theming, and developer-friendly utilities.

[![NixOS](https://img.shields.io/badge/NixOS-23.11-blue.svg)](https://nixos.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green.svg)](https://hyprland.org/)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-orange.svg)](https://nixos.wiki/wiki/Flakes)

## ✨ Features

### 🖥️ **Desktop Environment**
- **Hyprland**: Modern tiling Wayland compositor with custom animations and theming
- **Waybar**: Dual-bar status system with Catppuccin Macchiato theme
- **Dynamic Wallpapers**: Automated wallpaper rotation with hyprpaper
- **Interactive Lock Screen**: Media controls and system information on lock screen
- **Application Launcher**: Wofi with custom styling

### 🛠️ **Development Tools**
- **Multiple Terminals**: Kitty, Ghostty, and Alacritty with custom configurations
- **Text Editors**: Helix editor with language server support
- **Version Control**: Git with custom configuration
- **Containerization**: Docker and Podman support
- **UnixKit**: Custom utility scripts with automatic updates via flakes

### 🎵 **Media & Communication**
- **Browsers**: Firefox and Google Chrome
- **Music**: Spotify with Spicetify theming
- **Video**: FreeTube (YouTube alternative), Stremio
- **Communication**: WebCord (Discord), Viber
- **Productivity**: Logseq for note-taking

### 🎨 **Customization**
- **Themes**: Catppuccin Macchiato color scheme throughout
- **Icons**: Custom workspace and system icons
- **Animations**: Smooth transitions and effects
- **Keybindings**: Intuitive keyboard shortcuts

## 🚀 Quick Start

### Prerequisites
- NixOS system (or NixOS Live USB)
- Basic knowledge of NixOS and Linux
- Git installed

### Installation

#### Method 1: Flakes (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/nixmod.git
cd nixmod

# Build and activate the configuration
sudo nixos-rebuild switch --flake .#nixos

# Set up user configurations
./toolkit/setup-configs.sh
```

#### Method 2: Traditional NixOS

```bash
# Clone the repository
git clone https://github.com/yourusername/nixmod.git
cd nixmod

# Use the installation script
sudo ./toolkit/nixmod.sh install

# Rebuild the system
sudo nixos-rebuild switch
```

### Post-Installation Setup

1. **Configure User Settings**:
   ```bash
   # Copy configuration files to your home directory
   ./toolkit/setup-configs.sh
   ```

2. **Customize Paths**:
   - Update wallpaper paths in `extConfig/hypr/hyprlock.conf`
   - Modify user-specific paths in configuration files

3. **First Boot**:
   - Log in with your user account
   - Hyprland will start automatically
   - Use `Super + D` to open the application launcher

## 📁 Project Structure

```
nixmod/
├── configuration.nix              # Main system configuration
├── hardware-configuration.nix     # Hardware-specific settings
├── nvidia-configuration.nix       # NVIDIA driver configuration
├── unixkit.nix                   # UnixKit integration
├── flake.nix                     # Nix flake configuration
├── modules/                      # Modular configuration components
│   ├── desktop/                  # Desktop environment modules
│   ├── programs/                 # Application configurations
│   ├── system/                   # System-level configurations
│   └── users/                    # User management
├── extConfig/                    # Application configuration files
│   ├── hypr/                     # Hyprland and related tools
│   ├── waybar/                   # Status bar configuration
│   ├── kitty/                    # Terminal configuration
│   └── ...                       # Other application configs
├── toolkit/                      # Management and utility scripts
└── overlays/                     # Custom package overlays
```

## 🔧 Configuration

### Core Components

| Component | Description | Configuration File |
|-----------|-------------|-------------------|
| **Hyprland** | Wayland compositor | `extConfig/hypr/hyprland.conf` |
| **Waybar** | Status bar | `extConfig/waybar/config` |
| **Kitty** | Terminal emulator | `extConfig/kitty/kitty.conf` |
| **Wofi** | Application launcher | `extConfig/wofi/config` |
| **Hyprlock** | Lock screen | `extConfig/hypr/hyprlock.conf` |

### Customization Guide

#### Changing Themes
1. **Waybar Theme**: Edit `extConfig/waybar/style.css`
2. **Hyprland Colors**: Modify `extConfig/hypr/hyprland.conf`
3. **Terminal Theme**: Update `extConfig/kitty/theme.conf`

#### Adding Applications
1. Edit `modules/programs/applications.nix`
2. Add packages to `environment.systemPackages`
3. Rebuild: `sudo nixos-rebuild switch --flake .#nixos`

#### Keyboard Shortcuts
- **Super + D**: Application launcher
- **Super + Enter**: Terminal
- **Super + Q**: Close window
- **Super + Shift + Q**: Quit Hyprland
- **Super + 1-9**: Switch workspaces
- **Super + Shift + 1-9**: Move window to workspace

## 🛠️ Management Tools

### NixMod Toolkit

The `toolkit/` directory contains scripts for managing your configuration:

```bash
# Main management script
./toolkit/nixmod.sh [command]

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
# System maintenance
./toolkit/helper.sh health    # Check system health
./toolkit/helper.sh clean     # Clean Nix store
./toolkit/helper.sh sync-dotfiles  # Sync configurations
```

## 🔄 Updates

### Updating the System

```bash
# Update flake inputs (recommended)
nix flake update
sudo nixos-rebuild switch --flake .#nixos

# Or use the toolkit
sudo ./toolkit/nixmod.sh flake-update
```

### Updating UnixKit

UnixKit is automatically updated when you update flake inputs:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

## 🐛 Troubleshooting

### Common Issues

#### Hyprland Not Starting
```bash
# Check logs
journalctl --user -u hyprland

# Verify Wayland session
echo $XDG_SESSION_TYPE
```

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

## 📸 Screenshots

![Desktop Overview](https://github.com/user-attachments/assets/49d490d7-0cd4-4823-a911-9ca77b2f0ce0)

![Application Launcher](https://github.com/user-attachments/assets/f8c25395-2a8a-4e65-a461-802c2fc422da)

![Lock Screen](https://github.com/user-attachments/assets/5523ae28-f98a-4bb9-9262-dc831d20e746)

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
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful color palette
- [UnixKit](https://github.com/nikitasmen/UnixKit) - Custom utility scripts

## 📞 Support

- **GitHub Issues**: [Create an issue](https://github.com/yourusername/nixmod/issues)
- **Discord**: Join our community server
- **Documentation**: Check the [Wiki](https://github.com/yourusername/nixmod/wiki)

---

**Made with ❤️ for the NixOS community**


