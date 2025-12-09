#!/bin/bash

MON=""
SCALE="1.5"

monitor-sensor | while read -r line; do
  case "$line" in
    *"orientation changed: normal"*)
      hyprctl keyword monitor "$MON,,,$SCALE,transform,0"
      hyprctl keyword input:touchdevice:transform 0
      ;;
    *"orientation changed: left-up"*)
      hyprctl keyword monitor "$MON,,,$SCALE,transform,1"
      hyprctl keyword input:touchdevice:transform 1
      ;;
    *"orientation changed: bottom-up"*)
      hyprctl keyword monitor "$MON,,,$SCALE,transform,2"
      hyprctl keyword input:touchdevice:transform 2
      ;;
    *"orientation changed: right-up"*)
      hyprctl keyword monitor "$MON,,,$SCALE,transform,3"
      hyprctl keyword input:touchdevice:transform 3
      ;;
  esac
done

