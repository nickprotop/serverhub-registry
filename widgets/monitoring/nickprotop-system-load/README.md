# System Load Monitor

Monitor system load averages with color-coded status indicators.

## Features

- **Load Averages** - Shows 1, 5, and 15 minute load averages
- **CPU Count** - Displays number of CPU cores
- **Color Coding** - Green (< 70%), Yellow (70-90%), Red (> 90%)
- **Load Percentage** - Shows load relative to CPU count
- **Cross-Platform** - Works on Linux and macOS

## Installation

### Via Marketplace

```bash
serverhub marketplace install nickprotop/system-load
```

### Manual Installation

```bash
# Download the widget
curl -o ~/.config/serverhub/widgets/system-load.sh \
  https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/nickprotop-system-load/v1.0.0/system-load.sh

chmod +x ~/.config/serverhub/widgets/system-load.sh

# Add to config.yaml
cat >> ~/.config/serverhub/config.yaml << 'EOF'

widgets:
  system-load:
    path: system-load.sh
    refresh: 5
    sha256: "c6a4f39b6720f235d26290d5d3e611569232e9b0b3070f0ec176a70a6473ffd3"
EOF
```

## Configuration

```yaml
widgets:
  system-load:
    path: system-load.sh
    refresh: 5        # Update every 5 seconds
    sha256: "c6a4f39b6720f235d26290d5d3e611569232e9b0b3070f0ec176a70a6473ffd3"
```

## Output

**Compact View:**
```
Load: 0.52 0.48 0.51 (8 CPUs)
```

**Expanded View:**
```
System Load Averages
━━━━━━━━━━━━━━━━━━━━

1 min:  0.52 (7%)
5 min:  0.48 (6%)
15 min: 0.51 (6%)

CPU Cores: 8

Status: ✓ Normal
```

## Requirements

- **Required:** `awk` (standard on all systems)
- **Optional:** `nproc` (for CPU count on Linux)

## How It Works

1. Reads load averages from `/proc/loadavg` (Linux) or `uptime` (macOS)
2. Gets CPU count using `nproc` or `sysctl`
3. Calculates load percentage relative to CPU count
4. Applies color coding based on thresholds

## Color Thresholds

- **Green:** < 70% load
- **Yellow:** 70-90% load
- **Red:** > 90% load

## License

MIT

## Author

Created by nickprotop for the ServerHub marketplace.
