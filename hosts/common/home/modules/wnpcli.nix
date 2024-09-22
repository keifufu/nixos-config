{ inputs, ... }:

{
  imports = [
    inputs.wnpcli.homeManagerModules.wnpcli
  ];

  programs.wnpcli = {
    enable = true;
    service.enable = true;
  };
}