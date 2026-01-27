# Pi Sensors

Monitor Raspberry Pi temperature, throttling status, and voltages. Includes fallback support for non-Pi Linux systems using thermal zones.

## Features

- **Temperature Monitoring** - CPU/GPU temperature via `vcgencmd`
- **Throttling Detection** - Decode and display current throttling status
- **Voltage Readings** - Core and SDRAM voltages (extended mode)
- **Clock Speeds** - ARM, core, and peripheral clocks (extended mode)
- **Throttling History** - Track issues that occurred since boot
- **Fallback Mode** - Works on non-Pi systems using `/sys/class/thermal/`
- **Color Coding** - Green (< 70°C), Yellow (70-80°C), Red (> 80°C)

## Installation

### Via Marketplace

```bash
serverhub marketplace install nickprotop/pi-sensors
```

### Manual Installation

```bash
# Download the widget
curl -o ~/.config/serverhub/widgets/pi-sensors.sh \
  https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/nickprotop-pi-sensors/v1.0.0/pi-sensors.sh

chmod +x ~/.config/serverhub/widgets/pi-sensors.sh

# Add to config.yaml
cat >> ~/.config/serverhub/config.yaml << 'EOF'

widgets:
  pi-sensors:
    path: pi-sensors.sh
    refresh: 5
    sha256: "2bd58dc0926a0de707d50f609047126815c370ca30d8d4170dd68aebcd8f2c43"
EOF
```

## Configuration

```yaml
widgets:
  pi-sensors:
    path: pi-sensors.sh
    refresh: 5           # Update every 5 seconds
    expanded_refresh: 3  # Faster refresh when expanded
    sha256: "2bd58dc0926a0de707d50f609047126815c370ca30d8d4170dd68aebcd8f2c43"
```

## Output

**Compact View (Raspberry Pi):**
```
Temperature: 45.0°C
▓▓▓▓▓▓▓▓░░░░░░░░░░░░ 53%
Throttling: None
```

**Compact View (Non-Pi Fallback):**
```
Non-Pi system - using thermal zones

x86_pkg_temp: 52.0°C
▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░ 61%
```

**Expanded View (Raspberry Pi):**
```
Raspberry Pi Details:
Model: Raspberry Pi 4 Model B Rev 1.4

Voltages:
core: 1.35V
sdram_c: 1.1V
sdram_i: 1.1V
sdram_p: 1.1V

Clock Speeds:
arm: 1500 MHz
core: 500 MHz
h264: 0 MHz
isp: 500 MHz
v3d: 500 MHz

Throttling History (since boot):
✓ No issues since boot

GPU Memory: 256MB
```

## Throttling Flags

The widget decodes Raspberry Pi throttling flags to show both current issues and historical issues since boot:

| Issue | Description |
|-------|-------------|
| Under-voltage | Power supply voltage dropped below 4.63V |
| Freq capped | CPU frequency has been limited |
| Throttled | CPU is being actively throttled |
| Soft temp limit | Soft temperature limit reached (starts at 60°C) |

## Requirements

### Raspberry Pi
- **Required:** `awk`, `bc`
- **Required:** `vcgencmd` (included in Raspberry Pi OS)

### Other Linux Systems
- **Required:** `awk`, `bc`
- **Required:** Thermal zone support (`/sys/class/thermal/`)

## Temperature Thresholds

- **Green (ok):** < 70°C - Normal operation
- **Yellow (warn):** 70-80°C - Getting warm, check cooling
- **Red (error):** > 80°C - Overheating, throttling likely

## Raspberry Pi Thermal Guidelines

| Temperature | Status |
|-------------|--------|
| < 60°C | Excellent |
| 60-70°C | Normal under load |
| 70-80°C | Warm - ensure adequate cooling |
| 80-85°C | Hot - throttling begins |
| > 85°C | Critical - hard throttle limit |

## License

MIT

## Author

Created by nickprotop for the ServerHub marketplace.
