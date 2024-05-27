#!/usr/bin/env bash

# Run `brightness.sh scan` and `brightness.sh refresh` on startup
# This uses dimland for -90 to 0
# and ddccontrol and $BACKLIGHT for 0 to 100

if [[ "$(hostname)" == "laptop" ]]; then
  BACKLIGHT="/sys/class/backlight/amdgpu_bl1/brightness"
fi

if [ -z "$XDG_CACHE_HOME" ]; then
  echo "Environment variable XDG_CACHE_HOME is missing"
  exit 1
fi

if [ "$#" -lt 1 ]; then
  echo "Usage: brightness.sh <get|set|scan|refresh> [brightness] (+|-)"
  exit 1
fi

function set_monitor_brightness() {
  brightness="$1"

  if [[ -n "$BACKLIGHT" ]]; then
    echo "$brightness" | sudo tee "$BACKLIGHT" > /dev/null
  fi

  while IFS= read -r line; do
    if [ -n "$line" ]; then
      ddccontrol -s -r 0x10 -w "$brightness" "$line" &
    fi
  done < "$XDG_CACHE_HOME/.brightness-scan"
  wait
  echo "$brightness" > "$XDG_CACHE_HOME/.brightness-monitor"
}

function set_brightness() {
  brightness="$1"
  refresh="$2"

  if [ ! -f "$XDG_CACHE_HOME/.brightness-scan" ]; then
    echo "No scan output found"
    exit 1
  fi

  if [[ "$brightness" -lt 0 ]]; then
    echo "$brightness" > "$XDG_CACHE_HOME/.brightness"
    brightness=${brightness#-}
    brightness=$((brightness > 90 ? 90 : brightness))
    echo "-$brightness" > "$XDG_CACHE_HOME/.brightness"
    brightness=$(echo "scale=2; $brightness / 100" | bc)
    brightness="0$brightness"
    dimland -a $brightness

    monitor_brightness=$(cat "$XDG_CACHE_HOME/.brightness-monitor" 2>/dev/null || echo "100")
    if [[ "$monitor_brightness" != 0 || "$refresh" == "true" ]]; then
      set_monitor_brightness "0"
    fi

    exit 0
  else
    dimland -a 0
  fi

  brightness=$((brightness > 100 ? 100 : brightness))
  echo "$brightness" > "$XDG_CACHE_HOME/.brightness"

  # kill existing brightness.sh script because ddccontrol commands take a while
  kill -9 $(pgrep -f ${BASH_SOURCE[0]} | grep -v $$) >/dev/null 2>&1
  # Wait for a bit to not spam commands when scrolling brightness
  sleep 0.3

  set_monitor_brightness "$brightness"
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
  # refresh is used to set the correct brightness at startup
  # as well as improving ddccontrol performance by its daemon
  # keeping devices opened after using them once
  brightness=$(cat "$XDG_CACHE_HOME/.brightness" 2>/dev/null || echo "0")
  set_brightness "$brightness" "true"
elif [ "$1" == "scan" ]; then
  ddccontrol -p | grep 'Device:' | awk -F': ' '{print $2}' > "$XDG_CACHE_HOME/.brightness-scan"
  cat "$XDG_CACHE_HOME/.brightness-scan"
else
  echo "Usage: brightness.sh <get|set|scan|refresh> [(+|-)brightness]"
  exit 1
fi