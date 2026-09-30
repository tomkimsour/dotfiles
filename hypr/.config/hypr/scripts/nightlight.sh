#!/usr/bin/env bash
# Always-on night light wrapper around wlsunset, applied to the laptop panel only.
# Usage: nightlight.sh start          launch with the stored temperature
#        nightlight.sh set <kelvin>   store a new temperature and restart (6500 = off)
set -euo pipefail

DEFAULT_TEMP=2700
NEUTRAL_TEMP=6500
OUTPUT=eDP-1
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nightlight"

stored_temp() {
    local t
    t=$(cat "$STATE" 2>/dev/null || true)
    [[ "$t" =~ ^[0-9]+$ ]] && echo "$t" || echo "$DEFAULT_TEMP"
}

start() {
    local t
    t=$(stored_temp)
    [ "$t" -ge "$NEUTRAL_TEMP" ] && return 0
    exec wlsunset -t "$t" -T "$((t + 1))" -S 06:00 -s 18:00 -o "$OUTPUT"
}

stop() {
    pkill -x wlsunset || true
    for _ in $(seq 20); do
        pgrep -x wlsunset > /dev/null || return 0
        sleep 0.05
    done
}

case "${1:-}" in
    start)
        start
        ;;
    set)
        [[ "${2:-}" =~ ^[0-9]+$ ]] || { echo "usage: $0 set <kelvin>" >&2; exit 2; }
        mkdir -p "$(dirname "$STATE")"
        echo "$2" > "$STATE"
        stop
        start
        ;;
    *)
        echo "usage: $0 {start|set <kelvin>}" >&2
        exit 2
        ;;
esac
