#!/bin/bash

hour="$(date +%H)"
hour="$(echo $hour | sed 's/^0*//')"
hour="$(($hour / 2 * 2))"

file="$hour-$(($hour + 2)).png"

~/.local/bin/wal -i ~/.config/feh/time-backgrounds/backgrounds/$file
