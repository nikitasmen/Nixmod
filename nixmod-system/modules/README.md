# NixMod Modules

`default.nix` imports the four category directories; each category's `default.nix` lists its own `.nix` files.

## Modules

| Category | Module | What it does |
|----------|--------|--------------|
| `desktop/` | `hyprland.nix` | Hyprland (nixpkgs release build) and desktop packages |
| | `greetd.nix` | greetd + ReGreet login, random wallpaper background, Macchiato CSS |
| | `kdeconnect-portal-fix.nix` | RemoteDesktop portal so KDE Connect remote input works |
| | `terminals.nix` | Terminal emulators |
| `programs/` | `applications.nix` | Firefox (AI features off) and general apps |
| | `development.nix` | Dev tools, Docker, git |
| | `nixmod-gui.nix` | Packages `toolkit/nixmod-gui.py` as `nixmod-gui` |
| | `shell.nix` | zsh as login shell (configured in Home Manager) |
| | `spicetify.nix` | Spotify + Spicetify theme and stats |
| `system/` | `audio.nix` | PipeWire |
| | `boot.nix` | GRUB on EFI |
| | `fonts.nix` | Fonts |
| | `input-remapper.nix` | Extra mouse buttons / key remapping |
| | `locale.nix` | Time zone, locales, keyboard layout |
| | `memory.nix` | zram swap (no disk swap) |
| | `networking.nix` | NetworkManager, firewall |
| | `power.nix` | TLP |
| | `steam-on-controller.nix` | Starts Steam when a gamepad connects |
| `users/` | `nikmen.nix` | User account, Steam |
| | `nikmen-home.nix` | Home Manager: dotfile deployment, shell, user programs |

## Package lists

Packages are not listed in the `.nix` files. Each module that has them reads a sibling `<module>.packages.json`:

```json
{
  "packages": [
    { "name": "ripgrep", "note": "fast grep" }
  ]
}
```

```nix
{ pkgs, nixmod, ... }:
{
  environment.systemPackages = nixmod.readPackages ./example.packages.json;
}
```

`name` is a nixpkgs attribute path. `nixmod-gui` edits these files in jq's default format; keep that formatting if you edit by hand. Anything that needs a Nix expression (overrides, `writeTextFile`, `programs.*.enable`) stays in the `.nix` file, appended with `++`.

## New module

`./toolkit/nixmod.sh create-module NAME` prompts for the category, writes a template, and adds it to that category's `default.nix`.
