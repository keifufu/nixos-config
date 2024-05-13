{ lib, modulesPath, host, vars, ... }:

let
  getSambaHost = path: fallback:
    if lib.pathExists path then
      builtins.readFile path
    else
      fallback;
  smb-host = getSambaHost "${vars.secrets}/smb_host" "192.168.2.111";
in
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

  fileSystems."/smb" =
    {
      device = "//${smb-host}/data";
      fsType = "cifs";
      options = let
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
      in [ "${automount_opts},credentials=${vars.secrets}/smb,uid=1000,gid=100" ];
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
