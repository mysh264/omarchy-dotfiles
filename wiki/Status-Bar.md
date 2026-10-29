# Status Bar (`shell.json`)

**Repo:** `omarchy/shell.json`  
**Live:** `~/.config/omarchy/shell.json`  
**Stock defaults (read-only):** `/usr/share/omarchy/config/omarchy/shell.json`

Omarchy's bar is not Waybar. It runs inside **omarchy-shell**, one long-running Quickshell process that also draws notifications, the menu, the lock screen and other overlays. `shell.json` decides which bar plugin is used, where it sits, which widgets it shows and in what order, and the idle timings.

> Once you have your own `shell.json`, it is **the whole truth**. Omarchy does not deep-merge it with the stock file. A widget you leave out is simply not on the bar.

## Coming from i3

| i3 | Omarchy |
|----|---------|
| `bar { position bottom }` in `~/.config/i3/config` | `"position": "bottom"` in `shell.json`, or `omarchy bar position bottom` |
| `status_command i3status` | Built in. The bar runs the widgets itself. |
| `order += "cpu_usage"` lines in `~/.config/i3status/config` | Entries in `bar.layout.left / center / right`, in order |
| An i3blocks script that prints text | A `"type": "command"` module (plain text or Waybar-style JSON) |
| `i3-msg reload` | Nothing. The shell hot-reloads `shell.json` on save. |
| `tray_output primary` | The `omarchy.tray` widget, placed wherever you like |

## Top-level keys

| Key | Shipped | Meaning |
|-----|---------|---------|
| `bar.id` | `"mahmoud.bar"` | Which bar plugin draws the bar. Leave it out (or use `omarchy.bar`) for the stock bar. This rice uses its clone, see [Plugins](Plugins). |
| `bar.position` | `"bottom"` | `top` / `bottom` / `left` / `right` (stock: `top`) |
| `bar.transparent` | `false` | `true` makes the bar fully clear (no fill). Keep `false`; the "glass" look comes from `background-alpha`, see [Themes and Fonts](Themes-and-Fonts). |
| `bar.centerAnchor` | `"omarchy.clock"` | Pins one **center** widget to the exact middle and places the rest around it. In this layout the clock sits in `right`, so the anchor finds nothing and the center list (just system-update) is centered as a group. |
| `bar.layout.left / center / right` | arrays | Widget entries, in order. Each entry carries its own settings inline. |
| `idle.screensaver` | `150` | Seconds of idle before the screensaver |
| `idle.lock` | `300` | Seconds of idle before locking (counted from when idle began, not from the screensaver) |
| `plugins` | `[]` | Entries for non-bar plugins (panels, overlays, services). Empty here. |
| `version` | `1` | Required. An unknown version makes the shell fall back to defaults. |

## Shipped layout

Exactly as in `shell.json`, in order:

| Section | Widgets |
|---------|---------|
| **Left** | `omarchy.menu` · `mahmoud.workspaces` (named workspaces, see [Plugins](Plugins)) |
| **Center** | `omarchy.system-update` |
| **Right** | `omarchy.indicators` · `omarchy.clock` · `omarchy.weather` · `omarchy.keyboard-layout` · `hw-stats` (command) · `omarchy.tailscale` · `omarchy.agents` · `wallpaper` (QML) · `omarchy.tray` · `omarchy.bluetooth` · `mahmoud.network` · `omarchy.audio` · `omarchy.monitor` · `omarchy.power` |

Compared with stock Omarchy: the bar is at the bottom; indicators, clock, weather and keyboard layout moved from center to right; `hw-stats`, `omarchy.tailscale` and `wallpaper` were added; and the stock workspaces and network widgets were swapped for the `mahmoud.*` clones.

To see every widget id you can use, and which are enabled:

```bash
omarchy plugin list
```

## Editing the layout

### By hand

Reorder, add or remove objects under `bar.layout.left|center|right`. Settings go straight on the entry. The clock entry shipped here:

```json
{
  "format": "dddd HH:mm",
  "formatAlt": "d MMMM 'W'ww yyyy",
  "id": "omarchy.clock",
  "verticalFormat": "HH\n—\nmm"
}
```

Save and the bar redraws. Keep the file valid JSON (`jq . ~/.config/omarchy/shell.json` tells you fast if it is not).

### With the `omarchy bar` command

These edit `~/.config/omarchy/shell.json` for you:

