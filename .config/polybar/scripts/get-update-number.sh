#!/bin/sh
if [ -x "$(command -v checkupdates)" ] && [ -x "$(command -v yay)" ]; then
  PACKAGES="$(checkupdates 2> /dev/null | wc -l)"
  PACKAGES=$((PACKAGES + $(yay -Qum 2> /dev/null | wc -l)))
elif [ -x "$(command -v apt)" ]; then
  # Suppress error from apt about cli being unstable
  # This method is much simpler / faster than parsing apt-get
  # and fairly easy to tell if there is an issue
  PACKAGES=$(apt list -u 2>/dev/null | wc -l)
  # Remove header line
  PACKAGES=$((PACKAGES - 1))
else
  PACKAGES="Can't be determined"
fi

echo "$PACKAGES"
