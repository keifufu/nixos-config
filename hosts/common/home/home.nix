{ inputs, config, lib, pkgs, vars, ... }:

{
  imports = [
    ./modules/ags.nix
    ./modules/btop.nix
    ./modules/dimland.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/mako.nix
    ./modules/mpscd.nix
    ./modules/obs-studio.nix
    ./modules/rnnoise.nix
    ./modules/wofi.nix
    ./modules/theming.nix
    ./modules/vscode.nix
    ./modules/wnpcli.nix
    ./modules/xremap.nix
    ./modules/yazi.nix
    ./modules/zen.nix
    ./modules/zsh.nix
  ];

  xdg.enable = true;

  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}
