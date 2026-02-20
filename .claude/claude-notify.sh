#!/usr/bin/env bash
# Usage: claude-notify.sh <message>
# Sends a system notification that focuses the correct Alacritty window on click.

MSG="${1:-Task complete}"
TITLE="Claude Code"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ "$(uname)" = "Darwin" ]; then
  terminal-notifier \
    -title "$TITLE" \
    -message "$MSG" \
    -sound default \
    -activate com.github.alacritty
else
  dunstify "$TITLE" "$MSG"
fi
