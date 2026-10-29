# Status Bar (`shell.json`)

**Repo:** `omarchy/shell.json`  
**Live:** `~/.config/omarchy/shell.json`

Controls bar position, widget order, idle lock timings, and which bar engine plugin to use.

> Once customized, this file is **canonical** — Omarchy does not deep-merge it with defaults. Keep a backup before large edits.

## Top-level keys

| Key | Shipped | Meaning |
|-----|---------|---------|
| `bar.position` | `"bottom"` | `top` / `bottom` / `left` / `right` |
| `bar.transparent` | `false` | Double-click empty center also toggles |
| `bar.id` | `"mahmoud.bar"` | Cloned bar plugin ([Plugins](Plugins)) |
| `bar.centerAnchor` | `"omarchy.clock"` | Pins that module to true center |
| `bar.layout.left\|center\|right` | arrays | Widget entries in order |
| `idle.lock` | `300` | Seconds to lock |
| `idle.screensaver` | `150` | Seconds to screensaver |
| `plugins` | `[]` | Extra plugin ids (usually empty; folders under `plugins/` are scanned) |
| `version` | `1` | Schema version |

## Shipped layout (summary)

**Left:** menu · **mahmoud.workspaces** (all 12, named — see [Plugins](Plugins))  

**Center:** system-update  

**Right:** indicators · clock · weather · keyboard-layout · **hw-stats** · tailscale · agents · **wallpaper** · tray · bluetooth · **mahmoud.network** · audio · monitor · power  

## Editing layout

### By hand

Reorder or remove objects under `layout.left|center|right`. Example clock formats already in the file:

```json
{
  "id": "omarchy.clock",
  "format": "dddd HH:mm",
  "formatAlt": "d MMMM 'W'ww yyyy",
  "verticalFormat": "HH\n—\nmm"
}
```

### Via CLI

```bash
omarchy bar position bottom
omarchy bar transparent false
omarchy bar move omarchy.clock --section right
omarchy bar set …
omarchy plugin list
omarchy plugin enable <id>
omarchy plugin disable <id>
```

### Gestures (Quickshell bar)

- Drag empty bar space → move to another edge  
- Double-left-click empty center → toggle transparency  
- Drag widgets → reorder (writes `shell.json`)  

## Custom module types

### Command module (Waybar-style JSON or plain text)

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

Loads `~/.config/omarchy/bar/modules/<id>.qml` (or `source` path). See [Wallpaper Widget](Wallpaper-Widget).

## Indicators widget

`omarchy.indicators` can take:

```json
{
  "id": "omarchy.indicators",
  "items": ["Dnd", "Reminder", "NightLight"],
  "alwaysShow": false
}
```

Omit `items` to show all. Indicators live under the bar plugin’s `indicators/` folder.

## Apply changes

Usually hot-reloads on save. If not:

```bash
omarchy restart shell
```

## Hide / peek

Independent of `shell.json`: Super+M and the top-left hot corner latch-hide the bar and allow bottom-edge peek — implemented in [Keybindings](Keybindings).
