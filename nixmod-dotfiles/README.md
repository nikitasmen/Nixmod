# NixMod Dotfiles

User configuration files for applications and desktop environment components. This repository contains all the `.config` files that are not managed by NixOS but need to be deployed to user directories.

## ✨ Features

### 🖥️ **Desktop Environment**
- **Hyprland**: Complete Hyprland configuration with animations and theming
- **Waybar**: Dual-bar status system with Catppuccin Macchiato theme
- **Dynamic Wallpapers**: Automated wallpaper rotation with hyprpaper
- **Interactive Lock Screen**: Media controls and system information on lock screen
- **Application Launcher**: Wofi with custom styling
- **Logout Menu**: Wlogout with custom styling

### 🛠️ **Terminal & Development**
- **Multiple Terminals**: Kitty, Ghostty configurations
- **File Manager**: Superfile with extensive theme collection
- **System Information**: Neofetch with custom ASCII art
- **Clipboard Manager**: Clipse with custom theming

### 🎵 **Audio & Visual**
- **Audio Visualizer**: Cava with custom shaders and themes

### 🎨 **Customization**
- **Themes**: Catppuccin Macchiato color scheme throughout
- **Icons**: Custom workspace and system icons
- **Animations**: Smooth transitions and effects
- **Keybindings**: Intuitive keyboard shortcuts

## 🚀 Quick Start

### Prerequisites
- NixOS system with NixMod system configuration installed
- Git installed
- Basic knowledge of Linux configuration

### Installation
NixMod dotfiles are managed natively via **Home Manager**.

1. Rebuild your NixOS system:
   ```bash
   sudo ./toolkit/nixmod.sh update
   ```
   This will automatically deploy all configurations to `~/.config` using Home Manager.

## 📁 Project Structure

```
nixmod-dotfiles/
├── README.md
├── .gitignore
├── hypr/                      # Hyprland ecosystem
│   ├── hyprland.conf         # Main Hyprland config
│   ├── hypridle.conf         # Idle management
│   ├── hyprlock.conf         # Lock screen
│   ├── hyprpaper.conf        # Wallpaper management
│   ├── last_wallpaper.txt    # Wallpaper tracking
│   ├── random-wallpaper.sh   # Wallpaper rotation
│   └── set-wallpaper.sh      # Wallpaper setting
├── waypaper/                 # GUI Wallpaper utility
│   └── config.ini            # Configuration for waypaper
├── waybar/                   # Status bar
│   ├── config                # Main configuration
│   ├── style.css             # Custom styling
│   ├── macchiato.css         # Catppuccin theme
│   └── scripts/
│       ├── exit_menu.sh      # Exit menu script
│       ├── media.sh          # Media player status
│       ├── webcam.sh         # Webcam status
│       ├── recording.sh      # Recording indicator
│       ├── geo.sh            # Location services
│       └── user-uptime.sh    # User/uptime display
├── kitty/                    # Kitty terminal
│   ├── kitty.conf            # Main configuration
│   ├── theme.conf            # Theme settings
│   ├── splits.conf           # Split configurations
│   └── custom-hints.py      # Custom key hints (URL/path selection)
├── ghostty/                  # Ghostty terminal
│   └── config                # Terminal configuration
├── wofi/                     # Application launcher
│   ├── config                # Main configuration
│   └── style.css             # Styling
├── wlogout/                  # Logout menu
│   ├── layout                # Layout configuration
│   └── style.css             # Styling
├── superfile/                # File manager
│   └── superfile/            # Superfile configuration
│       ├── config.toml       # Main configuration
│       ├── hotkeys.toml      # Keybindings
│       └── theme/            # Theme collection
│           ├── ayu-dark.toml
│           ├── blood.toml
│           ├── catppuccin-frappe.toml
│           ├── catppuccin-latte.toml
│           ├── catppuccin-macchiato.toml
│           ├── catppuccin.toml
│           ├── dracula.toml
│           ├── everforest-dark-medium.toml
│           ├── gruvbox.toml
│           ├── hacks.toml
│           ├── kaolin.toml
│           ├── monokai.toml
│           ├── nord.toml
│           ├── onedark.toml
│           ├── poimandres.toml
│           ├── rose-pine.toml
│           ├── sugarplum.toml
│           └── tokyonight.toml
├── neofetch/                 # System information
│   ├── config.conf           # Neofetch configuration
│   ├── asciiLogo.txt         # Custom ASCII art
│   └── Atom.ascii            # Atom logo
├── clipse/                   # Clipboard manager
│   ├── config.json           # Main configuration
│   └── custom_theme.json     # Custom theme
├── cava/                     # Audio visualizer
│   ├── config                # Main configuration
│   └── shaders/              # Custom shaders
│       ├── bar_spectrum.frag
│       ├── northern_lights.frag
│       ├── pass_through.vert
│       ├── spectrogram.frag
│       └── winamp_line_style_spectrum.frag
```

> **Note:** Install, sync, and update-paths are run from the main Nixmod repo via `./toolkit/dotfiles.sh` (run from repo root).

## 🔧 Configuration

### Core Components

