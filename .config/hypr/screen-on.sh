#!/usr/bin/env bash

# screen-off.sh disabled DP-1 and offloaded all workspaces to a headless output.
# Bring the physical OLED back reliably, then tear the headless output down.
#
# Note: plain `keyword monitor DP-1,...` does NOT recover the broken state
# (re-issuing it, even repeatedly, is a no-op when the DP link dropped or
# Hyprland's monitor is stuck disabled), so we escalate to `hyprctl reload`,
# which re-reads hyprland.conf and re-probes every DRM connector.

is_dp1_active() {
	# `hyprctl -j monitors` lists only active monitors, so a disabled or
	# link-dropped DP-1 simply won't appear here.
	[ "$(hyprctl -j monitors | jq -r '.[] | select(.name=="DP-1").name')" = "DP-1" ]
}

wait_for_dp1() {
	# $1 = number of 0.2s polls before giving up.
	for _ in $(seq 1 "$1"); do
		is_dp1_active && return 0
		sleep 0.2
	done
	return 1
}

HEADLESS=$(hyprctl -j monitors | jq -r '.[] | select(.name | test("HEADLESS-"; "i")).name')

# 1) Normal path: re-apply the monitor rule and give the panel a moment to wake.
hyprctl keyword monitor DP-1,3840x2160@119.88Hz,auto,1,vrr,3

# 2) Recovery path: if DP-1 didn't come back, force a full re-probe.
if ! wait_for_dp1 10; then
	hyprctl reload
	wait_for_dp1 25
fi

# 3) Ensure the panel is powered on (in case it was left in DPMS off).
hyprctl dispatch dpms on DP-1

# 4) Remove the headless output only once DP-1 is confirmed live, so we never
#    drop to zero monitors or strand workspaces on a vanishing output.
if is_dp1_active && [ -n "$HEADLESS" ]; then
	hyprctl output remove "$HEADLESS"
fi
