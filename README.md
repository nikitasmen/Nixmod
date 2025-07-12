# NixOS Configuration with Hyprland

A modern NixOS desktop environment configuration centered around the Hyprland compositor, now with Nix Flakes for better reproducibility and up-to-date UnixKit tools.

## Overview

This NixOS setup provides:
- Hyprland window manager with custom theming and configuration
- Waybar with Catppuccin Macchiato theme
- Multiple terminal options (kitty, ghostty, alacritty)
- Dynamic wallpaper management with hyprpaper
- Comprehensive development environment
- UnixKit tools (always fetches latest version via flakes)
- Nix Flakes support for reproducible builds

## Key Components

### Core Configuration
- [configuration.nix](configuration.nix) - Main system configuration
- [hardware-configuration.nix](hardware-configuration.nix) - Hardware-specific settings
- [nvidia-configuration.nix](nvidia-configuration.nix) - NVIDIA driver configuration
- [unixkit.nix](unixkit.nix) - Custom utility configurations

### Desktop Environment
- **Hyprland**: Tiling Wayland compositor with [custom configuration](extConfig/hyprland/hyprland.conf)
- **Waybar**: Status bar with [Catppuccin Macchiato theme](extConfig/waybar/macchiato.css)
- **Wallpapers**: Dynamic management via [hyprpaper](extConfig/hyprland/hyprpaper.conf) and [random-wallpaper.sh](extConfig/hyprland/random-wallpaper.sh)
- **Logout Menu**: Custom styled using [wlogout](extConfig/wlogout/style.css)
- **Application Launcher**: [Wofi](extConfig/wofi) for application launching

### Terminal Configuration
- **Kitty**: Feature-rich terminal with [custom configuration](extConfig/kitty/kitty.conf), [splits support](extConfig/kitty/splits.conf), and [custom hints](extConfig/kitty/custom-hints.conf)
- **Ghostty**: Modern terminal alternative
- **Alacritty**: Lightweight GPU-accelerated terminal option

### Development Environment
- Git with custom configuration
- Docker containerization
- Helix text editor
- Fish shell

### Media & Communication
- Firefox browser (system default)
- Spotify music player
- FreeTube (YouTube alternative)
- Stremio media center
- WebCord (Discord alternative)
- Viber messaging

## Installation

### Traditional Method

1. Clone this repository
2. Use the provided installation script:
   ```bash
   ./install configuration.nix
   ```
3. Rebuild your NixOS system:
   ```bash
   sudo nixos-rebuild switch
   ```

### Using Flakes (Recommended)

The flakes-based approach ensures you always get the latest UnixKit tools:

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/nixmod.git
   cd nixmod
   ```

2. Build and activate the configuration with flakes:
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

3. Manually set up your user configurations (optional):
   ```bash
   # Example: copying Hyprland configuration to your home directory
   mkdir -p ~/.config/hyprland
   cp -r ./extConfig/hyprland/* ~/.config/hyprland/
   ```

4. Update everything to latest versions (including UnixKit):
   ```bash
   # Update all flake inputs to their latest versions
   nix flake update
   
   # Apply the updated configuration
   sudo nixos-rebuild switch --flake .#nixos
   ```

## Customization

The configuration is highly modular:

- Modify waybar appearance in [style.css](extConfig/waybar/style.css)
- Adjust Hyprland settings in [hyprland.conf](extConfig/hyprland/hyprland.conf)
- Change terminal behavior in [kitty.conf](extConfig/kitty/kitty.conf)
- Customize system information display with [neofetch config](extConfig/neofetch/config.conf)

### Managing Configuration Files

All application configurations are stored in the `extConfig/` directory. These are **not** automatically installed by NixOS and need to be managed separately.

**Note:** The `extConfig/` directory is intentionally excluded from the NixOS system configuration. You'll need to manually copy or symlink these files to your `~/.config` directory as needed.

Example:
```bash
# Manual symlink for a specific config
ln -sf /path/to/nixmod/extConfig/hyprland ~/.config/hyprland

# Or copy configuration files
cp -r /path/to/nixmod/extConfig/kitty ~/.config/
```

## Using UnixKit Tools

This configuration includes [UnixKit](https://github.com/nikitasmen/UnixKit), a collection of custom utility scripts:

### Automatic Updates

Thanks to the flake-based approach, UnixKit is automatically updated to the latest version whenever you run:

```bash
nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

### Accessing UnixKit Tools

After rebuilding your system, all UnixKit tools will be available in your PATH. You can:

1. Run them directly from the terminal
2. Use them in your own scripts
3. Add keyboard shortcuts to frequently used tools

### Custom Scripts

You can add your own scripts to the `scripts/` directory, and they'll be available alongside the UnixKit tools.

## Additional Features

- **Pipewire**: Modern audio system with PulseAudio compatibility
- **Display Manager**: GDM with auto-login setup
- **Network**: NetworkManager with dmenu integration
- **Screenshots**: Flameshot with custom overlay
- **File Management**: Yazi and Superfile file explorers
- **UnixKit**: Custom utility scripts that are always up-to-date

## Screenshots
![image](https://github.com/user-attachments/assets/49d490d7-0cd4-4823-a911-9ca77b2f0ce0)

![image](https://github.com/user-attachments/assets/f8c25395-2a8a-4e65-a461-802c2fc422da)
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5523ae28-f98a-4bb9-9262-dc831d20e746" />


