#
#  Common nixOS configuration.
#
#  flake.nix
#   └─ ./hosts
#       ├─ hosts.nix !
#       └─ ./common
#           └─ ./configuration
#               ├─ configuration.nix *
#               ├─ hardware-configuration.nix +
#               └─ ./modules
#                   ├─ audio.nix +
#                   ├─ code.nix +
#                   ├─ docker.nix +
#                   ├─ games.nix +
#                   ├─ hyprland.nix +
#                   ├─ openrgb.nix +
#                   ├─ ssh.nix +
#                   ├─ symlink.nix +
#                   ├─ thunar.nix +
#                   └─ xremap.nix +
#

{ config, lib, pkgs, inputs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/audio.nix
    ./modules/code.nix
    ./modules/docker.nix
    ./modules/games.nix
    ./modules/hyprland.nix
    ./modules/openrgb.nix
    ./modules/ssh.nix
    ./modules/symlink.nix
    ./modules/thunar.nix
    ./modules/xremap.nix
  ];

  programs.zsh.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    password = "123";
    extraGroups = [ "wheel" "networkmanager" "corectrl" "wireshark" ];
    shell = pkgs.zsh;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  networking.networkmanager.enable = true;
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.i2c.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  fonts = {
    packages = with pkgs; [
      nerdfonts
    ];
    fontconfig.defaultFonts = {
      serif = [ "Source Code Pro" ];
      sansSerif = [ "Source Code Pro" ];
      monospace = [ "Source Code Pro" ];
      emoji = [ "Hack Nerd Font" ];
    };
  };

  environment = {
    variables = {
      NIXOS_ALLOW_UNFREE = "1";
      NIXOS_SECRETS = "${vars.secrets}";
      NIXOS_FILES = "${vars.location}/files";
      PATH = [
        "${vars.location}/files/scripts"
      ];
      TERMINAL = "kitty";
      EDITOR = "code";
      VISUAL = "code";
    };
    systemPackages = with pkgs; [
      imagemagick   # image manipulation
      ffmpeg        # ffmpeg
      cifs-utils    # samba
      alsa-utils    # alsa
      jq            # json parser
      killall       # killall
      nano          # nano
      pciutils      # pciutils
      inotify-tools # mainly for inotifywait
      curl          # curl
      wget          # some scripts use wget instead of curl
      solaar        # Logitech device manager
      parsec-bin
      ungoogled-chromium # need it for stupid webdev
      file
      yt-dlp
    ];
  };

  programs.corectrl.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  services = {
    xserver.layout = "de";
    flatpak.enable = true;
    printing.enable = true;
    printing.drivers = with pkgs; [ hplip ];
    avahi = {
      enable = true;
      nssmdns = true;
      publish = {
        enable = true;
        addresses = true;
        userServices = true;
      };
    };
  };

  nix = {
    settings = {
      trusted-users = [ "${vars.user}" "@wheel" ];
      auto-optimise-store = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    registry.nixpkgs.flake = inputs.nixpkgs;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs          = true
      keep-derivations      = true
    ''; 
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "23.11";
}
