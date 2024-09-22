{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 18;
  };

  gtk = {
    enable = true;
    font.name = "FiraCode Nerd Font Mono Medium";
    theme = {
      name = "Catppuccin-GTK-Purple-Dark-Compact";
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "purple" ];
        shade = "dark";
        size = "compact";
      };
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  home.packages = with pkgs; [
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    dart-sass
  ];

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