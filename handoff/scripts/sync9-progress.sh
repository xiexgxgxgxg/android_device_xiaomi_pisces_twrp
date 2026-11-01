#!/usr/bin/env bash
F=/home/xie/twrp-pisces/logs/.sync9-progress
now=$(du -sb /home/xie/twrp-pisces/source-9.0 2>/dev/null | cut -f1)
ts=$(date '+%H:%M:%S')
if [ -f "$F" ]; then read -r prev pts < "$F" || { prev=$now; pts=$ts; }; else prev=$now; pts=$ts; fi
delta=$((now - prev))
awk -v ts="$ts" -v n="$now" -v d="$delta" -v p="$pts" 'BEGIN {
  printf "%s  source9=%.2f GB  delta=+%.0f MB  (prev %s)\n", ts, n/1073741824, d/1048576, p
}'
if pgrep -f "repo/main.py.*sync" >/dev/null; then echo "sync: running"; else echo "sync: NOT running"; fi
echo "$now $ts" > "$F"
