{ config, lib, modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
}
