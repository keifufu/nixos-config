{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
    temurin-jre-bin-17
    lutris
    mangohud
    wineWowPackages.wayland
    protontricks
  ];

  programs = {
    steam.enable = true;
    gamemode.enable = true;
    gamescope.enable = true;
  };
}
