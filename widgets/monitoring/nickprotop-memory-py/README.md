# Memory Monitor (Python)

Advanced memory monitoring widget for ServerHub, written in Python. This widget demonstrates the language-agnostic widget protocol by implementing a fully-featured memory monitor in Python rather than bash.

## Features

- **RAM Usage Monitoring**: Track total, used, available, buffers, and cached memory
- **Swap Monitoring**: Monitor swap usage with detailed partition information
- **Smart Fallback**: Uses psutil library if available, gracefully falls back to /proc parsing
- **Detailed Statistics**: Shows active/inactive memory, shared memory, dirty pages, slab allocations
- **Memory Pressure**: PSI (Pressure Stall Information) metrics for memory contention
- **Top Processes**: Lists top memory-consuming processes
- **Huge Pages Support**: Display huge pages configuration and usage
- **History Graphs**: Sparklines and graphs showing memory usage trends
- **Color-Coded Status**: Visual indicators for memory health (ok/warn/error)
- **Contextual Actions**: Quick actions to clear caches, drop swap, or kill processes

## Installation

### Via Marketplace (Recommended)

1. Open ServerHub and press `m` to open the marketplace browser
2. Navigate to `Monitoring` category
3. Select `Memory Monitor (Python)` and press `i` to install
4. Configure in your `config.yaml`

### Manual Installation

```bash
# Download the widget
curl -o ~/.config/serverhub/widgets/memory.py \
  https://raw.githubusercontent.com/nickprotop/serverhub-registry/main/widgets/monitoring/nickprotop-memory-py/v1.0.0/memory.py

# Make it executable
chmod +x ~/.config/serverhub/widgets/memory.py
```

## Configuration

Add to your `~/.config/serverhub/config.yaml`:

```yaml
widgets:
  memory-py:
    path: memory.py
    refresh: 5
    expanded_refresh: 2
    sha256: "8e9cbedecb559cac59b36a15eafdec4cb89b8b76df75ebe16bda0c3c8b0fbd5d"
```

### Configuration Options

- **refresh**: Update interval in seconds for dashboard view (default: 5)
- **expanded_refresh**: Update interval in seconds for expanded view (default: 2)
- **sha256**: Checksum to verify widget integrity

## Output Examples

### Compact View (Dashboard)

```
[✓] Memory: 8542MB / 15896MB ▁▂▃▅▆▇█
███████████████████████████████████░░░░░ 54%

Memory Breakdown:
Type         Usage
RAM Used     ████████████ 54%
Swap Used    ███░░░░░░░░░ 25%
Cache        2847MB
Available    5120MB

Available: 5120MB (32%)
```

### Expanded View

```
[✓] Memory: 8542MB / 15896MB (54%)
███████████████████████████████████░░░░░ 54%

Available: 5120MB

─────────────────────────────────────

Memory Usage History (last 60s):
60 ┤      ╭─╮
50 ┤    ╭─╯ ╰─╮
40 ┤  ╭─╯     ╰─╮
30 ┤╭─╯         ╰─╮

Swap Usage History:
30 ┤      ╭─╮
20 ┤    ╭─╯ ╰─╮
10 ┤  ╭─╯     ╰─╮
 0 ┤╭─╯         ╰─╮

─────────────────────────────────────

Memory Breakdown:
Type         Size        Percentage
Total RAM    15896MB     100%
Used         8542MB      ████████████ 54%
Available    5120MB      32%
Buffers      847MB       5%
Cache        2000MB      13%
Swap Total   8192MB      100%
Swap Used    2048MB      ███░░░░░░░░░ 25%
Swap Free    6144MB      75%

─────────────────────────────────────

Advanced Details:
Metric           Value
Active           4728MB
Inactive         2814MB
Shared           423MB
Dirty            12MB
Slab (kernel)    847MB

─────────────────────────────────────

Swap Partitions:
Device       Type       Size     Used     Priority
sda5         partition  8192MB   2048MB   -2

─────────────────────────────────────

Top Memory Processes:
Process          Memory    Percent  PID
chrome           2847MB    17.9%    1234
firefox          1423MB    8.9%     5678
code             1024MB    6.4%     9012
python3          512MB     3.2%     3456

─────────────────────────────────────

Memory Pressure:
Type         10s avg   60s avg
Some stall   0.05%     0.03%
Full stall   0.00%     0.00%
```

