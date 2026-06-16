#!/usr/bin/env bash

HEADLESS=$(hyprctl -j monitors | jq -r '.[] | select(.name | test("HEADLESS-"; "i")).name')

hyprctl keyword monitor DP-1,3840x2160@119.88Hz,auto,1,vrr,3

hyprctl output remove "$HEADLESS"
