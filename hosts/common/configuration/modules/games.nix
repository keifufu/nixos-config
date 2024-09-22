{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
    temurin-jre-bin-17
    lutris
    wineWowPackages.wayland
    winetricks
    protontricks
  ];

  programs = {
    steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
  };
}
