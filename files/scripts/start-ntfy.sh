#!/usr/bin/env bash

TOPIC=$(cat $SNOWFLAKE_SECRETS/ntfy_topic);
ntfy subscribe "$TOPIC" 'notify-send -t 0 "$m"; pw-play "$SNOWFLAKE_FILES/sound/notification.mp3" --volume 0.75'