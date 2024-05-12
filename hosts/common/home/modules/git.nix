{ vars, ... }:

{
  programs.git = {
    enable = true;
    userName = "keifufu";
    userEmail = "github@keifufu.dev";
    signing = {
      # imported by exec-once in hyprland, scuffed but it'll do for now :v
      key = "861CB7ABE74F8EAD";
      signByDefault = true;
    };
    extraConfig = {
      core.sshcommand = "ssh -i ${vars.secrets}/git-ssh-key";
      init.defaultBranch = "main";
      pull.rebase = false;
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };
}