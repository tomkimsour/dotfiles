#!/usr/bin/env bash
# Self-contained weather for waybar via wttr.in (no jq). Set WTTR_LOCATION to override.
loc="${WTTR_LOCATION:-}"
raw=$(curl -fsS --max-time 10 "https://wttr.in/${loc}?format=%C|%t|%f|%l" 2>/dev/null)
if [ -z "$raw" ] || printf '%s' "$raw" | grep -qiE 'unknown|sorry|html'; then
  printf '{"text":"","class":"unavailable"}\n'; exit 0
fi
cond=${raw%%|*}; r=${raw#*|}; temp=${r%%|*}; r=${r#*|}; feels=${r%%|*}; where=${r##*|}
temp=$(printf '%s' "$temp" | tr -d ' +'); feels=$(printf '%s' "$feels" | tr -d ' +')
c=$(printf '%s' "$cond" | tr 'A-Z' 'a-z')
case "$c" in
  *thunder*)                            i="󰖓" ;;
  *snow*|*sleet*|*blizzard*|*ice*)      i="󰖘" ;;
  *partly*)                             i="🌤️" ;;
  *heavy*rain*|*torrential*|*downpour*) i="󰖖" ;;
  *rain*|*drizzle*|*shower*)            i="󰖗" ;;
  *fog*|*mist*|*haze*)                  i="󰖑" ;;
  *overcast*|*cloud*)                   i="☁️" ;;
  *sunny*|*clear*)                      i="☀️" ;;
  *)                                    i="󰖐" ;;
esac
printf '{"text":"%s %s","tooltip":"%s \u2014 %s, feels %s","class":"weather"}\n' "$i" "$temp" "$where" "$cond" "$feels"
