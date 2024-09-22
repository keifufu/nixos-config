{ pkgs, config, ... }:

{
  boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];
  hardware.i2c.enable = true;
  environment.systemPackages = with pkgs; [
    ddcutil
  ];

  # This would be nice to use if it would ever work consistently.

  # boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  # boot.kernelModules = [ "ddcci_backlight" ];

  # environment.systemPackages = with pkgs; [
  #   brightnessctl
  # ];

  # services.udev.extraRules = ''
  #   SUBSYSTEM=="i2c-dev", ACTION=="add",\
  #     ATTR{name}=="AMDGPU *"\
  #     TAG+="ddcci",\
  #     TAG+="systemd",\
  #     ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
  # '';

  # systemd.services."ddcci@" = {
  #   description = "ddcci handler";
  #   after = [ "graphical.target" ];
  #   before = [ "shutdown.target" ];
  #   conflicts = [ "shutdown.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = "${
  #         pkgs.writeShellScript "attach-ddcci" ''
  #           echo "Trying to attach ddcci to $1"
  #           success=0
  #           i=0
  #           id=$(echo $1 | cut -d "-" -f 2)
  #           while ((success < 1)) && ((i++ < 5)); do
  #             ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id && {
  #               success=1
  #               echo "ddcci 0x37" > /sys/bus/i2c/devices/$1/new_device
  #               echo "ddcci attached to $1";
  #             } || sleep 5
  #           done
  #         ''
  #       } %i";
  #     Restart = "no";
  #   };
  # };
}