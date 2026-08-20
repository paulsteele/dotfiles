#!/bin/bash

BATT_PERCENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [[ $CHARGING != "" ]]; then
  sketchybar -m --set battery \
    icon.color=0xFF61FFCA \
    icon= \
    label=$(printf "${BATT_PERCENT}%%")
  exit 0
fi

[[ ${BATT_PERCENT} -gt 10 ]] && COLOR=0xFFEDECEE || COLOR=0xFFFF6767

# Use stable Font Awesome codepoints present in the installed Nerd Font.
case ${BATT_PERCENT} in
    100|9[0-9]) ICON="" ;;
    8[0-9]|7[0-9]) ICON="" ;;
    6[0-9]|5[0-9]|4[0-9]) ICON="" ;;
    3[0-9]|2[0-9]|1[0-9]) ICON="" ;;
    *) ICON=""
esac

sketchybar -m --set battery\
  icon.color=$COLOR \
  icon=$ICON \
  label=$(printf "${BATT_PERCENT}%%")

