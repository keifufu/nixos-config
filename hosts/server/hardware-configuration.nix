{ config, lib, pkgs, host, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "sdhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };

  boot.initrd.luks.devices.cryptroot = {
    name = "cryptroot";
    device = "/dev/disk/by-label/CRYPTROOT";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.cryptstuff = {
    name = "cryptstuff";
    device = "/dev/disk/by-label/CRYPTSTUFF";
    allowDiscards = true;
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

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    useDHCP = false;
    hostName = "${host.hostName}";
    enableIPv6 = false;
    interfaces = {
      enp3s0.ipv4.addresses = [{
        address = "192.168.2.111";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.2.1";
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };
}