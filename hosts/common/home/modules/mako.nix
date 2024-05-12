{ host, lib, ... }:

let
  output = with host; 
    if hostName == "desktop" then "DP-1"
    else if hostName == "laptop" then "eDP-1"
    else "";
in
{
  services.mako = {
    enable = true;
    catppuccin.enable = true;
    borderColor = lib.mkForce "#cba6f7";
    borderRadius = 8;
    borderSize = 3;
    output = "${output}";
    defaultTimeout = 5000;
    margin = "20,20,5";
  };
}