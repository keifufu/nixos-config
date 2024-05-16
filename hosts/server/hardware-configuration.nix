{ config, lib, pkgs, host, vars, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/all-hardware.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "sdhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "r8169" ];
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

  boot.kernelParams = [ "ip=192.168.2.111::192.168.2.1:255.255.255.0:server::none" ];
  boot.initrd = {
    systemd.users.${vars.user} = {
      uid = 1000;
      shell = "/bin/cryptsetup-askpass";
    };
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 22;
        authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9lCNP8EUEVlQFPZ9PJYEUqhxSlbJA8kYunpmy3ay5QNpLuGw7Gp9sjb0K/DXyzV3PgbSm6wxEbLmg1jXPiohGSqoXeTzgc500lKlpxtk89XKp6nmCF2uCykuKA8zSOhj+lWmfuyIZcsz23LHM8ksAji3VrhQy3Rb1jHLyvtm0yX2INlC3VsHWKazBtpqH3ZA5QdmVkYs5DzXOQS0THtq0R3+PRiUArQIZLiA5x5fkgnu1r6klPYvovlKNoyxp+SFxnN29mRKBVKhcvuUPxrWLlSYyhtV0Q3uz8kOAqUarRQpbOZJ8494z/ZwT+6K23wttyMfcSZJ1zX0m6viGQO4TQdMUa7l9cs4aOlqwMEB7dLo11LFQFkQBHJgxZICmXC9a74uhElbBVU9WFu1P+fVjmr8Jvl0th5/O2tCx3RegSxDBmcnVHGYJ1JkBkNGzPH9IkHJKZU6Tbe0PJpF1gsNY7LV8z6zzySFLVALbau7tFjS7xt6558pVbY4PU9blxW2hFZoYW9/wynuHtttOs7pQBffntA4I9pJR/B/Gf3NSCVqc3te83gvdMkbICPRknjbd88KhOHCmXa86wMvfCc9XnTGYoX5POHdVw/JR4gTuGcx/YAoDGiHrP1pGlXNhyhc1JxD/EpZz8KBMVz+9zkKuNUcFgP9V7xRUmgSEqC5yBQ== github@keifufu.dev" ];
        hostKeys = [
          "/etc/secrets/initrd/ssh_host_rsa_key"
        ];
      };
    };
  };

  boot.initrd.luks.devices.cryptroot = {
    name = "cryptroot";
    device = "/dev/disk/by-label/CRYPTROOT";
    preLVM = true;
    allowDiscards = true;
  };

  boot.initrd.luks.devices.cryptdata = {
    name = "cryptdata";
    device = "/dev/disk/by-label/CRYPTDATA";
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

  fileSystems."/data" =
    {
      device = "/dev/disk/by-label/DATA";
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