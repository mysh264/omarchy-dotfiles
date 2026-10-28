# Screenshots

## Binds

| Shortcut | What runs |
|----------|-----------|
| Super+S | `omarchy-capture-screenshot fullscreen` |
| Super+Shift+S | `~/.config/hypr/scripts/screenshot-focused` |

Defined in [Keybindings](Keybindings). Super+S / Super+Shift+S are unbound from Omarchy defaults first (scratchpad / Maps webapp).

## Focused-window script

**Repo:** `hypr/scripts/screenshot-focused`  
**Live:** `~/.config/hypr/scripts/screenshot-focused` (must be executable)

Behavior:

1. Reads focused window geometry via `hyprctl activewindow -j` + `jq`  
2. Captures with `grim -g "x,y WxH"`  
3. Saves under Pictures (see below)  
4. Copies PNG to clipboard (`wl-copy`)  
5. Notifies via `omarchy-notification-send` or `notify-send`  

### Output directory

```bash
# Priority:
OMARCHY_SCREENSHOT_DIR  →  XDG_PICTURES_DIR  →  ~/Pictures
```

Filename: `screenshot-YYYY-MM-DD_HH-MM-SS.png`.

### Edit ideas

| Goal | Change |
|------|--------|
| Different directory | export `OMARCHY_SCREENSHOT_DIR` or edit the script |
| Region select instead | call `slurp` + `grim` (write a new script; rebind Shift+S) |
| No notification | remove the notify block |
| Include cursor | add grim flags if supported on your version |

### Dependencies

```bash
sudo pacman -S --needed grim wl-clipboard jq
# optional: slurp for interactive regions
```

### Debug

```bash
hyprctl activewindow -j | jq .
~/.config/hypr/scripts/screenshot-focused
echo $?
```

Exit 1 usually means no valid focused window geometry (empty desktop / special cases).

## Fullscreen path

Uses Omarchy’s helper — follow Omarchy docs for its save location and options. This rice only rebinds the key to that command.
