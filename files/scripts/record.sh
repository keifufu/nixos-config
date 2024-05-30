#!/usr/bin/env bash

if [ -z "$XDG_CACHE_HOME" ]; then
  echo "Environment variable XDG_CACHE_HOME is missing"
  exit 1
fi

if [ "$1" == "status" ]; then
  if pgrep -x "wf-recorder" > /dev/null; then
    echo "󰑊 Recording"
  fi
  exit 0
fi

OUTPATH="/smb/screenshots/videos"
VIDEOPATH="$OUTPATH/$(date '+%Y-%m-%dT%H-%M-%S.mp4')"
THUMBNAIL="$XDG_CACHE_HOME/.recording-thumbnail.png"

if [[ ! -d "$OUTPATH" ]]; then
  notify-send -u critical "/smb inaccessible"
  exit 1
fi

if pgrep -x "wf-recorder" > /dev/null; then
  id=$(cat "$XDG_CACHE_HOME/.recording-id")
  pkill -SIGINT -x "wf-recorder"
  
  notify-send -t 0 -r $id "Saving video..."

  while pgrep -x wf-recorder > /dev/null; do
    sleep 0.1
  done

  ffmpeg -y -i "$VIDEOPATH" -ss 00:00:01 -vframes 1 "$THUMBNAIL"

  wl-copy < "$VIDEOPATH"
  notify-send -t 5000 -r $id -i $THUMBNAIL "Done recording"
elif [ "$1" == "--audio" ]; then
  wf-recorder -x yuv420p --audio="$(pactl get-default-sink).monitor" -g "$(slurp -b "#cad3f533" -c "#ffffffff" -d)" -f $TMPVIDEO <<<Y
else
  # "-x yuv420p" see https://github.com/ammen99/wf-recorder/issues/218#issuecomment-1710702237
  id=$(notify-send -t 0 "Recording..." --print-id)
  echo $id > "$XDG_CACHE_HOME/.recording-id"
  wf-recorder -x yuv420p -g "$(slurp -b "#cad3f533" -c "#ffffffff" -d)" -f $VIDEOPATH <<<Y
fi