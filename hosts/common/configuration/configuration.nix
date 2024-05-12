{ config, lib, pkgs, inputs, vars, host, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/code.nix
    ./modules/games.nix
    ./modules/hyprland.nix
    ./modules/openrgb.nix
    ./modules/ssh.nix
    ./modules/symlink.nix
  ];

  programs.zsh.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    password = "123";
    extraGroups = [ "wheel" "networkmanager" "corectrl" "wireshark" ];
    shell = pkgs.zsh;
  };

  # for xremap
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "${vars.user}" ];
  users.groups.input.members = [ "${vars.user}" ];

  networking = {
    hostName = "${host.hostName}";
    enableIPv6 = false;
    nameservers = [ "8.8.8.8" "8.0.0.8" ];
    networkmanager.enable = true;
    networkmanager.insertNameservers = [ "8.8.8.8" "8.0.0.8" ];
    extraHosts = ''
      192.168.2.1 speedport.ip
      192.168.2.2 asus.router
      192.168.2.111 n.k.d
    '';
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = true;

  systemd = {
    user.services.polkit-kde-authentication-agent-1 = {
      after = [ "graphical-session.target" ];
      description = "polkit-kde-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit-kde-agent}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      # rocmPackages.clr
      # rocmPackages.clr.icd
    ];
  };

  hardware.i2c.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
    catppuccin.enable = true;
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

  catppuccin = {
    flavour = "mocha";
    accent = "mauve";
  };

  environment = {
    variables = {
      NIXOS_ALLOW_UNFREE = "1";
      NIXOS_SECRETS = "${vars.secrets}";
      NIXOS_FILES = "${vars.location}/files";
      NIXOS_WALLDIR = "${vars.walldir}";
      PATH = [
        "${vars.location}/files/scripts"
      ];
      TERMINAL = "kitty";
      EDITOR = "code";
      VISUAL = "code";
    };
    systemPackages = with pkgs; [
      zip
      unzip
      p7zip
      unrar
      eza
      libnotify
      # ntfy 
      # ^ currently breaks the build with some python errors.
      # | cant be bothered to investigate since i dont use this
      # | package right now anyway?
      nvtopPackages.amd
      feh
      mpv
      vlc
      gimp
      libsForQt5.polkit-kde-agent
      networkmanagerapplet
      mako
      appimage-run
      qbittorrent-qt5
      libreoffice-qt
      imagemagick
      ffmpeg
      cifs-utils
      alsa-utils
      jq
      nano
      pciutils
      inotify-tools
      curl
      wget
      parsec-bin
      file
      yt-dlp
      man-pages
      man-pages-posix
      moonlight-qt
      virt-manager
      xclip
      notepadqq
      vesktop
      ahoviewer
      wireguard-tools
      grim
      slurp
      swappy
      wl-clipboard
      wtype
      hyprpicker
      hyprpaper
      hypridle
      hyprlock
      wlr-randr
      wf-recorder
      cliphist
      pavucontrol
      pulseaudio # just for pactl
      helvum # patchbay
      firefox
      brave
      bc # cli calc for usage in scripts
      (pkgs.xivlauncher.override {
        steam = pkgs.steam.override {
          extraProfile = ''
            unset TZ
          '';
        };
      })
    ] ++ [
      inputs.dimland.packages.${system}.default
    ];
  };

  documentation.dev.enable = true;

  programs.corectrl.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  services.ddccontrol.enable = true;
  services.fstrim.enable = true;
  services.blueman.enable = true;
  services.syncthing = {
    enable = true;
    user = "${vars.user}";
    dataDir = "/stuff/syncthing";
    configDir = "/stuff/syncthing/.sc";
  };

  services = {
    xserver.xkb.layout = "de";
    flatpak.enable = true;
    printing.enable = true;
    printing.drivers = with pkgs; [ hplip ];
    avahi = {
      enable = true;
      nssmdns4 = true;
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
