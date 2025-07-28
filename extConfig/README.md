# External Configuration Files

This directory contains application-specific configuration files that are not managed by NixOS but need to be manually deployed to user directories.

## 📁 Directory Structure

```
extConfig/
├── README.md              # This file
├── clipse/                # Clipse configuration
│   ├── config.json        # Main configuration
│   └── custom_theme.json  # Custom theme
├── ghostty/               # Ghostty terminal
│   └── config             # Terminal configuration
├── hypr/                  # Hyprland ecosystem
│   ├── hypridle.conf      # Idle management
│   ├── hyprland.conf      # Main Hyprland config
│   ├── hyprlock.conf      # Lock screen
│   ├── hyprpaper.conf     # Wallpaper management
│   ├── last_wallpaper.txt # Wallpaper tracking
│   ├── lock-helper.sh     # Lock screen helper
│   └── random-wallpaper.sh # Wallpaper rotation
├── kitty/                 # Kitty terminal
│   ├── custom-hints.conf  # Custom key hints
│   ├── kitty.conf         # Main configuration
│   ├── splits.conf        # Split configurations
│   └── theme.conf         # Theme settings
├── neofetch/              # System information
│   ├── asciiLogo.txt      # Custom ASCII art
│   ├── Atom.ascii         # Atom logo
│   └── config.conf        # Neofetch configuration
├── superfile/             # File manager
│   └── superfile/         # Superfile configuration
│       ├── config.toml    # Main config
│       ├── hotkeys.toml   # Keybindings
│       └── theme/         # Theme collection
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
├── waybar/                # Status bar
│   ├── config             # Main configuration
│   ├── macchiato.css      # Catppuccin theme
│   ├── scripts/           # Custom scripts
│   │   └── exit_menu.sh   # Exit menu script
│   └── style.css          # Custom styling
├── wlogout/               # Logout menu
│   ├── layout             # Layout configuration
│   └── style.css          # Styling
└── wofi/                  # Application launcher
    ├── config             # Main configuration
    └── style.css          # Styling
```

## 🎯 Configuration Categories

### Desktop Environment (`hypr/`)

Core Hyprland ecosystem configuration files.

| File | Description | Target Location |
|------|-------------|-----------------|
| `hyprland.conf` | Main Hyprland configuration | `~/.config/hyprland/` |
| `hyprlock.conf` | Lock screen configuration | `~/.config/hyprland/` |
| `hypridle.conf` | Idle management | `~/.config/hyprland/` |
| `hyprpaper.conf` | Wallpaper management | `~/.config/hyprland/` |
| `random-wallpaper.sh` | Wallpaper rotation script | `~/.config/hyprland/` |

### Terminal Emulators

#### Kitty (`kitty/`)
| File | Description | Target Location |
|------|-------------|-----------------|
| `kitty.conf` | Main terminal configuration | `~/.config/kitty/` |
| `theme.conf` | Theme settings | `~/.config/kitty/` |
| `splits.conf` | Split configurations | `~/.config/kitty/` |
| `custom-hints.conf` | Custom key hints | `~/.config/kitty/` |

#### Ghostty (`ghostty/`)
| File | Description | Target Location |
|------|-------------|-----------------|
| `config` | Terminal configuration | `~/.config/ghostty/` |

### Status Bar (`waybar/`)

| File | Description | Target Location |
|------|-------------|-----------------|
| `config` | Main waybar configuration | `~/.config/waybar/` |
| `style.css` | Custom styling | `~/.config/waybar/` |
| `macchiato.css` | Catppuccin theme | `~/.config/waybar/` |
| `scripts/exit_menu.sh` | Exit menu script | `~/.config/waybar/scripts/` |

### Application Launchers

#### Wofi (`wofi/`)
| File | Description | Target Location |
|------|-------------|-----------------|
| `config` | Application launcher config | `~/.config/wofi/` |
| `style.css` | Launcher styling | `~/.config/wofi/` |

#### Wlogout (`wlogout/`)
| File | Description | Target Location |
|------|-------------|-----------------|
| `layout` | Logout menu layout | `~/.config/wlogout/` |
| `style.css` | Menu styling | `~/.config/wlogout/` |

### File Management (`superfile/`)

