# home-manager

## Usage

```bash
export REPO_DIR=/path/to/installer
home-manager switch --flake .#<host> --impure
```

| host | description |
|------|-------------|
| `i3` | i3 (X11) |
| `hyprland` | Hyprland (Wayland) |
| `wsl` | WSL (Ubuntu) |
| `server` | minimal CLI |
