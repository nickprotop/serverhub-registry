#!/bin/bash
# ServerHub Widget - System Load Monitor
# Shows system load averages and CPU count

set -euo pipefail

# Get CPU count
cpu_count=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "?")

# Get load averages
if [ -f /proc/loadavg ]; then
    read -r load1 load5 load15 rest < /proc/loadavg
else
    # macOS fallback
    load_output=$(uptime | awk -F'load averages: ' '{print $2}')
    load1=$(echo "$load_output" | awk '{print $1}' | tr -d ',')
    load5=$(echo "$load_output" | awk '{print $2}' | tr -d ',')
    load15=$(echo "$load_output" | awk '{print $3}' | tr -d ',')
fi

# Calculate percentages
load1_pct=$(awk "BEGIN {printf \"%.0f\", ($load1 / $cpu_count) * 100}")
load5_pct=$(awk "BEGIN {printf \"%.0f\", ($load5 / $cpu_count) * 100}")
load15_pct=$(awk "BEGIN {printf \"%.0f\", ($load15 / $cpu_count) * 100}")

# Determine color based on load
if [ "$load1_pct" -lt 70 ]; then
    color="green"
elif [ "$load1_pct" -lt 90 ]; then
    color="yellow"
else
    color="red"
fi

# Compact view
cat << EOF
---
compact:
  text: "Load: $load1 $load5 $load15 ($cpu_count CPUs)"
  color: $color
EOF

# Expanded view (shown when user presses Enter)
cat << EOF
expanded:
  text: |
    System Load Averages
    ━━━━━━━━━━━━━━━━━━━━

    1 min:  $load1 (${load1_pct}%)
    5 min:  $load5 (${load5_pct}%)
    15 min: $load15 (${load15_pct}%)

    CPU Cores: $cpu_count

    Status: $([ $load1_pct -lt 70 ] && echo "✓ Normal" || echo "⚠ High Load")
EOF