| File | Description | Target Location |
|------|-------------|-----------------|
| `config.toml` | Main configuration | `~/.config/superfile/` |
| `hotkeys.toml` | Keybindings | `~/.config/superfile/` |
| `theme/*.toml` | Theme collection | `~/.config/superfile/theme/` |

### System Information (`neofetch/`)

| File | Description | Target Location |
|------|-------------|-----------------|
| `config.conf` | Neofetch configuration | `~/.config/neofetch/` |
| `asciiLogo.txt` | Custom ASCII art | `~/.config/neofetch/` |
| `Atom.ascii` | Atom logo | `~/.config/neofetch/` |

### Development Tools (`clipse/`)

| File | Description | Target Location |
|------|-------------|-----------------|
| `config.json` | Main configuration | `~/.config/clipse/` |
| `custom_theme.json` | Custom theme | `~/.config/clipse/` |

## 🚀 Deployment Methods

### Automated Deployment

Use the toolkit script for automated deployment:

```bash
# Deploy all configurations
./toolkit/helper.sh setup-configs

# Deploy specific configuration
./toolkit/install-config.sh hyprland
./toolkit/install-config.sh waybar
./toolkit/install-config.sh kitty
```

### Manual Deployment

#### Symlink Method (Recommended)
```bash
# Create symlinks for easy updates
ln -sf /path/to/nixmod/extConfig/hyprland ~/.config/hyprland
ln -sf /path/to/nixmod/extConfig/waybar ~/.config/waybar
ln -sf /path/to/nixmod/extConfig/kitty ~/.config/kitty
```

#### Copy Method
```bash
# Copy configurations (manual updates required)
cp -r /path/to/nixmod/extConfig/hyprland ~/.config/
cp -r /path/to/nixmod/extConfig/waybar ~/.config/
cp -r /path/to/nixmod/extConfig/kitty ~/.config/
```

### Selective Deployment

```bash
# Deploy only specific files
mkdir -p ~/.config/hyprland
cp /path/to/nixmod/extConfig/hypr/hyprland.conf ~/.config/hyprland/
cp /path/to/nixmod/extConfig/hypr/hyprlock.conf ~/.config/hyprland/

# Deploy with custom paths
cp /path/to/nixmod/extConfig/hypr/hyprland.conf ~/.config/hyprland/
# Edit ~/.config/hyprland/hyprland.conf to update paths
```

## 🔧 Customization Guide

### Path Customization

Many configuration files contain hardcoded paths that need to be updated:

#### Hyprlock Configuration
```bash
# Edit hyprlock.conf to update wallpaper path
sed -i 's|/home/nikmen/Pictures/wallpapers/|/home/youruser/Pictures/wallpapers/|g' ~/.config/hyprland/hyprlock.conf
```

#### Hyprland Configuration
```bash
# Update monitor configuration in hyprland.conf
# Edit ~/.config/hyprland/hyprland.conf
```

### Theme Customization

#### Waybar Themes
```bash
# Switch between themes
cp ~/.config/waybar/macchiato.css ~/.config/waybar/style.css
# Or edit style.css directly
```

#### Superfile Themes
```bash
# List available themes
ls ~/.config/superfile/theme/

# Change theme in config.toml
# Edit ~/.config/superfile/config.toml
```

### Application-Specific Customization

#### Kitty Terminal
```bash
# Edit theme
nano ~/.config/kitty/theme.conf

# Modify keybindings
nano ~/.config/kitty/kitty.conf
```

#### Wofi Launcher
```bash
# Customize appearance
nano ~/.config/wofi/style.css

# Modify behavior
nano ~/.config/wofi/config
```

## 🔄 Synchronization

### Syncing Changes Back to Repository

```bash
# Sync all configurations
./toolkit/helper.sh sync-dotfiles

# Sync specific configuration
cp -r ~/.config/hyprland /path/to/nixmod/extConfig/hypr/
cp -r ~/.config/waybar /path/to/nixmod/extConfig/waybar/
```

### Version Control

```bash
# Add changes to git
git add extConfig/

# Commit changes
git commit -m "Update external configurations"

# Push to repository
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

When modifying external configurations:

1. **Test changes** before committing
2. **Update documentation** for new features
3. **Maintain backward compatibility** when possible
4. **Use consistent formatting** and style
5. **Add comments** for complex configurations

---

**Need help with configurations?** Check the troubleshooting section or create an issue on GitHub. 