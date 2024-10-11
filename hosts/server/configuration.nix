{ pkgs, inputs, vars, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  security.sudo.wheelNeedsPassword = false;
  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  users.users.${vars.user} = {
    isNormalUser = true;
    password = "123";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9lCNP8EUEVlQFPZ9PJYEUqhxSlbJA8kYunpmy3ay5QNpLuGw7Gp9sjb0K/DXyzV3PgbSm6wxEbLmg1jXPiohGSqoXeTzgc500lKlpxtk89XKp6nmCF2uCykuKA8zSOhj+lWmfuyIZcsz23LHM8ksAji3VrhQy3Rb1jHLyvtm0yX2INlC3VsHWKazBtpqH3ZA5QdmVkYs5DzXOQS0THtq0R3+PRiUArQIZLiA5x5fkgnu1r6klPYvovlKNoyxp+SFxnN29mRKBVKhcvuUPxrWLlSYyhtV0Q3uz8kOAqUarRQpbOZJ8494z/ZwT+6K23wttyMfcSZJ1zX0m6viGQO4TQdMUa7l9cs4aOlqwMEB7dLo11LFQFkQBHJgxZICmXC9a74uhElbBVU9WFu1P+fVjmr8Jvl0th5/O2tCx3RegSxDBmcnVHGYJ1JkBkNGzPH9IkHJKZU6Tbe0PJpF1gsNY7LV8z6zzySFLVALbau7tFjS7xt6558pVbY4PU9blxW2hFZoYW9/wynuHtttOs7pQBffntA4I9pJR/B/Gf3NSCVqc3te83gvdMkbICPRknjbd88KhOHCmXa86wMvfCc9XnTGYoX5POHdVw/JR4gTuGcx/YAoDGiHrP1pGlXNhyhc1JxD/EpZz8KBMVz+9zkKuNUcFgP9V7xRUmgSEqC5yBQ== github@keifufu.dev"
    ];
  };

  virtualisation.docker.enable = true;

  networking.firewall = {
    enable = true;
    # nfs
    allowedTCPPorts = [ 2049 ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    hostKeys = [{
      bits = 4096;
      path = "/etc/secrets/initrd/ssh_host_rsa_key";
      type = "rsa";
    }];
  };

  services.cloudflared = {
    enable = true;
    user = "${vars.user}";
    group = "users";
    tunnels = {
      "nixos" = {
        credentialsFile = "/data/services/cloudflared/nixos.json";
        default = "http_status:404";
        ingress = {
          "navidrome.keifufu.dev" = "http://localhost:4533";
          "vault.keifufu.dev" = "http://localhost:8222";
          "ssh.keifufu.dev" = "ssh://localhost:22";
          "keifufu.dev" = "http://localhost:80";
          "www.keifufu.dev" = "http://localhost:80";
          "homu.dev" = "http://localhost:80";
          "www.homu.dev" = "http://localhost:80";
          "homu.homu.dev" = "http://localhost:80";
        };
      };
    };
  };

  services.navidrome = {
    enable = true;
    user = "${vars.user}";
    group = "users";
    settings = {
      MusicFolder = "/data/nfs/music";
      DataFolder = "/data/services/navidrome";
    };
  };

  systemd.services.vaultwarden = {
    after = [ "network.target" ];
    path = with pkgs; [ openssl ];
    serviceConfig = {
      User = "${vars.user}";
      Group = "users";
      EnvironmentFile = pkgs.writeText "vaultwarden.env" ''
        WEB_VAULT_FOLDER=${pkgs.vaultwarden.webvault}/share/vaultwarden/vault
        DATA_FOLDER=/data/services/vaultwarden
        DOMAIN=https://vault.keifufu.dev
        ROCKET_PORT=8222
        SIGNUPS_ALLOWED=false
      '';
      ExecStart = "${pkgs.vaultwarden}/bin/vaultwarden";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
  };

  services.nginx = {
    enable = true;
    user = "${vars.user}";
    group = "users";
    virtualHosts."keifufu.dev".root = "/data/services/nginx";
    virtualHosts."homu.dev".root = "/data/services/nginx";
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /data/nfs 192.168.2.0/24(rw,sync)
    '';
  };

  environment = {
    variables = {
      NIXOS_ALLOW_UNFREE = "1";
      SNOWFLAKE_SECRETS = "${vars.secrets}";
      SNOWFLAKE_FILES = "${vars.location}/files";
      PATH = [
        "${vars.location}/files/scripts"
      ];
    };
    systemPackages = with pkgs; [
      kitty
      nano
      curl
      git
      wget
      screen
      cryptsetup
      hdparm
      pv
      nvme-cli
      cloudflared
    ];
  };

  nix = {
    settings = {
      trusted-users = [ "${vars.user}" "@wheel" ];
      auto-optimise-store = true;
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
  system.stateVersion = "24.11";
}
