{ config, lib, pkgs, host, system, inputs, vars, ... }:

{
  environment = {
    variables = {
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XKB_DEFAULT_LAYOUT = "de";
    };
    sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1"; # make electron and chromium run on wayland
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  services.getty.autologinUser = "${vars.user}";
  programs.zsh.loginShellInit = ''
    if [ -f "$HOME/.no-hypr" ]; then
      rm "$HOME/.no-hypr"
    else
      Hyprland
    fi
  '';

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
}
