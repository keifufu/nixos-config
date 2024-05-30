#!/usr/bin/env bash

TOPIC=$(cat $NIXOS_SECRETS/ntfy_topic);
ntfy subscribe "$TOPIC" 'notify-send -t 0 "$m"; paplay --volume 45000 "$NIXOS_FILES/sound/ntfy.mp3"'
