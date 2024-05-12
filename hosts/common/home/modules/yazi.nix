{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    catppuccin.enable = true;
    enableZshIntegration = true;
    # TODO: rebind "a" to "n" for new file/folder
    # TODO: bookmark plugin https://github.com/dedukun/bookmarks.yazi

    # file:///stuff
    # file:///stuff/code
    # file:///smb
    # file:///smb/pictures
    # file:///smb/other
    # file:///home/${vars.user}/Downloads
  };
}
