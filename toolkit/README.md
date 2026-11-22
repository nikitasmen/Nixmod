# NixMod Toolkit

Bash wrappers around `nixos-rebuild` plus maintenance helpers, and the NixMod GUI. Run from a checkout of the repo: `nixmod.sh` builds from the working tree via a `path:` flake ref (which also copies gitignored files into the store, so keep secrets out of the tree).

| File | What it is |
|------|-----------|
| `nixmod.sh` | Entry point. Rebuild/flake commands, and forwards maintenance commands to `helper.sh` |
| `helper.sh` | `health`, `clean`, `create-module`, `validate` (also callable directly: `./toolkit/helper.sh <cmd>`) |
| `update-unixkit.sh` | Backs `nixmod.sh update-unixkit` |
| `colors.sh` | Shared terminal colors |
| `nixmod-gui.py` | GTK4 GUI, installed as `nixmod-gui` ("NixMod" in wofi) by `nixmod-system/modules/programs/nixmod-gui.nix` |

## `nixmod.sh` commands

```bash
sudo ./toolkit/nixmod.sh install|update      # nixos-rebuild switch (identical; also redeploys dotfiles)
sudo ./toolkit/nixmod.sh test                # nixos-rebuild test, not added to the bootloader
sudo ./toolkit/nixmod.sh flake-update        # nix flake update
     ./toolkit/nixmod.sh update-unixkit      # bump UnixKit to its latest commit
     ./toolkit/nixmod.sh status              # system status
     ./toolkit/nixmod.sh health              # disk / memory / load
sudo ./toolkit/nixmod.sh clean [DAYS]        # delete generations older than DAYS (default 14) + GC the store (destructive)
     ./toolkit/nixmod.sh create-module NAME  # scaffold a module, prompts for category, wires it into that default.nix
     ./toolkit/nixmod.sh validate            # nix flake check
     ./toolkit/nixmod.sh help
```

Packages have no CLI command: edit `nixmod-system/modules/<category>/<module>.packages.json` directly, or use the GUI, then rebuild.

## `nixmod-gui`

- Search nixpkgs (index pinned to the flake.lock nixpkgs) and add/remove packages in the `*.packages.json` files.
- Package details: meta, runtime deps, reverse deps, and where the repo references it.
- Read-only lists of enabled `programs.<name>.enable` (NixOS and Home Manager, with file:line) and flake inputs, with a per-input `nix flake update`.
- Runs the `nixmod.sh` actions with a live log. Root actions ask for your password in-app and use `sudo -S` (NixOS has no setuid pkexec by default).

## Troubleshooting

```bash
./toolkit/nixmod.sh validate                      # evaluate the flake
sudo nixos-rebuild dry-activate --flake .#nixos   # what a switch would change
nix-instantiate --parse path/to/file.nix          # syntax-check one file
journalctl -xe
```
