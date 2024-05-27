{ inputs, vars, ... }:

let
  system = "x86_64-linux";
  hmModule = inputs.home-manager.nixosModules.home-manager;
  catppuccinModule = inputs.catppuccin.nixosModules.catppuccin;
  catppuccinHmModule = inputs.catppuccin.homeManagerModules.catppuccin;
  xremapHmModule = inputs.xremap.homeManagerModules.default;
  dimlandHmModule = inputs.dimland.homeManagerModules.dimland;
  inherit (inputs.nixpkgs.lib) nixosSystem;
in
{
  desktop = nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs vars;
      host = {
        hostName = "desktop";
      };
    };
    modules = [
      ./common/configuration/configuration.nix
      ./desktop/configuration.nix
      catppuccinModule
      hmModule {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs vars;
            host.hostName = "desktop";
          };
          users.${vars.user} = {
            imports = [
              ./common/home/home.nix
              ./desktop/home.nix
              catppuccinHmModule
              xremapHmModule
              dimlandHmModule
            ];
          };
        };
      }
    ];
  };
  laptop = nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs vars;
      host = {
        hostName = "laptop";
      };
    };
    modules = [
      ./common/configuration/configuration.nix
      ./laptop/configuration.nix
      catppuccinModule
      hmModule {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs vars;
            host.hostName = "laptop";
          };
          users.${vars.user} = {
            imports = [
              ./common/home/home.nix
              ./laptop/home.nix
              catppuccinHmModule
              xremapHmModule
              dimlandHmModule
            ];
          };
        };
      }
    ];
  };
  server = nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs vars;
      host.hostName = "server";
    };
    modules = [
      ./server/configuration.nix
    ];
  };
}
