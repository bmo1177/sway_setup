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
# fonts the bar and lock screen need, and the terminal/shell quality of
# life set: eza, bat, zoxide, starship, fd, fastfetch, jq — wired into
# bash below (aliases, fzf key bindings, matugen-themed prompt).
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

  # --- terminal / shell quality of life ---------------------------------
  # Modern CLI tools + bash wiring for the foot terminal. The prompt
  # (starship) and fzf colors are generated from the wallpaper by matugen:
  # ~/.config/matugen/templates/{starship.toml,fzf-colors.sh}, applied on
  # Super+W. STARSHIP_CONFIG points at the matugen output location.
  environment.systemPackages = with pkgs; [
    eza
    bat
    zoxide
    starship
    fd
    fastfetch
    jq
  ];

  programs.bash = {
    # eza replaces ls/ls -l with icons + git status columns.
    shellAliases = {
      ls = "eza --group-directories-first --icons";
      l = "eza -la --group-directories-first --header --git --icons";
      ll = "eza -l --group-directories-first --header --git --icons";
      la = "eza -la --group-directories-first --header --git --icons";
      lt = "eza --tree --level=2 --group-directories-first --icons";
      tree = "eza --tree --group-directories-first --icons";
      fetch = "fastfetch";
    };

    interactiveShellInit = ''
      # Interactive shells only — scripts and agents stay untouched.
      if [[ $- == *i* ]]; then
        # History: big, deduped, appended (shared across terminals).
        HISTSIZE=100000
        HISTFILESIZE=200000
        HISTCONTROL=ignoreboth:erasedups
        shopt -s histappend

        # Tab completion: case-insensitive.
        bind "set completion-ignore-case on" 2>/dev/null || true

        # Prompt (starship) — themed from the wallpaper via matugen.
        export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
        command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"

        # zoxide: z <dir> jumps, zi picks with fzf.
        command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

        # fzf: matugen colors + fd-powered search + Ctrl+R/Ctrl+T/Alt+C.
        if command -v fzf >/dev/null 2>&1; then
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
          export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
          [ -f "$HOME/.config/fzf/colors.sh" ] && . "$HOME/.config/fzf/colors.sh"
          [ -f "${pkgs.fzf}/share/fzf/completion.bash" ] && . "${pkgs.fzf}/share/fzf/completion.bash"
          [ -f "${pkgs.fzf}/share/fzf/key-bindings.bash" ] && . "${pkgs.fzf}/share/fzf/key-bindings.bash"
        fi
      fi
    '';
  };
}
