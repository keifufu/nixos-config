{ inputs, ... }:

{
  imports = [
    inputs.dimland.homeManagerModules.dimland
  ];

  programs.dimland = {
    enable = true;
    service = {
      enable = true;
      alpha = 0;
      radius = 20;
      after = "hyprland-session.target";
      restartSec = "1s";
    };
  };
}
