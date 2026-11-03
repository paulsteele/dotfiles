#!/usr/bin/env bash
set -euo pipefail

is_dp1_active() {
	hyprctl -j monitors | jq -e 'any(.[]; .name == "DP-1" and .disabled == false)' >/dev/null
}

wait_for_dp1() {
	local max_attempts=$1
	local attempt
	for ((attempt = 0; attempt < max_attempts; attempt++)); do
		if is_dp1_active; then
			return 0
		fi
		sleep 0.2
	done
	return 1
}

hyprctl eval 'hl.monitor({ output = "DP-1", disabled = false, mode = "3840x2160@119.88Hz", position = "auto", scale = 1, vrr = 3 })'

if ! wait_for_dp1 10; then
	hyprctl reload
	if ! wait_for_dp1 25; then
		printf 'DP-1 did not become active; keeping headless outputs.\n' >&2
		exit 1
	fi
fi

hyprctl dispatch 'hl.dsp.dpms({ action = "on", monitor = "DP-1" })'

if ! is_dp1_active; then
	printf 'DP-1 is no longer active; keeping headless outputs.\n' >&2
	exit 1
fi

HEADLESS_OUTPUTS=$(hyprctl -j monitors all | jq -r '.[] | select(.name | test("^HEADLESS-"; "i")).name')
while IFS= read -r output; do
	if [ -z "$output" ]; then
		continue
	fi
	hyprctl output remove "$output"
done <<< "$HEADLESS_OUTPUTS"
