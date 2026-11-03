#!/usr/bin/env bash
set -euo pipefail

find_headless_output() {
	hyprctl -j monitors | jq -r '[.[] | select(.name | test("^HEADLESS-"; "i"))][0].name // empty'
}

wait_for_headless_output() {
	local attempt
	local expected_width=3840
	local expected_height=2160
	local expected_scale=1
	for ((attempt = 0; attempt < 10; attempt++)); do
		if hyprctl -j monitors | jq -e --arg name "$HEADLESS_OUTPUT" --argjson width "$expected_width" --argjson height "$expected_height" --argjson scale "$expected_scale" 'any(.[]; .name == $name and .disabled == false and .width == $width and .height == $height and .scale == $scale)' >/dev/null; then
			return 0
		fi
		sleep 0.2
	done
	return 1
}

WORKSPACE_SELECTOR_LUA=$(hyprctl -j activeworkspace | jq -er '"name:" + .name | @json')
HEADLESS_OUTPUT=$(find_headless_output)

if [ -z "$HEADLESS_OUTPUT" ]; then
	hyprctl output create headless
	sleep 0.2
	HEADLESS_OUTPUT=$(find_headless_output)
fi

if [ -z "$HEADLESS_OUTPUT" ]; then
	printf 'No headless output is available; keeping DP-1 enabled.\n' >&2
	exit 1
fi

HEADLESS_OUTPUT_LUA=$(jq -Rn --arg name "$HEADLESS_OUTPUT" '$name')
hyprctl eval "hl.monitor({ output = $HEADLESS_OUTPUT_LUA, disabled = false, mode = \"3840x2160@119.88Hz\", position = \"auto\", scale = 1, vrr = 3 })"

if ! wait_for_headless_output; then
	printf 'Headless output did not become ready; keeping DP-1 enabled.\n' >&2
	exit 1
fi

hyprctl eval 'hl.monitor({ output = "DP-1", disabled = true })'
hyprctl dispatch "hl.dsp.focus({ workspace = $WORKSPACE_SELECTOR_LUA })"
