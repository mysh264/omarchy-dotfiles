# Hardware Stats Widget

**Script:** `omarchy/bar/scripts/hw-stats` → `~/.config/omarchy/bar/scripts/hw-stats`  
**Wired in:** `shell.json` as a `type: "command"` module  

Python 3 script that prints Waybar-style JSON for the bar every `interval` seconds (shipped: **2**).

## What it shows

Bar text (example):

```text
CPU 64° 3200MHz 22%  GPU 55° 1800MHz 10%  load 0.42  RAM 12.1/31.2G  SWAP 0.0/8.0G
```

| Piece | Source |
|-------|--------|
| CPU °C | `/sys/class/hwmon` `coretemp` package temp |
| CPU MHz | average of `scaling_cur_freq` |
| CPU % | delta of `/proc/stat` (state file `~/.cache/omarchy/hw-stats-cpu`) |
| GPU | NVIDIA via `nvidia-smi`; or **GPU sleep** if runtime suspended; or **GPU —** if no NVIDIA |
| load | `/proc/loadavg` 1-minute |
| RAM / SWAP | `/proc/meminfo` |

Tooltip adds peak CPU MHz and more precise GiB lines.

**Click:** `omarchy-launch-or-focus-tui btop` (from `shell.json` `onClick`).

## shell.json entry

```json
{
  "id": "hw-stats",
  "type": "command",
  "exec": "~/.config/omarchy/bar/scripts/hw-stats",
  "interval": 2,
  "onClick": "omarchy-launch-or-focus-tui btop"
}
```

Change `interval` or `onClick` without touching Python.

## How to edit the script

1. Open `~/.config/omarchy/bar/scripts/hw-stats`  
2. Keep stdout a single JSON object: `{"text":"…","tooltip":"…"}`  
3. Ensure executable: `chmod +x …/hw-stats`  
4. Test: `~/.config/omarchy/bar/scripts/hw-stats | jq .`  
5. Restart shell if the module stalls: `omarchy restart shell`  

### Common tweaks

| Goal | Where |
|------|--------|
| Shorter bar string | Edit `text = "  ".join([...])` in `main()` — drop fields |
| °C label / spacing | `deg`, `mhz`, `pct`, `fmt_pair` helpers |
| AMD / Intel GPU | Extend `nvidia()` or add a new probe; call it from `main()` |
| Hide GPU when absent | Skip `gpu_text` when `gpu` is None |
| Different click action | `onClick` in `shell.json` |

### NVIDIA notes

- Uses `nvidia-smi --query-gpu=temperature.gpu,clocks.gr,utilization.gpu`  
- If the card is runtime-suspended (`power/runtime_status == suspended`), shows **GPU sleep** without waking it  
- Timeout 2s; failures → treat as no GPU data  

## Dependencies

- Python 3 (Arch/Omarchy base)  
- Optional: `nvidia-smi` for NVIDIA stats  
- Optional: `btop` for click action  
