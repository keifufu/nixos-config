{ pkgs, vars, ... }:

{
  users.users.${vars.user}.extraGroups = [ "libvirtd" ];
  boot = {
    kernelModules = [
      "kvm-amd"
      "vfio"
      "vfio_pci"
      "vfio_virqfd"
      "vfio_iommu_type1"
    ];
    kernelParams = [
      "amd_iommu=on"
    ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    win-virtio
    win-spice
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}