#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar
DISPLAY1="$(xrandr -q | grep 'eDP1\|VGA-1\|rdp2\|HDMI2\|Virtual1\|DP-0' | cut -d ' ' -f1)"
DISPLAY2="$(xrandr -q | grep 'HDMI1\|VGA-2\|rdp1\|Virtual2\|DP-3' | cut -d ' ' -f1)"
DISPLAY3="$(xrandr -q | grep 'rdp0\|VGA-3' | cut -d ' ' -f1)"

if [[ ! -z "$DISPLAY1" ]]; then     
  export MONITOR="$DISPLAY1" 
  polybar top & 
  polybar bottom &
fi

if [[ ! -z $DISPLAY2 ]]; then
  export MONITOR=$DISPLAY2 
  polybar top & 
  polybar bottom &
fi

if [[ ! -z $DISPLAY3 ]]; then 
  export MONITOR=$DISPLAY3 
  polybar top & 
  polybar bottom &
fi
