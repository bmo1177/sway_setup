# sway_setup — flake (module-only).
#
# The setup is delivered as a NixOS module; this flake makes it importable
# from other flake-based configs without copying files. No inputs on purpose:
# the module evaluates against the importer's own nixpkgs.
#
# Usage:
#   inputs.sway-setup.url = "github:bmo1177/sway_setup";
#   imports = [ inputs.sway-setup.nixosModules.default ];
#
# Then run ./install.sh once for the dotfiles (config/ -> ~/.config).

{
  description = "Catppuccin Mocha SwayFX rice on NixOS — Sway module + one-shot dotfiles installer";

  outputs = { self }: {
    nixosModules.default = import ./nixos/sway.nix;
  };
}
