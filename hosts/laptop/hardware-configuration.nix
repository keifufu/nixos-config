{ config, lib, modulesPath, ... }:

{
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = lib.mkForce true;
    modesetting.enable = lib.mkForce true;
    powerManagement.enable = lib.mkForce true;
    powerManagement.finegrained = lib.mkForce true;
    nvidiaSettings = lib.mkForce true;
    open = lib.mkForce false;
    prime = {
      offload.enableOffloadCmd = lib.mkForce true;
      offload.enable = lib.mkForce true;
      amdgpuBusId = lib.mkForce "PCI:5:0:0";
      nvidiaBusId = lib.mkForce "PCI:1:0:0";
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/ROOT";
    fsType = "ext4";
  };

  fileSystems."/stuff" = {
    device = "/dev/disk/by-label/STUFF";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  boot.initrd.luks.devices.cryptstuff = {
    name = "cryptstuff";
    device = "/dev/disk/by-label/CRYPTSTUFF";
    allowDiscards = true;
  };

  boot.initrd.luks.devices.cryptroot = {
    name = "cryptroot";
    device = "/dev/disk/by-label/CRYPTROOT";
    preLVM = true;
    allowDiscards = true;
  };

  services.logind.lidSwitch = "hibernate";

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };
}
