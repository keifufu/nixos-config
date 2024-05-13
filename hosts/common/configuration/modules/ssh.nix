{ pkgs, ... }:

{
  programs.ssh.startAgent = true;
  security.pam.services.gnome-keyring = {
    name = "gnome-keyring";
    text = ''
      auth     optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome-keyring.so
      session  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
      password  optional    ${pkgs.gnome.gnome-keyring}/lib/security/pam_gnome_keyring.so
    '';
  };
  services.gnome.gnome-keyring.enable = true;
}