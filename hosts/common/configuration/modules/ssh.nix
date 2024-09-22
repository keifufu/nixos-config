{ pkgs, ... }:

{
  programs.ssh.startAgent = true;
  services.gnome.gnome-keyring.enable = true;
}