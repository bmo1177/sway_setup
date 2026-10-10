# sway_setup — Catppuccin Mocha Sway rice on NixOS

My daily-driver Sway setup: SwayFX + islands-style Waybar, wallpaper-driven
theming (matugen), 12 workspaces, 50-wallpaper collection, Flatpak creative apps,
and a full recording setup for tech content. Built on NixOS 26.05 alongside GNOME.

## Screenshots

![Desktop](screenshots/desktop.png)
![App launcher](screenshots/launcher.png)
![Window switcher](screenshots/switcher.png)
![Power menu](screenshots/powermenu.png)

## Quick reinstall

```bash
git clone https://github.com/bmo1177/sway_setup.git
cd sway_setup
./install.sh
```

The script backs up your current `~/.config` pieces (timestamped), installs
everything from `config/`, and prints the remaining manual steps (NixOS
packages + rebuild, user tools, Flatpaks, re-login).

## What's inside

| Area | Details |
|---|---|
| Compositor | SwayFX 0.5.3 (blur, shadows, rounded corners), 14" 1080p @ 1.25 scale via kanshi |
| Theme | Catppuccin Mocha everywhere; `Super+W` picker recolors bar, terminal, launcher, GTK from the wallpaper |
| Bar | Waybar islands: 6 quick launchers, numbered workspaces 1–12, notify drawer, audio, power |
| Notifications | swaync (themed) · Power menu: wlogout (themed) |
| Launcher | fuzzel (drun, clipboard history, wallpaper picker, cheatsheet) |
| Extras | Alt+Tab + Super+Tab window switchers (swayr), focus mode, keystroke overlay (wshowkeys), night light (gammastep) |
| Apps | OBS Studio, Kdenlive, FilmCraft, PhotoCraft, PdfCraft (Flatpaks), Obsidian, Warp, VS Code |
| Recording | OBS (RNNoise mic filter built in), wf-recorder clips, swappy annotate |

## Repo layout

```
config/        # dotfiles, mirrored 1:1 to ~/.config/ (sway, waybar, foot,
               #   fuzzel, swaync, wlogout, swayr, matugen, mako, kanshi,
               #   gammastep, fontconfig)
nixos/         # sway-binnewbs-snippet.nix — packages for configuration.nix
```

Wallpapers live in `~/Pictures/wallpapers/` (50 and counting, not vendored here).

## Install on NixOS

1. Add the packages from `nixos/sway-binnewbs-snippet.nix` to
   `programs.sway.extraPackages` (plus `obs-studio`, `kdePackages.kdenlive`,
   `nwg-look`, `dpkg`), enable `services.flatpak`, then:
   ```bash
   sudo nixos-rebuild switch
   ```
2. Copy configs into place (back yours up first):
   ```bash
   cp -r config/* ~/.config/
   ln -sfn ~/Pictures/wallpapers/<your-pick> ~/.config/sway/current_wallpaper
   ```
3. Log out → pick **Sway** at the login screen → log back in.
4. Flatpaks: `flatpak remote-add --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo`,
   then install the `.flatpak` bundles from each app's GitHub releases.
5. Rebuild notes: `swww` was renamed to `awww` in nixpkgs; Kdenlive lives at
   `kdePackages.kdenlive`; `matugen image` is broken in 4.0.0 — this setup works
   around it (ffmpeg average color → `matugen color`, see `config/sway/scripts/sway-wallpaper`).

## Keybindings (`Super` = Windows key, full list on `Super+/`)

| Keys | Action |
|---|---|
| Super+Return / D / E / B / C / N | Terminal / launcher / Files / browser / Code / Obsidian |
| Super+Q, Super+F, Super+Shift+F | Close / fullscreen / focus mode (fullscreen + hide bar) |
| Super+1..0, Super+F11/F12 | Workspaces 1–12 (Shift moves windows) |
| Alt+Tab, Super+Tab | Window / workspace switcher |
| Super+W | Wallpaper picker + auto-theme |
| Super+Shift+E / Super+Ctrl+L | Power menu / lock |
| Super+Shift+X | Screen off/on toggle |
| Super+I | Keystroke overlay (recordings) |
| Super+O | Idle-inhibit toggle |
| Print / Super+Print / Super+Shift+S | Screenshots (region/file/annotate) |
| Super+Ctrl+V | Clipboard history |

## Credits

Binnewbs/arch-hyprland and JaKooLit for the rice ideas; Catppuccin, SwayFX,
Waybar, swaync, wlogout, fuzzel, matugen, awww, swayr, ArtCraft crew.
