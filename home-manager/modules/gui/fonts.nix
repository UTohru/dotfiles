{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    udev-gothic
  ];

  # Cica and Firge are not in nixpkgs; download from GitHub Releases
  home.activation.downloadFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _install_font() {
      local name=$1
      local url=$2
      local dest="$HOME/.local/share/fonts/$name"
      [ -d "$dest" ] && return
      install -d "$dest"
      ${pkgs.curl}/bin/curl -sfL "$url" -o /tmp/font.zip || { rm -rf "$dest"; return 1; }
      ${pkgs.unzip}/bin/unzip -o /tmp/font.zip -d "$dest"
      rm -f /tmp/font.zip
      ${pkgs.fontconfig}/bin/fc-cache -f "$dest"
    }

    cica_url=$(${pkgs.curl}/bin/curl -sf https://api.github.com/repos/miiton/Cica/releases/latest \
      | ${pkgs.jq}/bin/jq -r '.assets[0].browser_download_url')
    firge_url=$(${pkgs.curl}/bin/curl -sf https://api.github.com/repos/yuru7/Firge/releases/latest \
      | ${pkgs.jq}/bin/jq -r '.assets[0].browser_download_url')

    _install_font Cica "$cica_url"
    _install_font Firge "$firge_url"
  '';
}
