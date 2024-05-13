#!/usr/bin/env bash

if [ "$(hostname)" != "laptop" ]; then
  echo "This script is intended to run on laptop only."
  exit 1
fi

if [[ "$1" == "status" ]]; then
  if systemctl is-active --quiet --user xremap-mouse; then
    icon="󰍽"
    class="on"
    status="xremap mouse enabled"
  else
    icon="󰍾"
    class="off"
    status="xremap mouse disabled"
  fi
  printf '{"text": "%s", "class": "%s", "tooltip": "%s"}\n' "$icon" "$class" "$status"
elif [[ "$1" == "toggle" ]]; then
  if systemctl is-active --quiet --user xremap-mouse; then
    systemctl stop --user xremap-mouse
    systemctl start --user xremap
    echo "mouse stopped"
  else
    systemctl stop --user xremap
    systemctl start --user xremap-mouse
    echo "mouse started"
  fi
else
  echo "Usage: xremap.sh [status|toggle]"
  exit 1
fi