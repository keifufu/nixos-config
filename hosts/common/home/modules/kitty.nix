{
  programs.kitty = {
    enable = true;
    catppuccin.enable = true;
    extraConfig = ''
      confirm_os_window_close 0
      # Don't intercept the following key strokes to make zsh-shift-select work.
      map ctrl+shift+left no_op
      map ctrl+shift+right no_op
      map ctrl+shift+home no_op
      map ctrl+shift+end no_op
    '';
  };
}