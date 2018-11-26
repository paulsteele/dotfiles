#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar
DISPLAY1="$(xrandr -q | grep 'eDP1\|VGA-1\|rdp2\|HDMI2' | cut -d ' ' -f1)"
[[ ! -z "$DISPLAY1" ]] && MONITOR="$DISPLAY1" polybar bar &

DISPLAY2="$(xrandr -q | grep 'HDMI1\|VGA-2\|rdp1' | cut -d ' ' -f1)"
[[ ! -z $DISPLAY2 ]] && MONITOR=$DISPLAY2 polybar bar &

DISPLAY3="$(xrandr -q | grep 'rdp0' | cut -d ' ' -f1)"
[[ ! -z $DISPLAY3 ]] && MONITOR=$DISPLAY3 polybar bar &
