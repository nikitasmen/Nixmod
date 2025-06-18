# NixOS Configuration with Hyprland

A modern NixOS desktop environment configuration centered around the Hyprland compositor.

## Overview

This NixOS setup provides:
- Hyprland window manager with custom theming and configuration
- Waybar with Catppuccin Macchiato theme
- Multiple terminal options (kitty, ghostty, alacritty)
- Dynamic wallpaper management with hyprpaper
- Comprehensive development environment

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

1. Clone this repository
2. Use the provided installation script:
   ```bash
   ./install configuration.nix
   ```
3. Rebuild your NixOS system:
   ```bash
   sudo nixos-rebuild switch
   ```

## Customization

The configuration is highly modular:
- Modify waybar appearance in [style.css](extConfig/waybar/style.css)
- Adjust Hyprland settings in [hyprland.conf](extConfig/hyprland/hyprland.conf)
- Change terminal behavior in [kitty.conf](extConfig/kitty/kitty.conf)
- Customize system information display with [neofetch config](extConfig/neofetch/config.conf)

## Additional Features

- **Pipewire**: Modern audio system with PulseAudio compatibility
- **Display Manager**: GDM with auto-login setup
- **Network**: NetworkManager with dmenu integration
- **Screenshots**: Flameshot with custom overlay
- **File Management**: Yazi and Superfile file explorers

## Screenshots
![image](https://github.com/user-attachments/assets/49d490d7-0cd4-4823-a911-9ca77b2f0ce0)
