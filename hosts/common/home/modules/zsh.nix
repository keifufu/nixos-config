{ pkgs, vars, ... }:

{
  programs.zsh = {
    enable = true;
    initExtra = ''
if [[ -n "$IN_NIX_SHELL" ]]; then
  VIRTUAL_ENV=nix-shell
  VIRTUAL_ENV_DISABLE_PROMPT=0
fi

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
    '';
    shellAliases = {
      ls = "eza --icons -a --group-directories-first";
      rebuild = "sudo nixos-rebuild switch --flake ${vars.location}# --impure && reload.sh";
      rebuild-nvidia = "sudo nixos-rebuild switch --flake ${vars.location}-nvidia# --impure && reload.sh";
      rebuild-upgrade = "nix flake update ${vars.location} && sudo nixos-rebuild switch --flake ${vars.location}# --impure && reload.sh";
      lazypush = "lazypush.sh";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "agnoster";
    };
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        file = "zsh-syntax-highlighting.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "e0165eaa730dd0fa321a6a6de74f092fe87630b0";
          sha256 = "sha256-4rW2N+ankAH4sA6Sa5mr9IKsdAg7WTgrmyqJ2V1vygQ=";
        };
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "82ca15e638cc208e6d8368e34a1625ed75e08f90";
          sha256 = "sha256-Rtg8kWVLhXRuD2/Ctbtgz9MQCtKZOLpAIdommZhXKdE=";
        };
      }
      {
        name = "zsh-shift-select";
        file = "zsh-shift-select.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "jirutka";
          repo = "zsh-shift-select";
          rev = "da460999b7d31aef0f0a82a3e749d70edf6f2ef9";
          sha256 = "sha256-ekA8acUgNT/t2SjSBGJs2Oko5EB7MvVUccC6uuTI/vc=";
        };
      }
    ];
  };
}
