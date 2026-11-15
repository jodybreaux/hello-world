#!/bin/bash
# Wi-Fi diagnostic for macOS - read-only, changes nothing.
# Run in Terminal:  bash wifi-diag-mac.sh
OUT="$HOME/Desktop/wifi-report.txt"
{
echo "=== 1. Current Wi-Fi link + nearby networks (signal, noise, channel, rate) ==="
system_profiler SPAirPortDataType

GW=$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')
echo; echo "=== 2. Ping router ($GW) - tests Wi-Fi link quality ==="
ping -c 30 "$GW"

echo; echo "=== 3. Ping internet (1.1.1.1) - tests ISP ==="
ping -c 30 1.1.1.1

echo; echo "=== 4. DNS lookup speed ==="
for d in google.com netflix.com apple.com; do
  printf "%-15s " "$d"; dig "$d" | awk '/Query time/{print $4" ms"}'
done

echo; echo "=== 5. Route to internet ==="
traceroute -n -m 10 1.1.1.1 2>&1

echo; echo "=== 6. Speed / responsiveness test (macOS 12+) ==="
networkQuality 2>&1 || echo "networkQuality not available on this macOS version"
} 2>&1 | tee "$OUT"
echo; echo "Report saved to $OUT - paste its contents back to Claude."
