# =====================================================================
# Sway rice NixOS module — import from /etc/nixos/configuration.nix:
#
#   imports = [ /path/to/sway_setup/nixos/sway.nix ];
#
# then:  sudo nixos-rebuild switch
#
# Installs every binary referenced by ~/.config (sway, waybar, foot,
# fuzzel, swaync, kanshi, grim/slurp/swappy, wl-clipboard/cliphist,
# brightness/volume/media controls, idle/lock, wallpaper + theming,
# night light, file managers, polkit agent, recording apps).
# sway-binnewbs-snippet.nix is the minimal paste-in fragment; this file
# is the full importable equivalent.
# =====================================================================

{ pkgs, ... }:

{
  services.flatpak.enable = true;

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      # --- rice core ---
      matugen
      awww
      swaynotificationcenter
      wlogout
      waybar
      foot
      fuzzel
      kanshi
      # --- notifications / OSD deps ---
      libnotify
      # --- screenshots / clipboard ---
      grim
      slurp
      swappy
      wl-clipboard
      cliphist
      # --- volume / brightness / media ---
      pavucontrol
      pamixer
      brightnessctl
      playerctl
      # --- idle / lock ---
      swayidle
      swaylock
      # --- wallpaper / theming ---
      ffmpeg
      nwg-look
      hyprpicker
      # --- night light ---
      gammastep
      # --- system trays / bluetooth ---
      blueman
      # --- terminal tools ---
      yazi
      # --- auth agent (sway config resolves it without a /nix/store hash) ---
      polkit_gnome
      # --- apps ---
      nautilus
      celluloid
      file-roller
      obs-studio
      kdePackages.kdenlive
      dpkg
    ];
  };
}
