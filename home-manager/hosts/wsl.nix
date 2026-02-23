# WSL (Ubuntu): GUI なし、CLI + Windows 連携
{ lib, config, ... }:
{
  imports = [
    ../modules/dotfiles.nix
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

  # Windows バイナリへのシンボリックリンク
  home.file = {
    ".local/bin/powershell.exe".source = /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe;
    ".local/bin/cmd.exe".source        = /mnt/c/Windows/System32/cmd.exe;
    ".local/bin/explorer.exe".source   = /mnt/c/Windows/explorer.exe;
    ".local/bin/clip.exe".source       = /mnt/c/Windows/System32/clip.exe;
  };

  # Windows ユーザーディレクトリへのシンボリックリンクと WIN_USER 設定
  home.activation.wslSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v powershell.exe &>/dev/null; then
      WIN_USERDIR=$(wslpath -ua "$(powershell.exe '$env:USERPROFILE' | tr -d '\r\n')")
      [ -L "$HOME/desktop" ] || ln -sf "$WIN_USERDIR/Desktop" "$HOME/desktop"
      grep -q "WIN_USER" "$HOME/.config/zsh/localconf/profile.zsh" 2>/dev/null \
        || echo "export WIN_USER=${WIN_USERDIR##*/}" >> "$HOME/.config/zsh/localconf/profile.zsh"
    fi
  '';
}
