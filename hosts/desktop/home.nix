{ pkgs, ... }:

{
  home.packages = [
    (pkgs.appimageTools.wrapType2 rec {
      pname = "osu-lazer-bin";
      version = "2024.906.2";
      src = pkgs.fetchurl {
        url = "https://github.com/ppy/osu/releases/download/${version}/osu.AppImage";
        hash = "sha256-zQnR3KwlE1gTWH8f+GDRBsc7Whfn9XpT1D/NLg5TtrU=";
      };
      extraPkgs = pkgs: with pkgs; [ icu ];
      extraInstallCommands =
        let
          contents = pkgs.appimageTools.extract { inherit pname version src; };
        in
        ''
          mv -v $out/bin/${pname} $out/bin/osu\!
          install -m 444 -D ${contents}/osu\!.desktop -t $out/share/applications
          for i in 16 32 48 64 96 128 256 512 1024; do
            install -D ${contents}/osu\!.png $out/share/icons/hicolor/''${i}x$i/apps/osu\!.png
          done
        '';
    })
  ];
}
