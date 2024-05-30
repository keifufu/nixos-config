{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    catppuccin.enable = true;
    package = pkgs.btop.override {
      rocmSupport = true;
    };
  };
}
