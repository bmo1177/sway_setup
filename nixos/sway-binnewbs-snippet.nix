# =====================================================================
# Sway binnewbs-rice additions — paste into /etc/nixos/configuration.nix
# (merge the list into programs.sway.extraPackages), then:
#   sudo nixos-rebuild switch
#
# What it adds (ports of binnewbs/arch-hyprland pieces already configured
# in ~/.config, waiting for these binaries):
#   matugen                  wallpaper-driven dynamic colors ($mod+w)
#   aww                     smooth wallpaper transitions (renamed from swww in nixpkgs)
#   swaynotificationcenter   notification center (custom/swaync in waybar)
#   wlogout                  power menu ($mod+Shift+e)
#   pavucontrol              volume mixer (waybar right-click)
#   blueman                  bluetooth manager (waybar click)
#   yazi                     terminal file manager
#   hyprpicker               color picker ($mod+Ctrl+c)
#   wf-recorder              region screen recording ($mod+Shift+r)
#   gammastep                night light / blue-light filter ($mod+Ctrl+t)
#   celluloid                video player (mpv frontend, Wayland-native)
#   file-roller              archive manager (zip/tar/7z in Files)
#   nwg-look                 GUI to tweak GTK theme / fonts / cursor live
#   obs-studio               screen recording (Wayland capture, scenes, mic mix)
#   kdenlive                 general video editing (timeline, effects, titles)
# After rebuilding: sway uses swaync (exec swaync in ~/.config/sway/config).
# config/mako/ stays as an unused fallback — delete it if you never use mako.
# =====================================================================

  programs.sway.extraPackages = with pkgs; [
    matugen
    awww
    swaynotificationcenter
    wlogout
    pavucontrol
    blueman
    yazi
    hyprpicker
    wf-recorder
    gammastep
    celluloid
    file-roller
    libnotify
    nwg-look
    obs-studio
    kdenlive
    polkit_gnome
  ];
# Full importable version with every runtime dep — incl. the swayfx
# package (blur/shadows/rounding), swaylock-effects and the bar/lock
# fonts (grim/slurp/swappy, wl-clipboard/cliphist, pamixer/brightnessctl/
# playerctl, swayidle, ffmpeg, nautilus, etc.): see sway.nix in this
# directory. Prefer importing that over pasting this fragment.
