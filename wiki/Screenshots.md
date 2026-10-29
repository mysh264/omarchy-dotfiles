# Screenshots

Two keys: a fullscreen shot through Omarchy's own tool, and a focused-window shot through a small script in this repo. In i3 you probably bound `maim` or `scrot`; on Wayland the tools are `grim` (capture) and `slurp` (pick a region).

## Binds

| Shortcut | What runs |
|----------|-----------|
| Super+S | `omarchy-capture-screenshot fullscreen` |
| Super+Shift+S | `~/.config/hypr/scripts/screenshot-focused` |

Defined in [Keybindings](Keybindings). Super+S / Super+Shift+S are unbound from Omarchy defaults first (they were "Toggle scratchpad" and the Google Maps web app). Omarchy's **Print** key (screenshot picker) is untouched and still works.

```lua
o.bind("SUPER + S", "Screenshot fullscreen", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + S", "Screenshot focused window", (os.getenv("HOME") or "") .. "/.config/hypr/scripts/screenshot-focused")
```

## Focused-window script

**Repo:** `hypr/scripts/screenshot-focused`  
**Live:** `~/.config/hypr/scripts/screenshot-focused` (must be executable)

Behavior:

1. Reads `~/.config/user-dirs.dirs` (for `XDG_PICTURES_DIR`) and the focused window geometry via `hyprctl activewindow -j` + `jq`  
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
| Include cursor | add `-c` to the `grim` call |

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

Super+S runs Omarchy's `omarchy-capture-screenshot fullscreen` (also reachable as `omarchy screenshot`). It saves a PNG, copies it to the clipboard and notifies you, using the same folder as the script above (`OMARCHY_SCREENSHOT_DIR` → `XDG_PICTURES_DIR` → `~/Pictures`). Other modes it takes: `smart`, `region`, `windows`, `fullscreen`. This repo only binds the key.
