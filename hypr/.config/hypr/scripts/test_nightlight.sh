#!/usr/bin/env bash
# Tests for nightlight.sh. Run: ./test_nightlight.sh
set -u

SCRIPT="$(cd "$(dirname "$0")" && pwd)/nightlight.sh"
failures=0

setup() {
    TMP=$(mktemp -d)
    export XDG_STATE_HOME="$TMP/state"
    export CALLS="$TMP/calls"
    mkdir -p "$TMP/bin"
    printf '#!/bin/sh\necho "wlsunset $*" >> "$CALLS"\n' > "$TMP/bin/wlsunset"
    printf '#!/bin/sh\necho "pkill $*" >> "$CALLS"\n' > "$TMP/bin/pkill"
    printf '#!/bin/sh\nexit 1\n' > "$TMP/bin/pgrep"
    chmod +x "$TMP/bin/"*
    export PATH="$TMP/bin:$PATH"
    : > "$CALLS"
}

teardown() {
    rm -rf "$TMP"
}

check() {
    local name=$1 expected=$2 actual=$3
    if [ "$expected" = "$actual" ]; then
        echo "PASS $name"
    else
        echo "FAIL $name"
        echo "  expected: $expected"
        echo "  actual:   $actual"
        failures=$((failures + 1))
    fi
}

should_start_with_default_temperature_when_no_state() {
    setup
    "$SCRIPT" start
    check "${FUNCNAME[0]}" "wlsunset -t 2700 -T 2701 -S 06:00 -s 18:00 -o eDP-1" "$(rg '^wlsunset' "$CALLS")"
    teardown
}

should_start_with_stored_temperature() {
    setup
    mkdir -p "$XDG_STATE_HOME" && echo 3400 > "$XDG_STATE_HOME/nightlight"
    "$SCRIPT" start
    check "${FUNCNAME[0]}" "wlsunset -t 3400 -T 3401 -S 06:00 -s 18:00 -o eDP-1" "$(rg '^wlsunset' "$CALLS")"
    teardown
}

should_not_start_when_stored_temperature_is_neutral() {
    setup
    mkdir -p "$XDG_STATE_HOME" && echo 6500 > "$XDG_STATE_HOME/nightlight"
    "$SCRIPT" start
    check "${FUNCNAME[0]}" "" "$(rg '^wlsunset' "$CALLS")"
    teardown
}

should_store_temperature_when_set() {
    setup
    "$SCRIPT" set 3000
    check "${FUNCNAME[0]}" "3000" "$(cat "$XDG_STATE_HOME/nightlight")"
    teardown
}

should_restart_with_new_temperature_when_set() {
    setup
    "$SCRIPT" set 3000
    check "${FUNCNAME[0]}" "pkill -x wlsunset|wlsunset -t 3000 -T 3001 -S 06:00 -s 18:00 -o eDP-1" "$(paste -sd'|' "$CALLS")"
    teardown
}

should_only_stop_when_set_to_neutral() {
    setup
    "$SCRIPT" set 6500
    check "${FUNCNAME[0]}" "pkill -x wlsunset" "$(paste -sd'|' "$CALLS")"
    teardown
}

should_reject_non_numeric_temperature() {
    setup
    "$SCRIPT" set warm 2>/dev/null
    check "${FUNCNAME[0]}" "2" "$?"
    teardown
}

should_start_with_default_temperature_when_no_state
should_start_with_stored_temperature
should_not_start_when_stored_temperature_is_neutral
should_store_temperature_when_set
should_restart_with_new_temperature_when_set
should_only_stop_when_set_to_neutral
should_reject_non_numeric_temperature

[ "$failures" -eq 0 ]
