{ pkgs, ... }:

{
  programs.ssh.startAgent = true;
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  services.gnome.gnome-keyring.enable = true;
}