| Component | Description | Configuration File |
|-----------|-------------|-------------------|
| **Hyprland** | Wayland compositor | `hypr/hyprland.conf` |
| **Waybar** | Status bar | `waybar/config` |
| **Kitty** | Terminal emulator | `kitty/kitty.conf` |
| **Ghostty** | Terminal emulator | `ghostty/config` |
| **Wofi** | Application launcher | `wofi/config` |
| **Wlogout** | Logout menu | `wlogout/layout` |
| **Hyprlock** | Lock screen | `hypr/hyprlock.conf` |
| **Superfile** | File manager | `superfile/superfile/config.toml` |
| **Neofetch** | System information | `neofetch/config.conf` |
| **Clipse** | Clipboard manager | `clipse/config.json` |
| **Cava** | Audio visualizer | `cava/config` |

### Customization Guide

#### Changing Themes
1. **Waybar Theme**: Edit `waybar/style.css`
2. **Hyprland Colors**: Modify `hypr/hyprland.conf`
3. **Terminal Theme**: Update `kitty/theme.conf`
4. **Superfile Theme**: Change theme in `superfile/superfile/config.toml`

#### Path Customization
Many configuration files contain hardcoded paths that need to be updated. Run from the **main Nixmod repo root**:

```bash
# Update paths in all configuration files
./toolkit/dotfiles.sh update-paths /home/yourusername

# Or update to current user's home
./toolkit/dotfiles.sh update-paths
```

#### Keyboard Shortcuts
- **Super + D**: Application launcher
- **Super + Enter**: Terminal
- **Super + Q**: Close window
- **Super + Shift + Q**: Quit Hyprland
- **Super + 1-9**: Switch workspaces
- **Super + Shift + 1-9**: Move window to workspace

## 🛠️ Management Tools

Dotfiles are managed via `toolkit/dotfiles.sh` from the **main Nixmod repo root**:

### Installation

```bash
# Install all configurations
./toolkit/dotfiles.sh install

# Install specific configuration
./toolkit/dotfiles.sh install hypr
./toolkit/dotfiles.sh install waybar
./toolkit/dotfiles.sh install kitty
./toolkit/dotfiles.sh install ghostty
./toolkit/dotfiles.sh install wofi
./toolkit/dotfiles.sh install wlogout
./toolkit/dotfiles.sh install superfile
./toolkit/dotfiles.sh install neofetch
./toolkit/dotfiles.sh install clipse
./toolkit/dotfiles.sh install cava
```

### Synchronization

```bash
# Sync changes back to repository (from ~/.config to nixmod-dotfiles)
./toolkit/dotfiles.sh sync

# Sync specific configuration
./toolkit/dotfiles.sh sync hypr
./toolkit/dotfiles.sh sync waybar
```

### Path Update

```bash
# Update hardcoded paths for another user
./toolkit/dotfiles.sh update-paths /home/username

# Update to current user's home
./toolkit/dotfiles.sh update-paths
```

## 🔄 Updates

### Updating Configurations

```bash
# From main Nixmod repo root
git pull origin main

# Reinstall configurations
./toolkit/dotfiles.sh install

# Or update specific configurations
./toolkit/dotfiles.sh install hypr waybar kitty ghostty wofi wlogout superfile neofetch clipse cava
```

### Syncing Changes

```bash
# Sync changes from ~/.config back to nixmod-dotfiles
./toolkit/dotfiles.sh sync

# Commit and push changes
git add .
git commit -m "Update configurations"
git push origin main
```

## 🐛 Troubleshooting

### Common Issues

#### Configuration Not Applied
```bash
# Check if configuration is loaded
ls -la ~/.config/application/

# Verify file permissions
chmod 644 ~/.config/application/config.conf

# Restart application
pkill application-name
application-name &
```

#### Path Issues
```bash
# Find and replace paths
find ~/.config -name "*.conf" -exec sed -i 's|old/path|new/path|g' {} \;

# Check for broken symlinks
find ~/.config -type l -exec test ! -e {} \; -print
```

#### Permission Issues
```bash
# Fix permissions
chmod -R 755 ~/.config/
chown -R $USER:$USER ~/.config/
```

### Debugging Tips

1. **Check application logs**:
   ```bash
   journalctl --user -u application-name
   ```

2. **Test configuration syntax**:
   ```bash
   # For JSON files
   jq . ~/.config/application/config.json

   # For TOML files
   toml validate ~/.config/application/config.toml
   ```

3. **Validate configuration**:
   ```bash
   # Test without applying
   application-name --config ~/.config/application/config.conf --dry-run
   ```

## 📚 Additional Resources

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Waybar Documentation](https://github.com/Alexays/Waybar/wiki)
- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Superfile Documentation](https://github.com/MHNightCat/superfile)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Test your configurations
5. Commit your changes: `git commit -m 'Update feature'`
6. Push to the branch: `git push origin feature-name`
7. Submit a pull request

### Development Guidelines

- Test changes before committing
- Update documentation for new features
- Use consistent formatting and style
- Add comments for complex configurations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - The amazing Wayland compositor
- [Catppuccin](https://github.com/catppuccin/catppuccin) - Beautiful color palette
- [NixOS](https://nixos.org/) - The declarative Linux distribution

## 📞 Support

- **GitHub Issues**: [Create an issue](https://github.com/nikitasmen/Nixmod/issues)
- **Documentation**: Check the [Wiki](https://github.com/nikitasmen/Nixmod/wiki)

---

**Made with ❤️ for the NixOS community**
