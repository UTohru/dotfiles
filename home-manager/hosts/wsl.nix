# WSL: CLI-only with Windows interop
{ lib, ... }:
{
  imports = [
    ../modules/dotfiles.nix
    ../modules/cli/base.nix
    ../modules/cli/rust.nix
    ../modules/cli/go.nix
    ../modules/cli/node.nix
    ../modules/cli/deno.nix
    ../modules/cli/editor.nix
    ../modules/cli/python.nix
  ];

  editor.vim.enable = true;
  editor.nvim.enable = true;
  python.uv.enable = true;

  home.activation.wslSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v powershell.exe &>/dev/null; then
      mkdir -p "$HOME/.local/bin"
      ln -sf /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe "$HOME/.local/bin/powershell.exe"
      ln -sf /mnt/c/Windows/System32/cmd.exe "$HOME/.local/bin/cmd.exe"
      ln -sf /mnt/c/Windows/explorer.exe "$HOME/.local/bin/explorer.exe"
      ln -sf /mnt/c/Windows/System32/clip.exe "$HOME/.local/bin/clip.exe"

      WIN_USERDIR=$(wslpath -ua "$(powershell.exe '$env:USERPROFILE' | tr -d '\r\n')")
      [ -L "$HOME/desktop" ] || ln -sf "$WIN_USERDIR/Desktop" "$HOME/desktop"
      grep -q "WIN_USER" "$HOME/.config/zsh/localconf/profile.zsh" 2>/dev/null \
        || echo "export WIN_USER=''${WIN_USERDIR##*/}" >> "$HOME/.config/zsh/localconf/profile.zsh"
    fi
  '';
}