| Command | What it does |
|---------|--------------|
| `omarchy bar position bottom` | Move the bar to `top` / `bottom` / `left` / `right` |
| `omarchy bar transparent true\|false\|toggle` | Full transparency on/off |
| `omarchy bar move omarchy.clock --section center --index 0` | Move a widget within or between sections |
| `omarchy bar put omarchy.keyboard-layout --after omarchy.clock` | Put a widget on the bar; if it is already there, leave it where it is |
| `omarchy bar set omarchy.clock format HH:mm` | Set one option on a widget (`--json` for non-string values) |
| `omarchy bar use mahmoud.bar` | Choose which bar plugin is active (writes `bar.id`) |
| `omarchy bar reset` | Go back to the built-in `omarchy.bar` (removes `bar.id`) |
| `omarchy bar defaults` | Replace the whole bar section with Omarchy's stock layout |

Placement flags for `move`, `put` and `set`: `--section left|center|right`, `--index N`, `--before <id>`, `--after <id>`. `move` also takes `--from-section` / `--from-index`.

> `omarchy bar reset` and `omarchy bar defaults` throw away this rice's bar, and `omarchy refresh shell` resets the whole `shell.json` to stock. To get this rice back, copy the repo file again: `cp omarchy/shell.json ~/.config/omarchy/shell.json`.

### Adding and removing widgets

```bash
omarchy plugin enable omarchy.media --section center   # add it to the bar
omarchy plugin disable omarchy.tailscale               # take it off
```

`omarchy menu plugin enable` (and `disable`, `clone`, `remove`) does the same with a picker.

### On the bar itself

- Drag empty bar space (or click and hold) → move the bar to another edge  
- Double-left-click empty center space → toggle transparency  
- Drag widgets → reorder  

All three write `shell.json`, so they change your live file.

## Custom modules

Two kinds. Both go in `bar.layout` like any widget.

### Command module (like an i3blocks block)

Runs `exec` (through `bash -lc`) every `interval` seconds and shows what it prints. The output can be plain text or one line of Waybar-style JSON (`{"text": "…", "tooltip": "…", "class": "…"}`). `onClick`, `onRightClick` and `onMiddleClick` run commands on click.

```json
{
  "id": "hw-stats",
  "type": "command",
  "exec": "~/.config/omarchy/bar/scripts/hw-stats",
  "interval": 2,
  "onClick": "omarchy-launch-or-focus-tui btop"
}
```

See [Hardware Stats](Hardware-Stats).

### QML module

```json
{ "id": "wallpaper", "type": "qml" }
```

Loads `~/.config/omarchy/bar/modules/<id>.qml`, or the file named by a `source` key. See [Wallpaper Widget](Wallpaper-Widget).

## Indicators widget

`omarchy.indicators` shows small state icons (do not disturb, reminder, night light, screen recording, stay awake, dictation). It takes:

```json
{
  "id": "omarchy.indicators",
  "items": ["Dnd", "Reminder", "NightLight"],
  "alwaysShow": false
}
```

Leave `items` out to show all of them. `alwaysShow: true` keeps inactive ones visible instead of only on hover. This rice ships it with no options (all indicators). The QML for each one lives in the bar plugin's `indicators/` folder (`mahmoud.bar/indicators/`).

## Check it worked

```bash
jq . ~/.config/omarchy/shell.json >/dev/null && echo "valid JSON"
omarchy plugin list | grep mahmoud       # mahmoud.bar, .network, .workspaces should be "enabled"
hyprctl layers | grep omarchy-bar        # the bar is a layer surface, namespace omarchy-bar
```

If the bar does not pick up a change:

```bash
omarchy restart shell
```

## Hide and peek

This is separate from `shell.json`. **Super+M** and the **top-left hot corner** latch the bar hidden. Pushing the pointer to the bottom edge then "peeks" it over your windows. The logic is in `hypr/bindings.lua`. The peek needs the `setOverlay` IPC call that only the cloned `mahmoud.bar` has. See [Keybindings](Keybindings) and [Plugins](Plugins).

Omarchy's own `omarchy toggle bar` also exists. It only hides and shows, with no peek.

## Pitfalls

- **Wrong id = missing widget.** Ids are namespaced (`omarchy.clock`, not `Clock`). Check with `omarchy plugin list`.
- **Stock workspaces or network widget came back.** Something rewrote `shell.json` (`omarchy bar defaults`, `omarchy refresh shell`, …). Copy the repo file back.
- **The bar is fully see-through.** `transparent` got toggled, maybe by a double-click. `omarchy bar transparent false` fixes it.
