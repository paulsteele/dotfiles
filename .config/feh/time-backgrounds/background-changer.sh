#!/bin/bash

hour="$(date +%H)"
hour="$(echo $hour | sed 's/^0*//')"
hour="$(($hour / 2 * 2))"

file="$hour-$(($hour + 2)).png"

filepath=~/.config/feh/time-backgrounds/backgrounds/$file

~/.local/bin/wal -i $filepath -n
/usr/bin/feh --bg-fill $filepath
