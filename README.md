# NixMod - Modern NixOS Configuration with Hyprland

A comprehensive NixOS desktop environment configuration centered around the Hyprland Wayland compositor, featuring modern tooling, beautiful theming, and developer-friendly utilities.

**⚠️ IMPORTANT: This project has been separated into two repositories for better maintainability and user experience.**

[![NixOS](https://img.shields.io/badge/NixOS-23.11-blue.svg)](https://nixos.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green.svg)](https://hyprland.org/)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-orange.svg)](https://nixos.wiki/wiki/Flakes)

## 📁 **Current Repository Structure**

This project is organized into separate components for better maintainability:

### **🔧 nixmod-system/** - NixOS System Configuration
- **Purpose**: System-level NixOS configuration
- **Scope**: Packages, services, system settings, hardware configuration
- **Target**: `/etc/nixos/` directory
- **Management**: NixOS rebuild commands

### **🎨 nixmod-dotfiles/** - User Configuration Files
- **Purpose**: User application configurations
- **Scope**: `.config` files, themes, application settings
- **Target**: `~/.config/` directory
- **Management**: Symlink-based deployment via toolkit

### **🛠️ toolkit/** - Management Scripts
- **Purpose**: Installation and maintenance utilities
- **Scope**: Scripts for system management, configuration deployment, wallpaper management
- **Target**: Local system management
- **Management**: Direct script execution

## 🚀 **Quick Start (Current Structure)**

### **1. Install System Configuration**
```bash
# Clone the repository
git clone https://github.com/yourusername/nixmod.git
cd nixmod

# Install the system configuration
sudo ./toolkit/nixmod.sh install
```

### **2. Install User Dotfiles**
```bash
# Install user configurations by creating individual symlinks for all discovered apps
sudo ./toolkit/nixmod.sh install-dotfiles
```
This automatically discovers all configuration directories in `nixmod-dotfiles/` and creates individual symlinks for each one in your `~/.config/` directory.

### **3. Update Paths (if needed)**
```bash
# Update hardcoded paths for your username
./toolkit/dotfiles.sh update-paths /home/yourusername
```


## 📚 **Documentation**

- **[System Configuration](nixmod-system/README.md)** - NixOS system setup and management
- **[User Dotfiles](nixmod-dotfiles/README.md)** - Application configurations and theming
- **[Toolkit](toolkit/README.md)** - Management scripts and utilities

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


## 📁 **Current Project Structure**

### **System Configuration (`nixmod-system/`)**
```
nixmod-system/
├── README.md                     # System configuration documentation
├── flake.nix                     # Nix flake configuration
├── configuration.nix             # Main system configuration
├── hardware-configuration.nix    # Hardware-specific settings
├── nvidia-configuration.nix      # NVIDIA driver configuration
├── unixkit.nix                   # UnixKit integration
├── playwrightConfig.nix          # Playwright configuration
├── modules/                      # Modular configuration components
│   ├── desktop/                  # Desktop environment modules
│   │   ├── hyprland.nix         # Hyprland configuration
│   │   └── terminals.nix        # Terminal configurations
│   ├── programs/                 # Application configurations
│   │   ├── applications.nix     # General applications
│   │   └── development.nix      # Development tools
│   ├── system/                   # System-level configurations
│   │   ├── audio.nix            # Audio system
│   │   ├── boot.nix             # Boot configuration
│   │   ├── fonts.nix            # Font configuration
│   │   ├── locale.nix           # Locale settings
│   │   ├── networking.nix       # Network configuration
│   │   └── power.nix            # Power management
│   └── users/                    # User management
│       └── nikmen.nix           # User configuration
├── overlays/                     # Custom package overlays
│   └── flameshot.nix            # Flameshot overlay
└── README.md                     # Module documentation
```

### **User Dotfiles (`nixmod-dotfiles/`)**
```
nixmod-dotfiles/
├── README.md                     # Dotfiles documentation
├── hypr/                         # Hyprland ecosystem
│   ├── hyprland.conf            # Main Hyprland config
│   ├── hypridle.conf            # Idle management
│   ├── hyprlock.conf            # Lock screen
│   ├── hyprpaper.conf           # Wallpaper management
│   └── last_wallpaper.txt       # Wallpaper tracking
├── waybar/                       # Status bar
│   ├── config                   # Main configuration
│   ├── style.css                # Custom styling
│   ├── macchiato.css            # Catppuccin theme
│   └── scripts/
│       └── exit_menu.sh         # Exit menu script
├── kitty/                        # Kitty terminal
│   ├── kitty.conf               # Main configuration
│   ├── theme.conf               # Theme settings
│   ├── splits.conf              # Split configurations
│   └── custom-hints.conf        # Custom key hints
├── ghostty/                      # Ghostty terminal
│   └── config                   # Terminal configuration
├── wofi/                         # Application launcher
│   ├── config                   # Main configuration
│   └── style.css                # Styling
├── wlogout/                      # Logout menu
│   ├── layout                   # Layout configuration
│   └── style.css                # Styling
├── superfile/                    # File manager
│   └── superfile/               # Superfile configuration
│       ├── config.toml          # Main configuration
│       ├── hotkeys.toml         # Keybindings
│       └── theme/               # Theme collection
├── neofetch/                     # System information
│   ├── config.conf              # Neofetch configuration
│   ├── asciiLogo.txt            # Custom ASCII art
│   └── Atom.ascii               # Atom logo
├── clipse/                       # Clipboard manager
│   ├── config.json              # Main configuration
│   └── custom_theme.json        # Custom theme
└── cava/                         # Audio visualizer
    ├── config                   # Main configuration
    └── shaders/                 # Custom shaders
```

### **Management Toolkit (`toolkit/`)**
```
toolkit/
├── README.md                     # Toolkit documentation
├── nixmod.sh                    # Main management script
├── dotfiles.sh                  # Dotfiles management (install, sync, status)
├── wallpaper.sh                 # Wallpaper management (set, random)
├── helper.sh                    # Helper utilities
├── add-flake.sh                 # Flake management
└── update-unixkit.sh            # UnixKit updates
```

## 🔧 Configuration

### Core Components

| Component | Description | Configuration File |
|-----------|-------------|-------------------|
| **Hyprland** | Wayland compositor | `nixmod-dotfiles/hypr/hyprland.conf` |
| **Waybar** | Status bar | `nixmod-dotfiles/waybar/config` |
| **Kitty** | Terminal emulator | `nixmod-dotfiles/kitty/kitty.conf` |
| **Wofi** | Application launcher | `nixmod-dotfiles/wofi/config` |
| **Hyprlock** | Lock screen | `nixmod-dotfiles/hypr/hyprlock.conf` |

### Customization Guide

#### Changing Themes
1. **Waybar Theme**: Edit `nixmod-dotfiles/waybar/style.css`
2. **Hyprland Colors**: Modify `nixmod-dotfiles/hypr/hyprland.conf`
3. **Terminal Theme**: Update `nixmod-dotfiles/kitty/theme.conf`

#### Adding Applications
1. Edit `nixmod-system/modules/programs/applications.nix`
2. Add packages to `environment.systemPackages`
3. Rebuild: `sudo nixos-rebuild switch --flake .#nixos`

#### Keyboard Shortcuts
- **Super + D**: Application launcher
- **Super + Enter**: Terminal
- **Super + Q**: Close window
- **Super + Shift + Q**: Quit Hyprland
- **Super + 1-9**: Switch workspaces
- **Super + Shift + 1-9**: Move window to workspace

## 🛠️ **Management Tools (Current Structure)**

### **System Configuration Management**

```bash
# System configuration management
cd nixmod-system
sudo ../toolkit/nixmod.sh [command]

# Available commands:
# install           - Install system configuration
# update            - Update system
# test              - Test configuration
# status            - Show system status
# backup            - Create backup
# flake-update      - Update flake inputs
```

### **User Dotfiles Management**

```bash
# Dotfiles management via toolkit
sudo ./toolkit/nixmod.sh install-dotfiles    # Create individual symlinks for all discovered apps
sudo ./toolkit/nixmod.sh dotfiles-status     # Check individual symlink status for all apps
sudo ./toolkit/nixmod.sh sync-dotfiles       # Sync changes back to repository

# Direct dotfiles management
./toolkit/dotfiles.sh [command]

# Available commands:
# install [CONFIG]  - Install all or specific dotfiles
# sync [CONFIG]     - Sync all or specific configs
# list              - List available configurations
# status            - Check dotfiles status
# check             - Check for changes
# update-paths      - Update hardcoded paths
```

### **Toolkit Utilities**

```bash
# Main management script
./toolkit/nixmod.sh [command]

# Dotfiles management
./toolkit/dotfiles.sh [command]

# Wallpaper management
./toolkit/wallpaper.sh [command] [wallpaper-path]

# Helper utilities
./toolkit/helper.sh [command]

# Flake management
./toolkit/add-flake.sh [options]

# UnixKit updates
./toolkit/update-unixkit.sh
```

## 🔄 **Updates (Current Structure)**

### **Updating System Configuration**

```bash
# Update system configuration
cd nixmod-system
git pull
sudo ../toolkit/nixmod.sh update

# Or update flake inputs
sudo ../toolkit/nixmod.sh flake-update
```

### **Updating User Dotfiles**

```bash
# Update dotfiles via toolkit (recreates individual symlinks for all discovered apps)
sudo ./toolkit/nixmod.sh install-dotfiles

# Or update directly
cd nixmod-dotfiles
git pull
./toolkit/dotfiles.sh install

# Sync changes back to repository
sudo ./toolkit/nixmod.sh sync-dotfiles
# Or directly: ./toolkit/dotfiles.sh sync
```

### **Updating Toolkit**

```bash
# Update toolkit scripts
cd toolkit
git pull

# Update UnixKit
./update-unixkit.sh
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
