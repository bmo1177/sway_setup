#!/usr/bin/env bash
# sway_setup — quick reinstall for NixOS + Sway.
# Restores every dotfile in ./config to ~/.config (backing yours up first),
# installs sway-inhibit-toggle to ~/.local/bin, repairs waybar symlinks,
# creates picture folders, and prints the remaining manual steps.
# Safe to re-run: each run backs up to a new timestamped directory.
# Restore: cp -a <backup-dir>/<name> ~/.config/<name>
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo "==> Backing up current ~/.config pieces to $BACKUP"
mkdir -p "$BACKUP"
for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    if [ -e "$HOME/.config/$name" ]; then
        cp -a "$HOME/.config/$name" "$BACKUP/"
        echo "    saved $name"
    fi
done
if [ -e "$HOME/.local/bin/sway-inhibit-toggle" ]; then
    mkdir -p "$BACKUP/local-bin"
    cp -a "$HOME/.local/bin/sway-inhibit-toggle" "$BACKUP/local-bin/"
    echo "    saved sway-inhibit-toggle"
fi

echo "==> Installing rice from $REPO/config"
mkdir -p "$HOME/.config"
# Preserve the wallpaper symlink + live matugen outputs across reinstalls:
# the repo ships defaults, but a re-run must not wipe the user's theme.
PRESERVED_TMP="$(mktemp -d)"
if [ -L "$HOME/.config/sway/current_wallpaper" ]; then
    cp -a "$HOME/.config/sway/current_wallpaper" "$PRESERVED_TMP/current_wallpaper-link"
fi
for f in sway/colors waybar/colors.css foot/colors.ini fuzzel/colors.ini \
         starship/starship.toml fzf/colors.sh tmux/theme.conf; do
    if [ -f "$HOME/.config/$f" ]; then
        mkdir -p "$PRESERVED_TMP/$(dirname "$f")"
        cp -a "$HOME/.config/$f" "$PRESERVED_TMP/$f"
    fi
done
# The live tmux theme bridge (Catppuccin full bar) uses a local copy of
# the catppuccin plugin; keep it (and theme.conf above) across re-runs
# until the NixOS module is rebuilt with the plugin natively.
if [ -d "$HOME/.config/tmux/plugins/catppuccin" ]; then
    mkdir -p "$PRESERVED_TMP/tmux/plugins"
    cp -a "$HOME/.config/tmux/plugins/catppuccin" "$PRESERVED_TMP/tmux/plugins/"
fi
for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    rm -rf "$HOME/.config/$name"
    cp -a "$src" "$HOME/.config/$name"
    echo "    installed $name"
done
if [ -e "$PRESERVED_TMP/current_wallpaper-link" ]; then
    cp -a "$PRESERVED_TMP/current_wallpaper-link" "$HOME/.config/sway/current_wallpaper"
    echo "    preserved current_wallpaper -> $(readlink "$HOME/.config/sway/current_wallpaper")"
fi
for f in sway/colors waybar/colors.css foot/colors.ini fuzzel/colors.ini \
         starship/starship.toml fzf/colors.sh tmux/theme.conf; do
    if [ -f "$PRESERVED_TMP/$f" ]; then
        mkdir -p "$HOME/.config/$(dirname "$f")"
        cp -a "$PRESERVED_TMP/$f" "$HOME/.config/$f"
    fi
done
if [ -d "$PRESERVED_TMP/tmux/plugins/catppuccin" ]; then
    mkdir -p "$HOME/.config/tmux/plugins"
    cp -a "$PRESERVED_TMP/tmux/plugins/catppuccin" "$HOME/.config/tmux/plugins/"
fi
echo "    preserved live theme (if any)"
rm -rf "$PRESERVED_TMP"

echo "==> Scripts executable + local bin"
chmod +x "$HOME/.config/sway/scripts/"* 2>/dev/null || true
mkdir -p "$HOME/.local/bin"
cp -a "$REPO/config/sway/scripts/sway-inhibit-toggle" "$HOME/.local/bin/sway-inhibit-toggle"
chmod +x "$HOME/.local/bin/sway-inhibit-toggle"
echo "    installed ~/.local/bin/sway-inhibit-toggle"

echo "==> Waybar active config/style symlinks"
# cp -a preserves the repo's relative symlinks, but older installs left
# real files behind — re-link explicitly so style/layout switchers keep working.
if [ -d "$HOME/.config/waybar/configs" ]; then
    default_cfg="$(basename "$(readlink "$REPO/config/waybar/config")")"
    if [ -f "$HOME/.config/waybar/config" ] && [ ! -L "$HOME/.config/waybar/config" ]; then
        ln -sfn "configs/$default_cfg" "$HOME/.config/waybar/config"
    fi
fi
if [ -d "$HOME/.config/waybar/styles" ]; then
    default_style="$(basename "$(readlink "$REPO/config/waybar/style.css")")"
    if [ -f "$HOME/.config/waybar/style.css" ] && [ ! -L "$HOME/.config/waybar/style.css" ]; then
        ln -sfn "styles/$default_style" "$HOME/.config/waybar/style.css"
    fi
    echo "    config -> $(readlink "$HOME/.config/waybar/config")"
    echo "    style.css -> $(readlink "$HOME/.config/waybar/style.css")"
fi

echo "==> Picture folders"
mkdir -p "$HOME/Pictures/wallpapers" "$HOME/Pictures/Screenshots" "$HOME/Videos/screencasts"
if [ -z "$(ls -A "$HOME/Pictures/wallpapers" 2>/dev/null)" ]; then
    echo "    (!!) drop images into ~/Pictures/wallpapers, then press Super+W to pick one"
elif [ ! -e "$HOME/.config/sway/current_wallpaper" ]; then
    echo "    (!!) $(ls "$HOME/Pictures/wallpapers" | wc -l) wallpapers found, none selected — press Super+W to pick one"
fi

echo "==> Dependency check (warnings only)"
missing=""
for cmd in sway swaymsg waybar foot fuzzel swaync kanshi grim slurp swappy wl-copy cliphist brightnessctl pamixer playerctl swayidle swaylock awww matugen gammastep; do
    command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"
done
if [ -n "$missing" ]; then
    echo "    (!!) missing:$missing — see nixos/sway.nix then sudo nixos-rebuild switch"
else
    echo "    all runtime binaries present"
fi

cat <<'NEXT'

Done. Remaining manual steps:
  1. System packages: import nixos/sway.nix in /etc/nixos/configuration.nix
     (or paste nixos/sway-binnewbs-snippet.nix entries into
     programs.sway.extraPackages), then:  sudo nixos-rebuild switch
  2. User tools (no sudo):  nix profile install \
       'github:NixOS/nixpkgs/nixos-26.05#sov' \
       'github:NixOS/nixpkgs/nixos-26.05#swayr' \
       'github:NixOS/nixpkgs/nixos-26.05#wshowkeys'
  3. Flatpak: remote-add flathub --user, then install each app's .flatpak
     bundle from its GitHub releases page.
  4. Log out -> pick Sway at login -> log back in.
  5. Super+W picks wallpaper + theme. Super+/ shows every shortcut.

Restore: cp -a <backup-dir>/<name> ~/.config/<name>
Your old configs are safe in the backup dir printed above.
NEXT
