#/usr/bin/env bash

pkill .waybar-wrapped
pkill .ags-wrapped
if [[ "$1" == "waybar" ]]; then
  waybar >/dev/null 2>&1 & disown
else
  ags >/dev/null 2>&1 & disown
fi

hyprctl reload
# i dont know if restart had issues or if i
# was dumb and was using reload but whatever this works
# update: this sometimes fucks all up until i replug input devices
# i dont even know...
# systemctl --user stop xremap
# systemctl --user start xremap