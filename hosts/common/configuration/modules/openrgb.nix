{ pkgs, lib, ... }:

{
  config = {
    services.hardware.openrgb.enable = true;
    services.hardware.openrgb.motherboard = "amd";
  };
}