{ config, inputs, vars, lib, pkgs, host, ... }:

let
  yamlConfig = ''
    modmap:
      - name: FFXIV
        window:
          only: FINAL FANTASY XIV
        remap:
          Btn_Extra: Alt_L
    keymap:
      - name: AltGr
        remap:
          Ctrl_L-ALT_L-Key_2: Alt_R-Key_2                    # ²
          Ctrl_L-ALT_L-Key_3: Alt_R-Key_3                    # ³
          Ctrl_L-ALT_L-Key_7: Alt_R-Key_7                    # {
          Ctrl_L-ALT_L-Key_8: Alt_R-Key_8                    # [
          Ctrl_L-ALT_L-Key_9: Alt_R-Key_9                    # ]
          Ctrl_L-ALT_L-Key_0: Alt_R-Key_0                    # }
          Ctrl_L-ALT_L-Key_Q: Alt_R-Key_Q                    # @
          Ctrl_L-ALT_L-Key_E: Alt_R-Key_E                    # €
          Ctrl_L-ALT_L-Key_Minus: Alt_R-Key_Minus            # \
          Ctrl_L-ALT_L-Key_RightBrace: Alt_R-Key_RightBrace  # ~
          Ctrl_L-ALT_L-Key_102ND: Alt_R-Key_102ND            # |
      - name: DisableCapsLock
        remap:
          CAPSLOCK: { escape_next_key: true }
  '' ;
in
{
  imports = [
    inputs.xremap.homeManagerModules.default
  ];

  # install for debug purposes
  home.packages = with pkgs; [
    inputs.xremap.packages.${system}.default
  ];

  systemd.user.services.xremap-mouse = {
    Unit = {
      Description = "xremap-mouse service";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
      ConditionPathExists = "/nonexistent/path"; # dont autostart
    };
    Service = {
      Type = "simple";
      ExecStart = "${inputs.xremap.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/xremap --mouse --watch ${config.xdg.configHome}/xremap/xremap.yml";
      Restart = "no";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  services.xremap = {
    withWlroots = true;
    watch = true;
    mouse = host.hostName == "desktop";
    debug = false;
    yamlConfig = yamlConfig;
  };

  xdg.configFile."xremap/xremap.yml".text = yamlConfig;

  systemd.user.services.xremap.Unit.PartOf = lib.mkForce [ "hyprland-session.target" ];
  systemd.user.services.xremap.Unit.After = lib.mkForce [ "hyprland-session.target" ];
  systemd.user.services.xremap.Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
}
