#!/usr/bin/env bash

if [ "$#" -lt 1 ]; then
  echo "Usage: brightness.sh <get|set|scan> [(+|-)brightness]"
  exit 1
fi

operation="$1"

if [ "$operation" == "get" ]; then
  current_brightness=$(cat ~/.brightness 2>/dev/null || echo "0")
  if [ "$#" -eq 2 ] && [ "$2" == "--json" ]; then
    echo "{\"percentage\": $current_brightness}"
  else
    echo "$current_brightness"
  fi
elif [ "$operation" == "set" ]; then
  if [ "$#" -ne 2 ]; then
    echo "Usage: brightness.sh <get|set> [(+|-)brightness]"
    exit 1
  fi

  if [ ! -f ~/.brightness-scan ]; then
    echo "No scan output found"
    exit 1
  fi

  input_brightness="$2"
  if [[ "$input_brightness" =~ ^[+-][0-9]+$ ]]; then
    current_brightness=$(cat ~/.brightness 2>/dev/null || echo "0")
    new_brightness=$((current_brightness + input_brightness))

    if [[ "$new_brightness" -lt 0 ]]; then
      echo "$new_brightness" > ~/.brightness
      new_brightness=${new_brightness#-}
      new_brightness=$((new_brightness > 90 ? 90 : new_brightness))
      echo "-$new_brightness" > ~/.brightness
      new_brightness=$(echo "scale=2; $new_brightness / 100" | bc)
      brightness="0$new_brightness"
      pkill -f "dimland[^r]*$" # do not kill dimland with radius
      dimland -a $brightness &
      exit 0
    else
      pkill -f "dimland[^r]*$" # do not kill dimland with radius
    fi

    new_brightness=$((new_brightness > 100 ? 100 : new_brightness))
    brightness="$new_brightness"
  else
    brightness="$input_brightness"
  fi

  echo "$brightness" > ~/.brightness
  kill -9 $(pgrep -f ${BASH_SOURCE[0]} | grep -v $$) >/dev/null 2>&1

  # Wait for a bit to not spam commands when scrolling brightness
  sleep 0.3

  while IFS= read -r line; do
    if [ -n "$line" ]; then
      ddccontrol -r 0x10 -w "$brightness" "$line" &
    fi
  done < ~/.brightness-scan
elif [ "$operation" == "scan" ]; then
  ddccontrol -p | grep 'Device:' | awk -F': ' '{print $2}' > ~/.brightness-scan
  cat ~/.brightness-scan
else
  echo "Usage: brightness.sh <get|set|scan> [(+|-)brightness]"
  exit 1
fi