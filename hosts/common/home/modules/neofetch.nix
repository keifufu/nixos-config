{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neofetch
  ];

  home.file.".config/neofetch/config.conf".source = ../../../../files/config/neofetch.conf;
}