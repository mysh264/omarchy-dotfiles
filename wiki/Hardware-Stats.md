# Hardware Stats Widget

**Repo:** `omarchy/bar/scripts/hw-stats`  
**Live:** `~/.config/omarchy/bar/scripts/hw-stats` (`install.sh` copies it and makes it executable)  
**Wired in:** `shell.json` as a `"type": "command"` module, see [Status Bar](Status-Bar#custom-modules)

A small Python 3 script. The bar runs it every `interval` seconds (shipped: **2**) and shows what it prints: one line of Waybar-style JSON with `text` and `tooltip`.

In i3 terms this is an i3blocks block, or a `status_command` script: print a line, the bar shows it.

## What it shows

Bar text (real output):

```text
CPU 94° 1695MHz 11%  GPU 69° 405MHz 52%  load 3.13  RAM 13.3/31.0G  SWAP 1.9/62.0G
```

| Piece | Source |
|-------|--------|
| CPU °C | `/sys/class/hwmon/hwmon*/temp1_input` of the sensor named `coretemp` (Intel package temperature) |
| CPU MHz | Average of every core's `cpufreq/scaling_cur_freq` |
| CPU % | Change in `/proc/stat` since the last run. The previous sample is kept in `~/.cache/omarchy/hw-stats-cpu`. |
| GPU | NVIDIA through `nvidia-smi`; **GPU sleep** if the card is runtime-suspended; **GPU —** if there is no NVIDIA card or `nvidia-smi` fails |
| load | 1-minute value from `/proc/loadavg` |
| RAM / SWAP | `/proc/meminfo` (RAM used = `MemTotal − MemAvailable`) |

The tooltip adds peak core MHz, all three load averages and RAM/swap in GiB with two decimals.

**Click:** `omarchy-launch-or-focus-tui btop`, from `onClick` in `shell.json`. It focuses btop if it is already open, otherwise opens it in your default terminal.

## The `shell.json` entry

```json
{
  "id": "hw-stats",
  "type": "command",
  "exec": "~/.config/omarchy/bar/scripts/hw-stats",
  "interval": 2,
  "onClick": "omarchy-launch-or-focus-tui btop"
}
```

Change `interval` or `onClick` here without touching the Python. Command modules also accept `onRightClick` and `onMiddleClick`.

## How to edit the script

1. Open `~/.config/omarchy/bar/scripts/hw-stats` (or the repo copy, then copy it over).  
2. Keep stdout to **one** JSON object: `{"text": "…", "tooltip": "…"}`. Anything else printed breaks the parse.  
3. Keep it executable: `chmod +x ~/.config/omarchy/bar/scripts/hw-stats`  
4. The bar starts the script fresh every `interval`, so the next run already uses your edit. No restart needed.

### Common tweaks

| Goal | Where |
|------|--------|
| Shorter bar text | `text = "  ".join([cpu, gpu_text, load_text, ram_text, swap_text])` in `main()`: drop items from the list |
| Hide GPU on a machine without one | In `main()`, leave `gpu_text` out of that list when `gpu` is `None` |
| °, MHz, % format | The `deg`, `mhz`, `pct` and `fmt_pair` helpers |
| AMD CPU temperature | `cpu_package_c()` only looks for `coretemp`. AMD CPUs report as `k10temp`; add that name to the check. |
| AMD / Intel GPU | `nvidia()` only knows NVIDIA (vendor `0x10de`). Add a new probe and call it from `main()`. |
| Different click action | `onClick` in `shell.json` |

### NVIDIA notes

- Query: `nvidia-smi --query-gpu=temperature.gpu,clocks.gr,utilization.gpu --format=csv,noheader,nounits`  
- Before running it, the script reads `power/runtime_status` of the NVIDIA card. If it is `suspended`, it prints **GPU sleep** and does not call `nvidia-smi`. Why: on a hybrid laptop, calling `nvidia-smi` every 2 seconds would keep waking the dGPU and drain the battery.  
- `nvidia-smi` gets a 2-second timeout. Any failure shows **GPU —**.

## Check it worked

```bash
~/.config/omarchy/bar/scripts/hw-stats | jq .     # valid JSON with "text" and "tooltip"
~/.config/omarchy/bar/scripts/hw-stats | jq -r .text
```

Run it twice: on the very first run CPU % shows `—`, because there is no earlier sample to compare with yet.

If the module on the bar seems stuck after an edit:

```bash
omarchy restart shell
```

## Pitfalls

- **CPU shows `—°`.** No `coretemp` sensor (AMD, or a VM). See the tweak above. `ls /sys/class/hwmon/*/name | xargs cat` lists your sensor names.
- **Module disappears or shows raw text.** The script printed an error or more than one line. Run it by hand to see.
- **`exec` runs through `bash -lc`**, so `~`, pipes and arguments work. A relative path does not: there is no useful working directory.

## Dependencies

- Python 3 (part of the Arch/Omarchy base)  
- Optional: `nvidia-smi` (NVIDIA driver utilities) for GPU stats  
- Optional: `btop` for the click action  
