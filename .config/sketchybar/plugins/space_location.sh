#!/usr/bin/env bash

function GetNumberOfKeys() {
  i=0
  while true
  do
    /usr/libexec/PlistBuddy -c "print $1:$i" $HOME/Library/Preferences/com.apple.spaces.plist >/dev/null 2>/dev/null
    if [ $? -ne 0 ]; then
      echo $i
      return
    fi
    i=$(($i + 1))
  done
  echo $i
}

NUM_MONITORS=$(GetNumberOfKeys "SpacesDisplayConfiguration:Management\ Data:Monitors")

CURRENT_SPACE=1
MAX_SPACES=12

for ((i = 0; i < $NUM_MONITORS; i++))
do
  NUM_SPACES=$(GetNumberOfKeys "SpacesDisplayConfiguration:Management\ Data:Monitors:$i:Spaces")
  for ((j = 0; j < $NUM_SPACES; j++))
  do
    DISPLAY=$(($i + 1))
    sketchybar -m --set space_$CURRENT_SPACE associated_display=$DISPLAY associated_space=$CURRENT_SPACE
    CURRENT_SPACE=$(($CURRENT_SPACE + 1))
    if [ $CURRENT_SPACE -gt $MAX_SPACES ]
    then
      exit 0
    fi
  done
done
