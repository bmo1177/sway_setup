# =====================================================================
# Sway rice NixOS module — import from /etc/nixos/configuration.nix:
#
#   imports = [ /path/to/sway_setup/nixos/sway.nix ];
#
# then:  sudo nixos-rebuild switch
#
# Installs every binary referenced by ~/.config (swayfx, waybar, foot,
# fuzzel, swaync, kanshi, grim/slurp/swappy, wl-clipboard/cliphist,
# brightness/volume/media controls, idle/lock, wallpaper + theming,
# night light, file managers, polkit agent, recording apps) plus the
# fonts the bar and lock screen need.
# sway-binnewbs-snippet.nix is the minimal paste-in fragment; this file
# is the full importable equivalent.
# =====================================================================

{ pkgs, ... }:

{
  services.flatpak.enable = true;

  # Screen sharing / OBS capture on Wayland needs the wlr portal.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.sway = {
    enable = true;
    # The rice uses SwayFX-only directives (blur, shadows, corner_radius,
    # layer_effects in ~/.config/sway/config). Plain sway logs
    # "Unknown/invalid command" for every one of them at login — swaynag
    # error box — and drops all the eye candy. Keep swayfx here.
    package = pkgs.swayfx;
    wrapperFeatures.gtk = true;
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
      # --- screenshots / clipboard / recording ---
      grim
      slurp
      swappy
      wf-recorder
      wl-clipboard
      cliphist
      # --- volume / brightness / media ---
      pavucontrol
      pamixer
      brightnessctl
      playerctl
      # --- idle / lock ---
      swayidle
      # sway-lock script needs swaylock-effects (--clock/--timestr/
      # --fade-in/--effect-vignette are effects-only; plain swaylock
      # exits on those and the screen would stay unlocked).
      swaylock-effects
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

  # Fonts the rice expects: Nerd Font for bar/terminal/launcher glyphs,
  # Inter for the lock-screen clock, color emoji for notifications.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts-color-emoji
    inter
  ];
}
