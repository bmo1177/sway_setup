#!/usr/bin/env bash
# sway_setup — quick reinstall for NixOS + Sway.
# Restores every dotfile in ./config to ~/.config (backing yours up first),
# creates the wallpaper folder, and prints the remaining manual steps.
# Safe to re-run: each run backs up to a new timestamped directory.
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

echo "==> Installing rice from $REPO/config"
mkdir -p "$HOME/.config"
for src in "$REPO"/config/*/; do
    name="$(basename "$src")"
    rm -rf "$HOME/.config/$name"
    cp -a "$src" "$HOME/.config/$name"
    echo "    installed $name"
done

echo "==> Wallpaper folder"
mkdir -p "$HOME/Pictures/wallpapers"
if [ ! -e "$HOME/.config/sway/current_wallpaper" ]; then
    echo "    (!!) drop images into ~/Pictures/wallpapers, then press Super+W to pick one"
fi

cat <<'NEXT'

Done. Remaining manual steps:
  1. Packages: add nixos/sway-binnewbs-snippet.nix entries to
     programs.sway.extraPackages in /etc/nixos/configuration.nix
     (+ obs-studio, kdePackages.kdenlive, nwg-look, dpkg; services.flatpak),
     then:  sudo nixos-rebuild switch
  2. User tools (no sudo):  nix profile install \
       'github:NixOS/nixpkgs/nixos-26.05#sov' \
       'github:NixOS/nixpkgs/nixos-26.05#swayr' \
       'github:NixOS/nixpkgs/nixos-26.05#wshowkeys'
  3. Flatpak: remote-add flathub --user, then install each app's .flatpak
     bundle from its GitHub releases page.
  4. Log out -> pick Sway at login -> log back in.
  5. Super+W picks wallpaper + theme. Super+/ shows every shortcut.

Your old configs are safe in the backup dir printed above.
NEXT
