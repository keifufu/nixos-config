{
  systemd.user.paths.hyprland-started = {
    Unit.Description = "Watch for Hyprland to start";
    Path.PathExists = "%t/hypr";
    Install.WantedBy = [ "default.target" ];
  };

  programs.dimland = {
    enable = true;
    service = {
      enable = true;
      alpha = 0;
      radius = 20;
      after = "hyprland-started.path";
    };
  };
}
