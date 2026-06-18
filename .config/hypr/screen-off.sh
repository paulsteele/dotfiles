#!/usr/bin/env bash

# Remember the current workspace so we can return to it
ACTIVE_WORKSPACE=$(hyprctl -j activeworkspace | jq -r '.name')

hyprctl output create headless
sleep 0.2
HEADLESS=$(hyprctl -j monitors | jq -r '.[] | select(.name | test("HEADLESS-"; "i")).name')
[ -z "$HEADLESS" ] && exit 1

hyprctl keyword monitor "$HEADLESS",3840x2160@119.88Hz,auto,1,vrr,3

hyprctl keyword monitor DP-1,disable

# Restore focus to the workspace we were on
hyprctl dispatch workspace "$ACTIVE_WORKSPACE"
