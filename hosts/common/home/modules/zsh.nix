{ pkgs, vars, ... }:

{
  # TODO: maybe add zoxide to zsh and yazi for better cd
  # TODO: yazi bookmarks
  # TODO: yazi cd? dont wanna move around manually

  programs.zsh = {
    enable = true;
    initExtra = ''
      if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${vars.user}.zsh" ]];
      then
        source "$XDG_CACHE_HOME/p10k-instant-prompt-${vars.user}.zsh"
      fi

      [[ ! -f ${vars.location}/files/config/p10k.zsh ]] || source ${vars.location}/files/config/p10k.zsh
    '';
    shellAliases = {
      ls = "eza --all --icons --group-directories-first --no-permissions --octal-permissions --time-style long-iso";
      rebuild = "sudo nixos-rebuild switch --flake ${vars.location}# --impure && reload.sh";
      lsblk = "lsblk -o name,size,type,mountpoints,label";
      sudow = "sudo -EH";
    };
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    plugins = [
      {
        name = "powerlevel10k";
        file = "powerlevel10k.zsh-theme";
        src = pkgs.fetchFromGitHub {
          owner = "romkatv";
          repo = "powerlevel10k";
          rev = "16e58484262de745723ed114e09217094655eaaa";
          sha256 = "sha256-3grB3psh134qZOKOzWhJTaLdPpBQHjVC6y6dS/hJEYE=";
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
