{
  description = "A snowflake, just like me";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/hyprland";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    xremap.url = "github:xremap/nix-flake";
    dimland.url = "github:keifufu/dimland";
    wnpcli.url = "github:keifufu/WebNowPlaying-CLI";
    mpscd.url = "github:keifufu/mpscd";
    ags.url = "github:Aylur/ags";
    catppuccin.url = "github:catppuccin/nix";
    xivlauncher-rb.url = "github:drakon64/nixos-xivlauncher-rb";
    zen-browser.url = "github:fufexan/zen-browser-flake";
  };

  outputs = { nixpkgs, ... } @ inputs:
    let
      vars = {
        user = "keifufu";
        location = "/home/keifufu/.snowflake";
        symlink = "/stuff/symlink";
        secrets = "/stuff/secrets";
        walldir = "/smb/pictures/other/wallpapers";
        screenshotdir = "/smb/pictures/screenshots";
      };
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      nixosConfigurations = (
        import ./hosts/hosts.nix {
          inherit inputs vars;
        }
      );
    };
}
