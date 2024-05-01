#/usr/bin/env bash

pid=$(hyprctl activewindow | grep -oP 'pid: \K.*')

pactl set-sink-input-mute "$(pactl list sink-inputs | perl -ne '/^Sink Input #(\d+)/ && { $sinkid=$1 }; /^\s+application.process.id = "'"$pid"'"/ && print $sinkid;')" toggle

