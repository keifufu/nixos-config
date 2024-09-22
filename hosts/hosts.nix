{ inputs, vars, ... }:

{
  desktop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs vars;
      host = {
        hostName = "desktop";
      };
    };
    modules = [
      ./common/configuration/configuration.nix
      ./desktop/configuration.nix
      inputs.home-manager.nixosModules.home-manager {
        home-manager = {
          backupFileExtension = "hm-backup";
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
            ];
          };
        };
      }
    ];
  };
  laptop = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs vars;
      host = {
        hostName = "laptop";
      };
    };
    modules = [
      ./common/configuration/configuration.nix
      ./laptop/configuration.nix
      inputs.home-manager.nixosModules.home-manager {
        home-manager = {
          backupFileExtension = "hm-backup";
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
            ];
          };
        };
      }
    ];
  };
  server = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {
      inherit inputs vars;
      host.hostName = "server";
    };
    modules = [
      ./server/configuration.nix
    ];
  };
}
