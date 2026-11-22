# NixMod Dotfiles

Plain application configs. No Nix logic lives here: Home Manager deploys everything from `nixmod-system/modules/users/nikmen-home.nix` during a normal rebuild (`sudo ./toolkit/nixmod.sh update`). There is no separate install or sync script.

## How it's deployed

- Most entries are `xdg.configFile` symlinks into the read-only Nix store. **Editing a file here does nothing until you rebuild.**
- `nvim` is the exception: an out-of-store symlink to this checkout, so edits apply immediately and lazy.nvim can write `lazy-lock.json`.
- Apps that write runtime state into their config dir (`hypr`, `clipse`, `tuios`, `eww`, `waypaper`, `networkmanager-dmenu`) get individual files linked, so `~/.config/<app>` stays a real writable directory.
- `wallpapers/` goes to `~/Pictures/wallpapers` via `home.file` (a symlinked directory, hence `find -L` in the wallpaper scripts).
- `nixmod.sh` builds from a `path:` flake ref, which copies gitignored files into the world-readable store too. Never leave runtime state or secrets in this folder.

## Contents

| Dir | App |
|-----|-----|
| `hypr/` | Hyprland (`hyprland.lua`; `hyprland.conf` is the fallback for Hyprland < 0.55), hypridle, hyprlock, wallpaper scripts |
| `waybar/` | Three bars (top, bottom, left) in one `config`, `style.css` + `macchiato.css`, script-backed `custom/*` modules in `scripts/` |
| `eww/` | Bottom-bar prompter widget |
| `ghostty/` | Terminal |
| `wofi/`, `networkmanager-dmenu/` | Launcher, and the network picker that uses it |
| `wlogout/` | Logout menu |
| `nvim/`, `helix/` | Editors |
| `tmux/`, `starship/`, `bat/`, `git/` | Shell tooling |
| `superfile/` | File manager (plus a theme collection) |
| `clipse/` | Clipboard manager |
| `cava/` | Audio visualizer |
| `fastfetch/` | System info |
| `tuios/` | Terminal window manager |
| `waypaper/` | Wallpaper picker |
| `wallpapers/` | Images, not config |

## Adding a new dotfile

1. Put the config under `nixmod-dotfiles/<app>/`.
2. Add an `xdg.configFile` entry in `nikmen-home.nix` (whole dir, or individual files if the app writes into its config dir).
3. Rebuild.

Theme is Catppuccin Macchiato everywhere; reuse the hex values in `waybar/macchiato.css`.
