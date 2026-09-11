# Tmux - Bottom status bar widgets

When using Ghostty (or any terminal) with tmux, a status bar appears at the bottom with:

- **Left:** Session name, window list
- **Right:** User@host, uptime, battery %, time, date

## Usage

```bash
# Start tmux
tmux

# Or attach to existing session
tmux attach
```

## Widgets

| Widget   | Description                    |
|----------|--------------------------------|
| Session  | Current tmux session name      |
| Windows  | Open windows (1:bash, 2:vim…)  |
| User@host| Current user and hostname      |
| Uptime   | System uptime                  |
| Battery  | Battery percentage (laptops)   |
| Time     | Current time (HH:MM)           |
| Date     | Current date (DD-Mon)          |

Theme: Catppuccin Macchiato (matches Waybar).
