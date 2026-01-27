# NVIDIA GPU Monitor

Monitor NVIDIA GPU temperature, utilization, memory usage, and power consumption. Auto-detects NVIDIA GPUs via `nvidia-smi`.

## Features

- **Temperature Monitoring** - GPU temperature with color-coded status
- **GPU Utilization** - Current GPU usage percentage
- **VRAM Usage** - Memory used vs total available
- **Power Consumption** - Current power draw and limit
- **Extended Mode** - Clock speeds, driver version, GPU processes
- **Auto-Detection** - Works automatically if NVIDIA drivers are installed

## Installation

### Via Marketplace

```bash
serverhub marketplace install nickprotop/nvidia-gpu
```

### Manual Installation

```bash
# Download the widget
curl -o ~/.config/serverhub/widgets/nvidia-gpu.sh \
  https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/nickprotop-nvidia-gpu/v1.0.0/nvidia-gpu.sh

chmod +x ~/.config/serverhub/widgets/nvidia-gpu.sh

# Add to config.yaml
cat >> ~/.config/serverhub/config.yaml << 'EOF'

widgets:
  nvidia-gpu:
    path: nvidia-gpu.sh
    refresh: 3
    sha256: "ab29ac240badb075001133a481926a37086ba0b0936fc359ff8b9dcd27392ac4"
EOF
```

## Configuration

```yaml
widgets:
  nvidia-gpu:
    path: nvidia-gpu.sh
    refresh: 3           # Update every 3 seconds
    expanded_refresh: 2  # Faster refresh when expanded
    sha256: "ab29ac240badb075001133a481926a37086ba0b0936fc359ff8b9dcd27392ac4"
```

## Output

**Compact View:**
```
NVIDIA GeForce RTX 3080
✓ Temperature: 52°C
▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░ 52%
GPU Utilization: 34%
VRAM: 4521/10240 MiB (44%)
```

**Expanded View:**
```
GPU Details:
Power: 145.2W / 320.0W limit
Fan Speed: 45%
Performance State: P2
Driver: 535.154.05
CUDA: 12.2

Clock Speeds:
Graphics: 1875 MHz (max 2100)
Memory: 9501 MHz (max 9501)

GPU Processes:
python3 (PID 12345): 2048 MiB
chrome (PID 6789): 512 MiB
```

## Requirements

- **Required:** `nvidia-smi` (included with NVIDIA drivers)
- **Required:** NVIDIA GPU with proprietary drivers installed

## Temperature Thresholds

- **Green (ok):** < 70°C - Normal operation
- **Yellow (warn):** 70-85°C - Under load, monitor closely
- **Red (error):** > 85°C - Approaching thermal limits

## Performance States

NVIDIA GPUs use performance states (P-states) to manage power:

| State | Description |
|-------|-------------|
| P0 | Maximum performance |
| P1 | High performance |
| P2 | Balanced |
| P5-P8 | Low power / idle |
| P12 | Minimum power |

## Supported GPUs

Any NVIDIA GPU supported by the proprietary driver:
- GeForce (GTX, RTX series)
- Quadro
- Tesla
- Data Center GPUs (A100, H100, etc.)

## Troubleshooting

**"nvidia-smi not found"**
- Install NVIDIA proprietary drivers
- Ubuntu/Debian: `apt install nvidia-driver-535`
- Or use the graphics-drivers PPA

**"Cannot access NVIDIA GPU"**
- Check if the driver is loaded: `lsmod | grep nvidia`
- Verify GPU is detected: `lspci | grep -i nvidia`
- Check dmesg for errors: `dmesg | grep -i nvidia`

**Some values show [N/A]**
- Some metrics are not available on all GPUs
- Older GPUs may not report power or fan speed
- This is normal and handled gracefully

## License

MIT

## Author

Created by nickprotop for the ServerHub marketplace.
