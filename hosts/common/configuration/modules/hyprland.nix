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
      # nvidia stuff if needed
      # GBM_BACKEND = "nvidia-drm";
      # __GL_GSYNC_ALLOWED = "0";
      # __GL_VRR_ALLOWED = "0";
      # WLR_DRM_NO_ATOMIC = "1";
      # XDG_SESSION_TYPE = "wayland";
      # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      # _JAVA_AWT_WM_NONREPARENTING = "1";
      # WLR_NO_HARDWARE_CURSORS = "1";
      # WLR_BACKEND = "vulkan";
      # WLR_RENDERER = "vulkan";

      # QT_QPA_PLATFORM = "wayland"; # defined in hyprland nix flake, set to "wayland;xcb"
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      NIXOS_OZONE_WL = "1";
      XCURSOR_SIZE = "24";
      # GDK_BACKEND = "wayland"; # defined in hyprland nix flake, set to "wayland,x11"
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };

  programs = {
    hyprland = {
      enable = true;
      # TODO: remove patch once new wlroots -> hyprland implementations are ironed out and do not cause issues
      package = (inputs.hyprland.packages.${pkgs.system}.hyprland.overrideAttrs (old: {
        patches = (old.patches or []) ++ [
          (pkgs.fetchpatch {
            url = "https://github.com/hyprwm/Hyprland/commit/fa69de8ab6cc17bb763a1586c55847c5d5a82a83.patch";
            hash = "sha256-ZXckiZ+X797p5NA7v83psuHHOd9AvG/CfttAqiJDaFs=";
          })
        ];
      }));
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=yes
  '';

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
