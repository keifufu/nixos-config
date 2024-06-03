#!/usr/bin/env bash

TOPIC=$(cat $NIXOS_SECRETS/ntfy_topic);
ntfy subscribe "$TOPIC" 'notify-send -t 0 "$m"; pw-play "$NIXOS_FILES/sound/ntfy.mp3" --volume 0.75'
