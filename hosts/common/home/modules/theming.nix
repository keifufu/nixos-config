{ lib, pkgs, ... }:

{
  gtk = {
    enable = true;
    catppuccin.enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "mauve";
      };
    };
    font = {
      name = "FiraCode Nerd Font Mono Medium";
    };
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 16;
  };

  xdg.configFile."kdeglobals".source = "${(pkgs.catppuccin-kde.override {
    flavour = ["mocha"];
    accents = ["mauve"];
    winDecStyles = ["modern"];
  })}/share/color-schemes/CatppuccinMochaMauve.colors";

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
  };

  home.sessionVariables = {
    DISABLE_QT5_COMPAT = "0";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
  };
  
  xdg.configFile."Kvantum/kvantum.kvconfig".source = (pkgs.formats.ini {}).generate "kvantum.kvconfig" {
    General.theme = "Catppuccin-Mocha-Mauve";
  };

  xdg.configFile = {
    "qt5ct/qt5ct.conf".source = pkgs.substituteAll {
      src = ./qt5ct.conf;
      themePath = "${pkgs.catppuccin-qt5ct}/share/qt5ct/colors/Catppuccin-Mocha.conf";
    };
    "qt6ct/qt6ct.conf".source = pkgs.substituteAll {
      src = ./qt5ct.conf;
      themePath = "${pkgs.catppuccin-qt5ct}/share/qt5ct/colors/Catppuccin-Mocha.conf";
    };
  };
}