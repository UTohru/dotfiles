# home-manager

## Usage

```bash
export REPO_DIR=/path/to/installer
home-manager switch --flake .#<host> --impure
```

| host | description |
|------|-------------|
| `desktop` | Ubuntu, i3 (X11) |
| `arch` | Arch Linux, Hyprland (Wayland) |
| `wsl` | WSL (Ubuntu) |
| `server` | minimal CLI |
