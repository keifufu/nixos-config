{ inputs, config, lib, pkgs, vars, ... }:

{
  imports = [
    ./modules/ags.nix
    ./modules/btop.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/mako.nix
    ./modules/neofetch.nix
    ./modules/obs-studio.nix
    ./modules/rnnoise.nix
    ./modules/wofi.nix
    ./modules/swaylock.nix
    ./modules/theming.nix
    ./modules/vscode.nix
    ./modules/waybar.nix
    ./modules/wlogout.nix
    ./modules/xremap.nix
    ./modules/yazi.nix
    ./modules/zsh.nix
  ];

  xdg.enable = true;
  catppuccin = {
    flavour = "mocha";
    accent = "mauve";
  };

  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";

    stateVersion = "23.11";
  };

  programs.home-manager.enable = true;
}
