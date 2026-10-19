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
# bash below (aliases, fzf key bindings, starship prompt).
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
  # Modern CLI tools + bash wiring for the foot terminal. starship uses a
  # fixed config (nerd-font-symbols preset, restored from the old GNOME
  # setup); fzf colors are still generated from the wallpaper by matugen
  # on Super+W.
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

        # Prompt (starship) — fixed nerd-font-symbols config.
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

  # ---------------------------------------------------------------------
  # tmux: TypeCraft's config (github.com/typecraft-dev/dotfiles) — C-s
  # prefix, vi keys, h/j/k/l pane nav, bar at the TOP with catppuccin
  # "rounded" window pills and application + session on the right,
  # transparent bar background (foot's glass shows through) — plus
  # session persistence (resurrect + continuum) and the tmux-which-key
  # menu. Config lands in /etc/tmux.conf.
  # ---------------------------------------------------------------------
  programs.tmux = {
    enable = true;
    shortcut = "s";
    baseIndex = 1;
    clock24 = true;
    keyMode = "vi";
    escapeTime = 0;
    historyLimit = 50000;
    terminal = "tmux-256color";
    newSession = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      resurrect
      continuum
      tmux-which-key
      # last: its theme styles the window pills / borders / menus
      catppuccin
    ];
    extraConfigBeforePlugins = ''
      # --- Catppuccin Mocha, full bar (restored from the pre-Sway setup) ---
      # truecolor pass-through for xterm-style TERMs
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g @catppuccin_flavor "mocha"
      set -g @catppuccin_window_status_style "rounded"
      set -g @catppuccin_window_flags "icon"
      set -g @catppuccin_pane_status_enabled "no"
      set -g @catppuccin_status_background "default"
      # Window pills show the current directory basename ("devlab"), like
      # the status-left directory chip.
      set -g @catppuccin_window_text " #{b:pane_current_path}"
      set -g @catppuccin_window_current_text " #{b:pane_current_path}"

      # Session persistence (read by resurrect / continuum)
      set -g @resurrect-capture-pane-contents "on"
      set -g @continuum-restore "on"
      set -g @continuum-save-interval "5"

      # tmux-which-key: menu comes from
      # ~/.config/tmux/plugins/tmux-which-key/config.yaml, rebuilt into
      # ~/.local/share/tmux/plugins/tmux-which-key/init.tmux on every start.
      set -g @tmux-which-key-xdg-enable "true"
    '';
    extraConfig = ''
      # --- Catppuccin bar: session + directory | git, uptime, RAM, CPU, time ---
      # No pane title bar.
      set -g pane-border-status off
      set -g status-position top
      set -g status-style bg=default

      # Custom status chips: git branch (teal) + RAM (peach), inlined from
      # catppuccin's utils/status_module.conf (nested `source` plus
      # `%hidden MODULE_NAME` mis-resolves once the theme plugin has queued
      # its own source files).
      #
      # --- git branch ---
      set -g @catppuccin_gitbranch_icon " "
      set -gF @catppuccin_gitbranch_color "#{E:@thm_teal}"
      set -g @catppuccin_gitbranch_text " #(git -C \"#{pane_current_path}\" branch --show-current 2>/dev/null || echo \"·\")"
      set -gqF @_ctp_connect_style "#{?#{==:#{@catppuccin_status_connect_separator},yes},,#[bg=default]}"
      set -ogqF @catppuccin_status_gitbranch_icon_fg "#{E:@thm_crust}"
      set -ogqF @catppuccin_status_gitbranch_text_fg "#{E:@thm_fg}"
      set -ogqF @catppuccin_status_gitbranch_icon_bg "#{@catppuccin_gitbranch_color}"
      set -gqF @_ctp_module_text_bg "#{E:@catppuccin_status_module_text_bg}"
      set -gF @catppuccin_status_gitbranch "#[fg=#{@catppuccin_status_gitbranch_icon_bg}]#{@_ctp_connect_style}#{@catppuccin_status_left_separator}"
      set -agF @catppuccin_status_gitbranch "#[fg=#{@catppuccin_status_gitbranch_icon_fg},bg=#{@catppuccin_status_gitbranch_icon_bg}]#{@catppuccin_gitbranch_icon}"
      set -agF @catppuccin_status_gitbranch "#{@catppuccin_status_middle_separator}"
      set -agF @catppuccin_status_gitbranch "#[fg=#{@catppuccin_status_gitbranch_text_fg},bg=#{@_ctp_module_text_bg}]"
      set -ag @catppuccin_status_gitbranch "#{E:@catppuccin_gitbranch_text}"
      set -agF @catppuccin_status_gitbranch "#[fg=#{@_ctp_module_text_bg}]#{@_ctp_connect_style}#{@catppuccin_status_right_separator}"
      set -ug @_ctp_connect_style
      set -ug @_ctp_module_text_bg

      # --- RAM ---
      set -g @catppuccin_ram_icon "󰍛 "
      set -gF @catppuccin_ram_color "#{E:@thm_peach}"
      set -g @catppuccin_ram_text " #{l:#{ram_percentage}}"
      set -gqF @_ctp_connect_style "#{?#{==:#{@catppuccin_status_connect_separator},yes},,#[bg=default]}"
      set -ogqF @catppuccin_status_ram_icon_fg "#{E:@thm_crust}"
      set -ogqF @catppuccin_status_ram_text_fg "#{E:@thm_fg}"
      set -ogqF @catppuccin_status_ram_icon_bg "#{@catppuccin_ram_color}"
      set -gqF @_ctp_module_text_bg "#{E:@catppuccin_status_module_text_bg}"
      set -gF @catppuccin_status_ram "#[fg=#{@catppuccin_status_ram_icon_bg}]#{@_ctp_connect_style}#{@catppuccin_status_left_separator}"
      set -agF @catppuccin_status_ram "#[fg=#{@catppuccin_status_ram_icon_fg},bg=#{@catppuccin_status_ram_icon_bg}]#{@catppuccin_ram_icon}"
      set -agF @catppuccin_status_ram "#{@catppuccin_status_middle_separator}"
      set -agF @catppuccin_status_ram "#[fg=#{@catppuccin_status_ram_text_fg},bg=#{@_ctp_module_text_bg}]"
      set -ag @catppuccin_status_ram "#{E:@catppuccin_ram_text}"
      set -agF @catppuccin_status_ram "#[fg=#{@_ctp_module_text_bg}]#{@_ctp_connect_style}#{@catppuccin_status_right_separator}"
      set -ug @_ctp_connect_style
      set -ug @_ctp_module_text_bg

      # session + directory left; git / uptime / RAM / CPU / clock right.
      # -agF unwraps #{l:...} so tmux-cpu can substitute its scripts.
      set -g status-left-length 100
      set -g status-right-length 100
      set -g status-left "#{E:@catppuccin_status_session}#{E:@catppuccin_status_directory}"
      set -g status-right "#{E:@catppuccin_status_gitbranch}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"
      set -agF status-right "#{E:@catppuccin_status_ram}"
      set -agF status-right "#{E:@catppuccin_status_cpu}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"
      set -g status-style bg=default

      # tmux-cpu: interpolate #{ram_percentage} / #{cpu_percentage} in the
      # status-right set above (must run after the status line is defined).
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

      # reload config: pointed at the nix-managed file.
      unbind r
      bind r source-file /etc/tmux.conf

      # prefix twice sends the prefix through (nested tmux).
      bind C-s send-prefix

      # TypeCraft pane navigation.
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # silent basics: clipboard (yank), mouse, vi keys in the command
      # line, focus events for nvim, image passthrough for yazi.
      set -g mouse on
      set -g renumber-windows on
      set -g status-keys vi
      set -g focus-events on
      set -gw allow-passthrough on
    '';
  };
}
