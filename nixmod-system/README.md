# NixMod System

NixOS + Home Manager modules for the `nixosConfigurations.nixos` defined in the repo-root `flake.nix`. Install and toolkit usage are in the [top-level README](../README.md).

## Layout

| Path | What it is |
|------|-----------|
| `configuration.nix` | Imports the hardware files and `./modules`, wires overlays, defines the `nixmod.readPackages` helper |
| `hardware-configuration.nix`, `nvidia-configuration.nix` | **Machine-specific** (disk UUIDs, GPU bus IDs). Regenerate with `sudo nixos-generate-config` on a new machine; never copy between machines |
| `modules/` | `desktop/`, `programs/`, `system/`, `users/`, see [modules/README.md](modules/README.md) |
| `overlays/` | `flameshot.nix`, `tlauncher.nix`, listed in `configuration.nix` |
| `unixkit.nix`, `passman.nix` | The author's own tools, built from flake inputs (fall back to `builtins.fetchGit` outside the flake) |
| `NVFanControl.nix` | NVIDIA fan-control timer. **Not imported anywhere**, so currently inactive |

## Common changes

- **Add a package**: add it to the module's `*.packages.json`, by hand or with the NixMod GUI. Then rebuild.
- **Add a module**: `./toolkit/nixmod.sh create-module NAME`, or create the file and add it to its category's `default.nix`.
- **Add an overlay**: put it in `overlays/` and add it to `nixpkgs.overlays` in `configuration.nix`.
- **Add a flake input**: edit the repo-root `flake.nix` by hand.

Rebuild with `sudo ./toolkit/nixmod.sh update`; check without applying with `./toolkit/nixmod.sh validate` or `sudo nixos-rebuild dry-activate --flake .#nixos`.
