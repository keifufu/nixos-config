{
  programs.ssh.startAgent = true;
  pam.services = [
    { name = "gnome_keyring"
      text = ''
        auth     optional    ${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
        session  optional    ${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so auto_start
        password  optional    ${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
      '';
    }
  ];
  services.gnome.gnome-keyring.enable = true;
}