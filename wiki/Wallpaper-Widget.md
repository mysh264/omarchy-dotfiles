# Wallpaper Widget

**QML:** `omarchy/bar/modules/wallpaper.qml` → `~/.config/omarchy/bar/modules/wallpaper.qml`  
**Wired in:** `shell.json` as `{ "id": "wallpaper", "type": "qml" }`

Controls Omarchy’s `wallpaper-slideshow` from the bar: previous / pause-play / next, plus scroll wheel.

## Interactions

| Control | Action |
|---------|--------|
| 󰒮 button | `wallpaper-slideshow --prev` |
| Pause / Play | `wallpaper-slideshow --toggle` |
| 󰒭 button | `wallpaper-slideshow --next` |
| Scroll up / down | prev / next |
| Hover | Tooltip with status + current name |

Status polled every **2s** via `wallpaper-slideshow --status` (JSON: `running`, `name`, `tooltip`).

## How to edit

1. Edit `~/.config/omarchy/bar/modules/wallpaper.qml`  
2. Shell rescans QML modules on save; if not: `omarchy restart shell`  

### Ideas

| Goal | Change |
|------|--------|
| Different icons | `iconText` on each `WallpaperButton` (Nerd Font glyphs) |
| Poll faster/slower | `statusTimer.interval` |
| Different backend | Replace `wallpaper-slideshow` in `runCmd` / `statusProc.command` |
| Hide widget | Remove the `wallpaper` entry from `shell.json` layout |

## QML contract (custom modules)

Custom modules should be an `Item` with `implicitWidth` / `implicitHeight`. Injected props:

- `bar` — theme colors, `bar.run(cmd)`, tooltips, …  
- `settings` — optional module settings from JSON  
- `moduleName` — id string  

See also the bar plugin README under `omarchy/plugins/mahmoud.bar/README.md` in the repo (module catalogue + examples).

## Theme / wallpaper without the widget

```bash
omarchy theme bg next
omarchy theme list
omarchy theme set "Catppuccin"
```
