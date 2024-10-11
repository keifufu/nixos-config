{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    catppuccin.enable = true;
    package = pkgs.btop.override {
      rocmSupport = true;
    };
    extraConfig = "custom_gpu_name0 = \"AMD Radeon RX 7900 XT\"";
  };
}