## Requirements

### Required

- **Python 3**: System must have Python 3 installed
- **Linux**: Widget uses /proc filesystem

### Optional

- **psutil**: Python library for enhanced performance
  ```bash
  # Ubuntu/Debian
  sudo apt install python3-psutil

  # Fedora/RHEL
  sudo dnf install python3-psutil

  # Arch Linux
  sudo pacman -S python-psutil

  # Via pip
  pip3 install psutil
  ```

If psutil is not available, the widget automatically falls back to parsing /proc/meminfo directly with no loss of functionality.

## How It Works

### Language-Agnostic Protocol

This widget demonstrates ServerHub's language-agnostic widget protocol. While most widgets are written in bash, this implementation uses Python to show that widgets can be written in any language that can:

1. Output text to stdout
2. Parse command-line arguments (`--extended` flag)
3. Use the widget protocol format

### Memory Calculation

The widget calculates memory usage following the same methodology as the `free` command:

- **Used Memory** = Total - Free - Buffers - Cached
- **Available Memory** = MemAvailable from /proc/meminfo (kernel calculation)
- **Swap Usage** = Swap Total - Swap Free

### Data Sources

1. **Primary**: psutil library (if available) - fast and efficient
2. **Fallback**: Direct parsing of /proc/meminfo, /proc/swaps, /proc/pressure/memory
3. **Processes**: `ps aux` command for top memory consumers
4. **Shared Memory**: `free -m` command output

### History Management

Memory and swap usage percentages are stored in `~/.cache/serverhub/`:
- `memory-usage.txt`: Last 30 samples (dashboard: 10 samples)
- `swap-usage.txt`: Last 30 samples (dashboard: 10 samples)

History files are updated on each widget refresh and used to generate sparklines and graphs.

## Available Actions

The widget provides contextual actions based on memory state:

- **Drop caches** (always available): Clear system page cache, dentries, and inodes
- **Clear memory history**: Reset history graphs
- **View memory map**: Show detailed /proc/meminfo
- **Show OOM killer history**: Display recent out-of-memory events
- **Clear swap** (when swap > 50%): Turn off and on swap to clear it
- **Kill process** (when memory > 90%): Terminate top memory-consuming process

## Performance

- **Dashboard refresh**: 5 seconds (configurable)
- **Expanded refresh**: 2 seconds (configurable)
- **CPU usage**: < 1% (negligible impact)
- **Execution time**: ~50ms with psutil, ~100ms without

## Troubleshooting

### Widget Not Loading

1. Check Python 3 is installed: `python3 --version`
2. Verify file is executable: `ls -l ~/.config/serverhub/widgets/memory.py`
3. Test manually: `python3 ~/.config/serverhub/widgets/memory.py`

### Missing Statistics

- **Pressure metrics**: Requires Linux kernel 4.20+ with PSI enabled
- **Huge pages**: Only shown if configured (`/proc/meminfo` has HugePages_Total > 0)
- **Swap**: Only shown if swap is configured (`/proc/swaps` has entries)

### Performance Issues

Install psutil for better performance:
```bash
sudo apt install python3-psutil
```

## Advantages Over Bash Implementation

- **Cleaner code**: Python's data structures and error handling
- **Better parsing**: Native string manipulation and file I/O
- **Rich libraries**: Can use psutil for enhanced functionality
- **Maintainability**: Easier to extend and modify
- **Type safety**: Python's dynamic typing catches common errors

## License

MIT License - see LICENSE file for details

## Author

- **Nick Protopapas** (nickprotop)
- GitHub: https://github.com/nickprotop
- Widget Repository: https://github.com/nickprotop/serverhub-registry

## Contributing

Contributions welcome! Please open issues or pull requests in the serverhub-registry repository.

## Version History

### v1.0.0 (2025-01-30)
- Initial release
- Python implementation with psutil support
- Fallback to /proc parsing
- Comprehensive memory statistics
- Memory pressure information
- Top process tracking
- Huge pages support
- History graphs and sparklines
