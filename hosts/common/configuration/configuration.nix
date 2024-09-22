{ config, lib, pkgs, inputs, vars, host, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/brightness.nix
    ./modules/games.nix
    ./modules/hyprland.nix
    ./modules/ssh.nix
    ./modules/symlink.nix
    ./modules/vm.nix
  ];

  programs.zsh.enable = true;
  users.users.${vars.user} = {
    isNormalUser = true;
    password = "123";
    extraGroups = [ "wheel" "networkmanager" "corectrl" "i2c" ];
    shell = pkgs.zsh;
  };

  # for xremap
  hardware.uinput.enable = true;
  users.groups.uinput.members = [ "${vars.user}" ];
  users.groups.input.members = [ "${vars.user}" ];

  services.resolved.enable = true;
  networking = {
    hostName = "${host.hostName}";
    networkmanager.enable = true;
    networkmanager.dns = "systemd-resolved";
    nameservers = [ "9.9.9.9#dns.quad9.net" ];
    extraHosts = ''
      192.168.2.1 speedport.ip
      192.168.2.2 asus.router
      192.168.2.111 n.k.d
    '';
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    # extraConfig.pipewire."99-low-latency" = {
    #   context.properties = {
    #     default.clock.rate = 48000;
    #     default.clock.quantum = 64;
    #     default.clock.min-quantum = 64;
    #     default.clock.max-quantum = 64;
    #   };
    # };

    extraConfig.pipewire."99-low-latency" = {
      context = {
        properties.default.clock.min-quantum = 128;
        modules = [
          {
            name = "libpipewire-module-rtkit";
            flags = ["ifexists" "nofail"];
            args = {
              nice.level = -15;
              rt = {
                prio = 88;
                time.soft = 200000;
                time.hard = 200000;
              };
            };
          }
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              server.address = ["unix:native"];
              pulse.min = {
                req = "128/48000";
                quantum = "128/48000";
                frag = "128/48000";
              };
            };
          }
        ];

        stream.properties = {
          node.latency = 128;
          resample.quality = 1;
        };
      };
    };

    # extraConfig.pipewire-pulse."99-low-latency" = {
    #   context.modules = [
    #     {
    #       name = "libpipewire-module-protocol-pulse";
    #       args = {
    #         pulse.min.req = "128/48000";
    #         pulse.default.req = "128/48000";
    #         pulse.max.req = "128/48000";
    #         pulse.min.quantum = "128/48000";
    #         pulse.max.quantum = "128/48000";
    #       };
    #     }
    #   ];
    #   stream.properties = {
    #     node.latency = "128/48000";
    #     resample.quality = 1;
    #   };
    # };

    wireplumber.extraConfig."wireplumber.profiles".main."monitor.libcamera" = "disabled";
  };

  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true; # make pipewire realtime-capable

  security.sudo.wheelNeedsPassword = false;
  security.polkit.enable = true;

  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "hyprland-session.target" ];
      wants = [ "hyprland-session.target" ];
      after = [ "hyprland-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  hardware.graphics = {
    package = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.mesa.drivers;
    package32 = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.pkgsi686Linux.mesa.drivers;
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
      amdvlk
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.amdvlk
    ];
  };

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
      SNOWFLAKE_SECRETS = "${vars.secrets}";
      SNOWFLAKE_FILES = "${vars.location}/files";
      SNOWFLAKE_WALLDIR = "${vars.walldir}";
      SNOWFLAKE_SCREENSHOTDIR = "${vars.screenshotdir}";
      PATH = [
        "${vars.location}/files/scripts"
      ];
      TERMINAL = "kitty";
      EDITOR = "code";
      VISUAL = "code";
    };
    systemPackages = with pkgs; [
      eza
      libnotify
      ntfy-sh
      mpv
      krita
      networkmanagerapplet
      imagemagick
      ffmpeg-full
      cifs-utils
      alsa-utils
      jq
      nano
      inotify-tools
      curl
      wget
      file
      yt-dlp
      ahoviewer
      wireguard-tools
      xclip
      wl-clipboard
      wtype
      hyprpicker
      wf-recorder
      cliphist
      pavucontrol
      pulseaudio # just for pactl
      helvum
      firefox-devedition-bin
      brave
      transmission_4-gtk
      cryptsetup
      android-file-transfer
      exiftool
      nautilus
      remmina
      telegram-desktop
      teamspeak_client
      (inputs.xivlauncher-rb.packages.${pkgs.stdenv.hostPlatform.system}.xivlauncher-rb.override {
        useGameMode = true;
        steam = pkgs.steam.override {
          extraProfile = ''
            unset TZ
          '';
        };
      })
    ];
  };

  xdg.mime = {
    enable = true;
    defaultApplications = 
    let
        # take from the respective mimetype files
        images = [
          "image/bmp"
          "image/gif"
          "image/jpeg"
          "image/jpg"
          "image/pjpeg"
          "image/png"
          "image/tiff"
          "image/x-bmp"
          "image/x-gray"
          "image/x-icb"
          "image/x-ico"
          "image/x-png"
          "image/x-portable-anymap"
          "image/x-portable-bitmap"
          "image/x-portable-graymap"
          "image/x-portable-pixmap"
          "image/x-xbitmap"
          "image/x-xpixmap"
          "image/x-pcx"
          "image/svg+xml"
          "image/svg+xml-compressed"
          "image/vnd.wap.wbmp;image/x-icns"
        ];
        urls = [
          "text/html"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ];
        documents = [
          "application/vnd.comicbook-rar"
          "application/vnd.comicbook+zip"
          "application/x-cb7"
          "application/x-cbr"
          "application/x-cbt"
          "application/x-cbz"
          "application/x-ext-cb7"
          "application/x-ext-cbr"
          "application/x-ext-cbt"
          "application/x-ext-cbz"
          "application/x-ext-djv"
          "application/x-ext-djvu"
          "image/vnd.djvu+multipage"
          "application/x-bzdvi"
          "application/x-dvi"
          "application/x-ext-dvi"
          "application/x-gzdvi"
          "application/pdf"
          "application/x-bzpdf"
          "application/x-ext-pdf"
          "application/x-gzpdf"
          "application/x-xzpdf"
          "application/postscript"
          "application/x-bzpostscript"
          "application/x-gzpostscript"
          "application/x-ext-eps"
          "application/x-ext-ps"
          "image/x-bzeps"
          "image/x-eps"
          "image/x-gzeps"
          "image/tiff"
          "application/oxps"
          "application/vnd.ms-xpsdocument"
          "application/illustrator"
        ];
        audioVideo = [
          "application/ogg"
          "application/x-ogg"
          "application/mxf"
          "application/sdp"
          "application/smil"
          "application/x-smil"
          "application/streamingmedia"
          "application/x-streamingmedia"
          "application/vnd.rn-realmedia"
          "application/vnd.rn-realmedia-vbr"
          "audio/aac"
          "audio/x-aac"
          "audio/vnd.dolby.heaac.1"
          "audio/vnd.dolby.heaac.2"
          "audio/aiff"
          "audio/x-aiff"
          "audio/m4a"
          "audio/x-m4a"
          "application/x-extension-m4a"
          "audio/mp1"
          "audio/x-mp1"
          "audio/mp2"
          "audio/x-mp2"
          "audio/mp3"
          "audio/x-mp3"
          "audio/mpeg"
          "audio/mpeg2"
          "audio/mpeg3"
          "audio/mpegurl"
          "audio/x-mpegurl"
          "audio/mpg"
          "audio/x-mpg"
          "audio/rn-mpeg"
          "audio/musepack"
          "audio/x-musepack"
          "audio/ogg"
          "audio/scpls"
          "audio/x-scpls"
          "audio/vnd.rn-realaudio"
          "audio/wav"
          "audio/x-pn-wav"
          "audio/x-pn-windows-pcm"
          "audio/x-realaudio"
          "audio/x-pn-realaudio"
          "audio/x-ms-wma"
          "audio/x-pls"
          "audio/x-wav"
          "video/mpeg"
          "video/x-mpeg2"
          "video/x-mpeg3"
          "video/mp4v-es"
          "video/x-m4v"
          "video/mp4"
          "application/x-extension-mp4"
          "video/divx"
          "video/vnd.divx"
          "video/msvideo"
          "video/x-msvideo"
          "video/ogg"
          "video/quicktime"
          "video/vnd.rn-realvideo"
          "video/x-ms-afs"
          "video/x-ms-asf"
          "audio/x-ms-asf"
          "application/vnd.ms-asf"
          "video/x-ms-wmv"
          "video/x-ms-wmx"
          "video/x-ms-wvxvideo"
          "video/x-avi"
          "video/avi"
          "video/x-flic"
          "video/fli"
          "video/x-flc"
          "video/flv"
          "video/x-flv"
          "video/x-theora"
          "video/x-theora+ogg"
          "video/x-matroska"
          "video/mkv"
          "audio/x-matroska"
          "application/x-matroska"
          "video/webm"
          "audio/webm"
          "audio/vorbis"
          "audio/x-vorbis"
          "audio/x-vorbis+ogg"
          "video/x-ogm"
          "video/x-ogm+ogg"
          "application/x-ogm"
          "application/x-ogm-audio"
          "application/x-ogm-video"
          "application/x-shorten"
          "audio/x-shorten"
          "audio/x-ape"
          "audio/x-wavpack"
          "audio/x-tta"
          "audio/AMR"
          "audio/ac3"
          "audio/eac3"
          "audio/amr-wb"
          "video/mp2t"
          "audio/flac"
          "audio/mp4"
          "application/x-mpegurl"
          "video/vnd.mpegurl"
          "application/vnd.apple.mpegurl"
          "audio/x-pn-au"
          "video/3gp"
          "video/3gpp"
          "video/3gpp2"
          "audio/3gpp"
          "audio/3gpp2"
          "video/dv"
          "audio/dv"
          "audio/opus"
          "audio/vnd.dts"
          "audio/vnd.dts.hd"
          "audio/x-adpcm"
          "application/x-cue"
          "audio/m3u"
        ];
        code = [
          "text/english"
          "text/plain"
          "text/x-makefile"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-java"
          "text/x-moc"
          "text/x-pascal"
          "text/x-tcl"
          "text/x-tex"
          "application/x-shellscript"
          "text/x-c"
          "text/x-c++"
        ];
      in
      (lib.genAttrs code (_: [ "codium.desktop" ]))
      // (lib.genAttrs images (_: [ "firefox-developer-edition.desktop" ]))
      // (lib.genAttrs urls (_: [ "firefox-developer-edition.desktop" ]))
      // (lib.genAttrs documents (_: [ "firefox-developer-edition.desktop" ]))
      // (lib.genAttrs audioVideo (_: [ "firefox-developer-edition.desktop" ]));
  };

  services.fstrim.enable = true;
  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.hardware.openrgb.enable = true;

  services = {
    xserver.xkb.layout = "de";
    printing = {
      enable = true;
      drivers = with pkgs; [ hplip ];
    };
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
      options = "--delete-older-than 30d";
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
