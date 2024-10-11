{ config, lib, pkgs, vars, ... }:

let
  getNfsHost = path: fallback:
    if lib.pathExists path then
      builtins.readFile path
    else
      fallback;
  nfs-host = getNfsHost "${vars.secrets}/nfs_host" "192.168.2.111";
in
{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.consoleLogLevel = 3;

  boot.extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  swapDevices = [ { device = "/dev/disk/by-label/SWAP"; } ];
  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
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

  fileSystems."/" = {
    device = "/dev/disk/by-label/ROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/stuff" = {
    device = "/dev/disk/by-label/STUFF";
    fsType = "ext4";
  };

  fileSystems."/nfs" = {
    device = "${nfs-host}:/data/nfs";
    fsType = "nfs";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  powerManagement.enable = true;
}
