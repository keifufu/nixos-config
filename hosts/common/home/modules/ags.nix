{ inputs, config, vars, pkgs, ... }:

{
  imports = [ inputs.ags.homeManagerModules.default ];
  
  home.packages = with pkgs; [
    bun # ags compilation
  ];

  programs.ags = {
    enable = true;
    configDir = null;
    extraPackages = with pkgs; [
      gtksourceview
      webkitgtk
      accountsservice
    ];
  };

  systemd.user.services.ags = {
    Unit = {
      Description = "ags";
      After = [ "hyprland-session.target" ];
      Requires = [ "dimland.service" ];
      StartLimitBurst = 15;
      StartLimitIntervaSec = 60;
    };
    Service = {
      Type = "simple";
      ExecStart = "${config.programs.ags.package}/bin/ags --config ${vars.location}/files/ags/config.js";
      Restart = "always";
      RestartSec = "1s";
      KillMode = "process";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
