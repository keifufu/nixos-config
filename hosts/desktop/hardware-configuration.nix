{ modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  networking = {
    useDHCP = false;
    interfaces = {
      enp4s0.ipv4.addresses = [{
        address = "192.168.2.112";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.2.1";
  };
}
