{ modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };
  boot.supportedFilesystems = [ "ntfs" ];

  fileSystems."/osu" =
    {
      device = "/dev/disk/by-label/OSU";
      fsType = "ntfs-3g";
    };

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/ROOT";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };

  fileSystems."/stuff" =
    {
      device = "/dev/disk/by-label/STUFF";
      fsType = "ext4";
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
