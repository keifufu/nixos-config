{ pkgs, ... }:

{
  home.packages = with pkgs; [
    clang-tools # for clang-format
    pnpm
    nodejs
    zip
  ];

  # Note: settings are symlinked in hosts/common/configuration/modules/symlink.nix
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      # streetsidesoftware.code-spell-checker
      serayuzgur.crates
      rust-lang.rust-analyzer
      formulahendry.auto-rename-tag
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      naumovs.color-highlight
      usernamehw.errorlens
      dbaeumer.vscode-eslint
      tamasfe.even-better-toml
      github.vscode-github-actions
      eamodio.gitlens
      ms-vscode.live-server
      bbenoist.nix
      esbenp.prettier-vscode
      humao.rest-client
      llvm-vs-code-extensions.vscode-clangd
      xaver.clang-format
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "markdown-preview-github-styles";
        publisher = "bierner";
        version = "2.0.2";
        sha256 = "sha256-GiSS9gCCmOfsBrzahJe89DfyFyJJhQ8tkXVJbfibHQY=";
      }
      {
        name = "BongoCat";
        publisher = "pixl-garden";
        version = "0.0.1";
        sha256 = "sha256-AyFDJZojea8jmCujhLgKVYdLBKSAdbHKc+83j8KRCwU=";
      }
      {
        name = "lazygit";
        publisher = "ChaitanyaShahare";
        version = "1.0.6";
        sha256 = "sha256-XijRju6mS3spdFPay0odb9G9EJKawyZwzvTuDWjIQFg=";
      }
    ];
  };

  programs.lazygit = {
    enable = true;
    settings = {};
  };
}
