{
  description = "A snowflake, just like me";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    xremap.url = "github:xremap/nix-flake";
    dimland.url = "github:keifufu/dimland";
    wnpcli.url = "github:keifufu/WebNowPlaying-CLI";
    ags.url = "github:Aylur/ags";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, ... } @ inputs:
    let
      vars = {
        user = "keifufu";
        location = "/home/keifufu/.snowflake";
        symlink = "/stuff/symlink";
        secrets = "/stuff/secrets";
        walldir = "/smb/pictures/other/wallpapers";
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
