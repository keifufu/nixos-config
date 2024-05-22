#!/usr/bin/env bash

if [ -z "$XDG_CACHE_HOME" ]; then
  echo "Environment variable XDG_CACHE_HOME is missing"
  exit 1
fi

if [ "$#" -lt 1 ]; then
  echo "Usage: brightness.sh <get|set|scan|refresh> [brightness] (+|-)"
  exit 1
fi

function set_brightness() {
  brightness="$1"

  if [ ! -f "$XDG_CACHE_HOME/.brightness-scan" ]; then
    echo "No scan output found"
    exit 1
  fi

  # TODO: handle following case:
  # current brightness: 50
  # new brightness: -50
  # this will start dimland but not set monitors to 0
  # can do by reading current brightness from file before overriding, and checking if its > 0, then setting monitors to 0
  # TODO: but my one dumb monitor does not retain brightness from last session?

  if [[ "$brightness" -lt 0 ]]; then
    echo "$brightness" > "$XDG_CACHE_HOME/.brightness"
    brightness=${brightness#-}
    brightness=$((brightness > 90 ? 90 : brightness))
    echo "-$brightness" > "$XDG_CACHE_HOME/.brightness"
    brightness=$(echo "scale=2; $brightness / 100" | bc)
    brightness="0$brightness"
    dimland -a $brightness -r 20
    exit 0
  else
    dimland -a 0 -r 20
  fi

  brightness=$((brightness > 100 ? 100 : brightness))
  echo "$brightness" > "$XDG_CACHE_HOME/.brightness"

  # kill existing brightness.sh script because ddccontrol commands take a while
  kill -9 $(pgrep -f ${BASH_SOURCE[0]} | grep -v $$) >/dev/null 2>&1
  # Wait for a bit to not spam commands when scrolling brightness
  sleep 0.3

  while IFS= read -r line; do
    if [ -n "$line" ]; then
      ddccontrol -r 0x10 -w "$brightness" "$line" &
    fi
  done < "$XDG_CACHE_HOME/.brightness-scan"
}

if [ "$1" == "get" ]; then
  current_brightness=$(cat "$XDG_CACHE_HOME/.brightness" 2>/dev/null || echo "0")
  if [ "$#" -eq 2 ] && [ "$2" == "--json" ]; then
    echo "{\"percentage\": $current_brightness}"
  else
    echo "$current_brightness"
  fi
elif [ "$1" == "set" ]; then
  if [ "$#" -lt 2 ]; then
    echo "Usage: brightness.sh <get|set> [(+|-)brightness]"
    exit 1
  fi

  brightness="$2"
  relative="$3"

  if [[ -n "$relative" ]]; then
    current_brightness=$(cat "$XDG_CACHE_HOME/.brightness" 2>/dev/null || echo "0")
    brightness=$((current_brightness + ${relative}${brightness}))
  fi

  set_brightness "$brightness"
elif [ "$1" == "refresh" ]; then
  brightness=$(cat "$XDG_CACHE_HOME/.brightness" 2>/dev/null || echo "0")
  set_brightness "$brightness"
elif [ "$1" == "scan" ]; then
  ddccontrol -p | grep 'Device:' | awk -F': ' '{print $2}' > "$XDG_CACHE_HOME/.brightness-scan"
  cat "$XDG_CACHE_HOME/.brightness-scan"
else
  echo "Usage: brightness.sh <get|set|scan|refresh> [(+|-)brightness]"
  exit 1
fi