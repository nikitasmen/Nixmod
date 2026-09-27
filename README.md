# NixMod - NixOS + Hyprland Configuration

A single-machine NixOS flake built around the Hyprland Wayland compositor, with Home Manager deploying every dotfile and Catppuccin Macchiato theming throughout.

[![NixOS](https://img.shields.io/badge/NixOS-Flakes-blue.svg)](https://nixos.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-green.svg)](https://hyprland.org/)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-orange.svg)](https://nixos.wiki/wiki/Flakes)

## 📁 Repository Structure

| Path | What it is |
|------|-----------|
| `flake.nix` | The flake: one `nixosConfigurations.nixos`, Home Manager, and inputs (nixpkgs unstable, Hyprland, UnixKit, spicetify-nix) |
| `nixmod-system/` | NixOS modules: `configuration.nix` → `modules/{desktop,programs,system,users}/`, plus `overlays/` and the machine-specific `hardware-configuration.nix` / `nvidia-configuration.nix` |
| `nixmod-dotfiles/` | Plain app configs (hypr, waybar, ghostty, kitty, nvim, wofi, clipse, cava, …) and `wallpapers/`, deployed by Home Manager |
| `toolkit/` | `nixmod.sh` (entry point: rebuild wrapper, forwards maintenance commands) and `helper.sh` (maintenance) |

## 🚀 Quick Start

```bash
git clone https://github.com/nikitasmen/Nixmod.git
cd Nixmod
sudo ./toolkit/nixmod.sh install
```

That's the whole install. Home Manager links the dotfiles into `~/.config` in the same rebuild; there is no separate dotfiles step.

### New machine
`hardware-configuration.nix` and `nvidia-configuration.nix` hold machine-specific data (disk UUIDs, GPU bus IDs). Never copy them between machines. Regenerate instead:
```bash
sudo nixos-generate-config
# then merge the output into nixmod-system/hardware-configuration.nix and nvidia-configuration.nix
```

## 🛠️ Toolkit

```bash
sudo ./toolkit/nixmod.sh update        # nixos-rebuild switch (alias: install)
sudo ./toolkit/nixmod.sh test          # nixos-rebuild test, not added to the bootloader
sudo ./toolkit/nixmod.sh flake-update  # nix flake update
     ./toolkit/nixmod.sh status        # system status
     ./toolkit/nixmod.sh update-unixkit

     ./toolkit/nixmod.sh health              # disk / memory / load
sudo ./toolkit/nixmod.sh clean               # delete generations older than 14 days + GC the Nix store (destructive)
     ./toolkit/nixmod.sh create-module NAME  # scaffold a module and add it to its category's default.nix
     ./toolkit/nixmod.sh validate            # nix flake check on the repo
```

Run these from a checkout of the repo: `nixmod.sh` builds from the working tree (`path:` flake ref).

## ✨ Features

- **Desktop**: Hyprland (Lua config, `hypr/hyprland.lua`), greetd/regreet login, hyprlock, hypridle, wlogout
- **Waybar**: three bars (top, bottom, left) with custom script-backed modules, such as a network traffic graph that opens netscanner
- **Wallpapers**: waypaper plus random/set wallpaper scripts over `~/Pictures/wallpapers`
- **Terminals & editors**: Ghostty (default), Kitty, Neovim (lazy.nvim), Helix, tmux, starship
- **Tools**: clipse clipboard manager, superfile, cava, fastfetch, aichat + local Ollama, UnixKit
- **Extras**: Spotify + Spicetify, Steam auto-launch on gamepad connect, KDE Connect remote input, input-remapper

## ⌨️ Keybindings

| Keys | Action |
|------|--------|
| `Super + Q` | Terminal (Ghostty) |
| `Super + Space` | App launcher (wofi) |
| `Super + C` | Close window |
| `Super + M` | Exit Hyprland |
| `Super + E` | File manager (superfile) |
| `Super + V` / `Super + F` | Toggle floating / fullscreen |
| `Super + Shift + V` | Clipboard history (clipse) |
| `Super + L` | Lock screen |
| `Super + P` | Screenshot (flameshot) |
| `Super + W` / `Super + Shift + W` | Wallpaper picker / set wallpaper |
| `Super + 1-0` / `Super + Shift + 1-0` | Switch to / move window to workspace |
| `Super + S` / `Super + Shift + S` | Toggle / send to scratchpad |

## 🔧 Customizing

- **Add a package**: edit `nixmod-system/modules/programs/applications.nix`, then `sudo ./toolkit/nixmod.sh update`.
- **Edit a dotfile**: change it under `nixmod-dotfiles/` and rebuild. Files are linked read-only from the Nix store, so edits have no effect until the rebuild. The exception is `nvim`, which links straight to the repo and updates immediately.
- **Theme**: Catppuccin Macchiato everywhere (`waybar/macchiato.css` has the palette). Reuse those hex values.

## 🐛 Troubleshooting

```bash
nix flake check                                   # evaluate the flake
sudo nixos-rebuild dry-activate --flake .#nixos   # what a switch would change
nix-instantiate --parse path/to/file.nix          # syntax-check one file
journalctl -xe                                    # system logs
```

## 📸 Screenshots

![Desktop Overview](https://github.com/user-attachments/assets/49d490d7-0cd4-4823-a911-9ca77b2f0ce0)

![Application Launcher](https://github.com/user-attachments/assets/f8c25395-2a8a-4e65-a461-802c2fc422da)

![Lock Screen](https://github.com/user-attachments/assets/5523ae28-f98a-4bb9-9262-dc831d20e746)

## 📄 License

MIT, see [LICENSE](LICENSE).

## 🙏 Acknowledgments

[Hyprland](https://hyprland.org/) · [NixOS](https://nixos.org/) · [Home Manager](https://github.com/nix-community/home-manager) · [Catppuccin](https://github.com/catppuccin/catppuccin) · [UnixKit](https://github.com/nikitasmen/UnixKit)
