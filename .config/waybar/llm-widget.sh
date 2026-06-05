#!/usr/bin/env bash
set -euo pipefail

LLAMA_SVC="llama-server"
WEBUI_SVC="open-webui"

# Colors for rofi (catppuccin mocha)
ROFI_THEME="--theme-str 'window { background: #2e3440; border: 1px solid #4c566a; }
                       textbox { color: #81a1c1; }
                       listview { color: #eceff4; }
                       element { border-color: #4c566a; }
                       element.normal { color: #eceff4; }
                       element.selected { background: #88c0d0; color: #2e3440; }
                       element-symbol.normal { color: #ebcb8b; }
                       element-symbol.selected { color: #88c0d0; }
                       button { padding: 8px 16px; }'"

get_status() {
    local svc="$1"
    local state
    state=$(systemctl --user is-active "$svc" 2>/dev/null) || true
    if [[ -z "$state" ]]; then
        state="inactive"
    fi
    echo "$state"
}

get_uptime() {
    local svc="$1"
    local state
    state=$(get_status "$svc")
    if [[ "$state" != "active" ]]; then
        echo "-"
        return
    fi
    local ts
    ts=$(systemctl --user show "$svc" --property=ActiveEnterTimestamp 2>/dev/null | cut -d= -f2)
    if [[ -n "$ts" && "$ts" != "" ]]; then
        local start_epoch
        start_epoch=$(date -d "$ts" +%s 2>/dev/null || echo "0")
        if [[ "$start_epoch" -gt 0 ]]; then
            local now_epoch
            now_epoch=$(date +%s)
            local diff=$((now_epoch - start_epoch))
            local mins=$((diff / 60))
            local secs=$((diff % 60))
            printf "%d:%02d" "$mins" "$secs"
            return
        fi
    fi
    echo "-"
}

cmd_status() {
    local llama_state webui_state
    llama_state=$(get_status "$LLAMA_SVC")
    webui_state=$(get_status "$WEBUI_SVC")

    local llama_icon webui_icon llama_class webui_class
    if [[ "$llama_state" == "active" ]]; then
        llama_icon="🟢"
        llama_class="llama-running"
    else
        llama_icon="🔴"
        llama_class="llama-stopped"
    fi

    if [[ "$webui_state" == "active" ]]; then
        webui_icon="🟢"
        webui_class="webui-running"
    else
        webui_icon="🔴"
        webui_class="webui-stopped"
    fi

    local llama_uptime webui_uptime
    llama_uptime=$(get_uptime "$LLAMA_SVC")
    webui_uptime=$(get_uptime "$WEBUI_SVC")

    # Build class string for CSS targeting
    local class="llm ${llama_class} ${webui_class}"

    # Build tooltip (escape newlines for valid JSON)
    local tooltip="llama-server: ${llama_state} (${llama_uptime}) — port 8000\\nopen-webui: ${webui_state} (${webui_uptime}) — port 3000"

    local text="🦙 ${llama_icon} 󰈈${webui_icon}"

    printf '{"text":"%s","class":"%s","tooltip":"%s"}' \
        "$text" "$class" "$tooltip"
}

cmd_menu() {
    local llama_state webui_state
    llama_state=$(get_status "$LLAMA_SVC")
    webui_state=$(get_status "$WEBUI_SVC")

    local options=()

    if [[ "$llama_state" == "active" ]]; then
        options+=("🦙 Stop llama-server")
    else
        options+=("🦙 Start llama-server")
    fi

    if [[ "$webui_state" == "active" ]]; then
        options+=("󰈈 Stop webui")
    else
        options+=("󰈈 Start webui")
    fi

    options+=("---")

    if [[ "$llama_state" == "active" || "$webui_state" == "active" ]]; then
        options+=("⏹ Stop both")
    fi

    if [[ "$llama_state" == "inactive" && "$webui_state" == "inactive" ]]; then
        options+=("▶ Start both")
    fi

    local choice
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -select 0 $ROFI_THEME -p "LLM" -i -width 30)

    if [[ -z "$choice" ]]; then
        exit 0
    fi

    case "$choice" in
        "🦙 Start llama-server"|"🦙 Stop llama-server")
            if [[ "$llama_state" == "active" ]]; then
                systemctl --user stop "$LLAMA_SVC"
            else
                systemctl --user start "$LLAMA_SVC"
            fi
            ;;
        "󰈈 Start webui"|"󰈈 Stop webui")
            if [[ "$webui_state" == "active" ]]; then
                systemctl --user stop "$WEBUI_SVC"
            else
                systemctl --user start "$WEBUI_SVC"
            fi
            ;;
        "⏹ Stop both")
            systemctl --user stop "$LLAMA_SVC" 2>/dev/null || true
            systemctl --user stop "$WEBUI_SVC" 2>/dev/null || true
            ;;
        "▶ Start both")
            systemctl --user start "$LLAMA_SVC"
            systemctl --user start "$WEBUI_SVC"
            ;;
    esac
}

cmd_toggle_llama() {
    local state
    state=$(get_status "$LLAMA_SVC")
    if [[ "$state" == "active" ]]; then
        systemctl --user stop "$LLAMA_SVC"
    else
        systemctl --user start "$LLAMA_SVC"
    fi
}

cmd_toggle_webui() {
    local state
    state=$(get_status "$WEBUI_SVC")
    if [[ "$state" == "active" ]]; then
        systemctl --user stop "$WEBUI_SVC"
    else
        systemctl --user start "$WEBUI_SVC"
    fi
}

cmd_toggle_all() {
    local llama_state webui_state
    llama_state=$(get_status "$LLAMA_SVC")
    webui_state=$(get_status "$WEBUI_SVC")

    if [[ "$llama_state" == "active" || "$webui_state" == "active" ]]; then
        systemctl --user stop "$LLAMA_SVC" 2>/dev/null || true
        systemctl --user stop "$WEBUI_SVC" 2>/dev/null || true
    else
        systemctl --user start "$LLAMA_SVC"
        systemctl --user start "$WEBUI_SVC"
    fi
}

case "${1:-}" in
    status)     cmd_status ;;
    menu)       cmd_menu ;;
    toggle-llama)  cmd_toggle_llama ;;
    toggle-webui)  cmd_toggle_webui ;;
    toggle-all)    cmd_toggle_all ;;
    *)
        echo "Usage: $0 {status|menu|toggle-llama|toggle-webui|toggle-all}"
        exit 1
        ;;
esac
