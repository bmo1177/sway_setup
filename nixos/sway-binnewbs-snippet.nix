// =====================================================================
// Sway binnewbs-rice additions — paste into /etc/nixos/configuration.nix
// next to the Phase 1 / Phase 2 blocks, then:
//   sudo nixos-rebuild switch
//
// What it adds (ports of binnewbs/arch-hyprland pieces already configured
// in ~/.config, waiting for these binaries):
//   matugen                  wallpaper-driven dynamic colors ($mod+w)
//   aww                     smooth wallpaper transitions (renamed from swww in nixpkgs)
//   swaynotificationcenter   notification center (custom/swaync in waybar)
//   wlogout                  power menu ($mod+Shift+e)
//   pavucontrol              volume mixer (waybar right-click)
//   blueman                  bluetooth manager (waybar click)
//   yazi                     terminal file manager
//   hyprpicker               color picker
//   gammastep                night light / blue-light filter ($mod+Ctrl+t)
//   celluloid                video player (mpv frontend, Wayland-native)
//   file-roller              archive manager (zip/tar/7z in Files)
//   nwg-look                 GUI to tweak GTK theme / fonts / cursor live
//   obs-studio               screen recording (Wayland capture, scenes, mic mix)
//   kdenlive                 general video editing (timeline, effects, titles)
// After rebuilding: uncomment the `exec swaync` line in
// ~/.config/sway/config (and drop `exec mako`), then reload sway.
// =====================================================================

  programs.sway.extraPackages = with pkgs; [
    matugen
    awww
    swaynotificationcenter
    wlogout
    pavucontrol
    blueman
    yazi
    hyprpicker
    gammastep
    celluloid
    file-roller
    libnotify
    nwg-look
    obs-studio
    kdenlive
  ];
