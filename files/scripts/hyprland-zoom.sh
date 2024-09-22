#!/usr/bin/env bash

current_zoom=$(hyprctl -j getoption cursor:zoom_factor | jq -r '.float')

if [[ -z $1 ]]; then
  echo "Please provide a zoom factor current_zoom: $current_zoom"
  exit 1
fi

if [[ $1 == +* ]] || [[ $1 == -* ]]; then
  new_zoom=$(echo "$current_zoom $1" | bc)
else
  new_zoom=$1
fi

if (( $(echo "$new_zoom < 1.000000" | bc -l) )); then
  echo "Zoom factor cannot be less than 1.000000. Setting to 1.000000."
  new_zoom="1.000000"
fi

echo "Zooming from $current_zoom to $new_zoom"
hyprctl keyword cursor:zoom_factor $new_zoom