#!/usr/bin/env bash

# ── config: icons ──
ICON_MODEL=""         # nf-oct-cpu
ICON_CTX="󱐖"          # nf-md-pac_man
ICON_COST=" "          # nf-fa-sack_dollar 
ICON_TIME="󰅐"          # nf-md-clock_outline
ICON_API="󰓅"          # nf-md-lightning_bolt_outline
ICON_DIFF="󰏫"          # nf-md-pencil_outline
ICON_RATE_5H=""       # nf-fa-hourglass_half 
ICON_RATE_7D="󰃮"       # nf-md-calendar_outline
SEP="│"

# ── config: colors (ANSI) ──
C_MODEL="1;35"
C_CTX="1;32"
C_COST="1;36"
C_TIME="1;34"
C_API="0;34"
C_DIFF_ADD="1;32"
C_DIFF_DEL="1;31"
C_RATE_OK="0;32"
C_RATE_WARN="1;33"
C_RATE_CRIT="1;31"
C_RESET="\033[0m"

# ── single jq pass for all fields ──
input=$(cat)
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "model=\(.model.display_name // "")",
  @sh "used_pct=\(.context_window.used_percentage // "")",
  @sh "cost_usd=\(.cost.total_cost_usd // "")",
  @sh "duration_ms=\(.cost.total_duration_ms // "")",
  @sh "api_duration_ms=\(.cost.total_api_duration_ms // "")",
  @sh "lines_added=\(.cost.total_lines_added // "")",
  @sh "lines_removed=\(.cost.total_lines_removed // "")",
  @sh "rate_5h=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "rate_7d=\(.rate_limits.seven_day.used_percentage // "")"
')"

# ── helper ──
c() { printf '\033[%sm%s\033[0m' "$1" "$2"; }

rate_color() {
  pct=$(printf '%.0f' "$1")
  if [ "$pct" -ge 80 ] 2>/dev/null; then echo "$C_RATE_CRIT"
  elif [ "$pct" -ge 50 ] 2>/dev/null; then echo "$C_RATE_WARN"
  else echo "$C_RATE_OK"; fi
}

# ── build parts ──
parts=()

[ -n "$model" ]          && parts+=("$(c "$C_MODEL" "$ICON_MODEL $model")")
[ -n "$used_pct" ]       && parts+=("$(c "$C_CTX" "$ICON_CTX $(printf '%.0f' "$used_pct")%")")
[ -n "$cost_usd" ]       && parts+=("$(c "$C_COST" "${ICON_COST}$(printf '%.2f' "$cost_usd")")")

[ -n "$duration_ms" ]    && parts+=("$(c "$C_TIME" "$ICON_TIME $(awk "BEGIN {printf \"%.1f\", $duration_ms / 1000}")s")")
[ -n "$api_duration_ms" ] && parts+=("$(c "$C_API" "$ICON_API $(awk "BEGIN {printf \"%.1f\", $api_duration_ms / 1000}")s")")

if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  diff_str=""
  [ -n "$lines_added" ]  && diff_str="$(c "$C_DIFF_ADD" "+$lines_added")"
  [ -n "$lines_removed" ] && diff_str="${diff_str:+$diff_str }$(c "$C_DIFF_DEL" "-$lines_removed")"
  parts+=("$ICON_DIFF $diff_str")
fi

[ -n "$rate_5h" ] && parts+=("$(c "$(rate_color "$rate_5h")" "$ICON_RATE_5H 5h $(printf '%.0f' "$rate_5h")%")")
[ -n "$rate_7d" ] && parts+=("$(c "$(rate_color "$rate_7d")" "$ICON_RATE_7D 7d $(printf '%.0f' "$rate_7d")%")")

# ── render ──
printf '%s' "${parts[0]}"
for part in "${parts[@]:1}"; do
  printf ' %s %s' "$SEP" "$part"
done
printf '\n'
