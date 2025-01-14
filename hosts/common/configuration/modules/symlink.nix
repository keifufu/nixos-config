{ vars, ... }:

{
  # -h checks if it's a symbolic link, if it's not, we delete it and create a link
  system.userActivationScripts.symlink = ''
    if [[ ! -h "$HOME/.config/VSCodium/User/settings.json" ]]; then
      mkdir -p $HOME/.config/VSCodium/User
      rm -rf $HOME/.config/VSCodium/User/settings.json
      ln -s "${vars.location}/files/config/vscode.json" "$HOME/.config/VSCodium/User/settings.json"
    fi
    if [[ ! -h "$HOME/.mozilla" ]]; then
      rm -rf $HOME/.mozilla
      ln -s "${vars.symlink}/.mozilla" "$HOME/.mozilla"
    fi
    if [[ ! -h "$HOME/.zen" ]]; then
      rm -rf $HOME/.zen
      ln -s "${vars.symlink}/.zen" "$HOME/.zen"
    fi
    if [[ ! -h "$HOME/Downloads" ]]; then
      rm -rf $HOME/Downloads
      ln -s "${vars.symlink}/Downloads" "$HOME/Downloads"
    fi
    if [[ ! -h "$HOME/.xlcore" ]]; then
      rm -rf $HOME/.xlcore
      ln -s "${vars.symlink}/.xlcore" "$HOME/.xlcore"
    fi
    if [[ ! -h "$HOME/.config/lutris" ]]; then
      rm -rf $HOME/.config/lutris
      ln -s "${vars.symlink}/lutris" "$HOME/.config/lutris"
    fi
    if [[ ! -h "$HOME/.config/obs-studio" ]]; then
      rm -rf $HOME/.config/obs-studio
      ln -s "${vars.symlink}/obs-studio" "$HOME/.config/obs-studio"
    fi
    if [[ ! -h "$HOME/.config/OpenRGB" ]]; then
      rm -rf $HOME/.config/OpenRGB
      ln -s "${vars.symlink}/OpenRGB" "$HOME/.config/OpenRGB"
    fi
    if [[ ! -h "$HOME/.local/share/reshade" ]]; then
      rm -rf $HOME/.local/share/reshade
      ln -s "${vars.symlink}/reshade" "$HOME/.local/share/reshade"
    fi
    if [[ ! -h "$HOME/.local/share/PrismLauncher" ]]; then
      rm -rf $HOME/.local/share/PrismLauncher
      ln -s "${vars.symlink}/PrismLauncher" "$HOME/.local/share/PrismLauncher"
    fi
    if [[ ! -h "$HOME/.local/share/fonts" ]]; then
      rm -rf $HOME/.local/share/fonts
      ln -s "${vars.symlink}/fonts" "$HOME/.local/share/fonts"
    fi
  '';
}
