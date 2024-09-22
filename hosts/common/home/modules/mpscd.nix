{ inputs, ... }:

{
  imports = [
    inputs.mpscd.homeManagerModules.mpscd
  ];

  programs.mpscd = {
    enable = true;
  };
}