# Monitors and Input

## Monitors (`monitors.lua`)

**Repo:** `hypr/monitors.lua`  
**Live:** `~/.config/hypr/monitors.lua`

**Always edit this on each machine.** Blindly copying another laptop’s panel name/mode causes blank or wrong-scale displays.

### Discover hardware

```bash
hyprctl monitors all
```

### Shipped pattern

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Example laptop panel
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })

-- External examples (commented in file):
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })  -- 90°
```

| Field | Tips |
|-------|------|
| `output` | Exact name from `hyprctl monitors` (`eDP-1`, `DP-2`, `HDMI-A-1`, …) |
| `mode` | `WxH@Hz` or `preferred` |
| `position` | `0x0`, `1920x0`, or `auto` |
| `scale` | `1`, `1.25`, `1.5`, `2`, … |
| `transform` | `0` normal · `1` = 90° · `3` = 270° |

Reload: `hyprctl reload && hyprctl configerrors`.

---

## Input (`input.lua`)

**Repo:** `hypr/input.lua`  
**Live:** `~/.config/hypr/input.lua`

Keep **only personal overrides** here. Uncommented settings replace Omarchy defaults.

### Shipped keyboard

| Setting | Value | Meaning |
|---------|-------|---------|
| `kb_layout` | `us,ara` | US + Arabic |
| `kb_options` | `grp:win_space_toggle` | **Win+Space** cycles layouts |
| `kb_variant` | `intl` | International US variant |
| `resolve_binds_by_sym` | `0` | Prefer keycodes for binds |
| `follow_mouse` | `1` | Focus follows mouse (Omarchy-style) |

Commented alternatives in the file:

- `grp:alts_toggle` (Left Alt + Right Alt)  
- compose on Caps, both-shift Caps cancel  
- `repeat_rate` / `repeat_delay`  
- `numlock_by_default`  
- `sensitivity`, `accel_profile = "flat"`  
- Touchpad: natural scroll, clickfinger, scroll_factor, disable_while_typing, drag_3fg  
- Per-app touchpad scroll via `o.window(..., { scroll_touchpad = … })`  
- 3-finger workspace / focus gestures  

### Change layout pair

```lua
kb_layout = "us,ru",
kb_options = "grp:win_space_toggle",
```

Or use Omarchy / system settings where available, then mirror into this file so reinstalls stay consistent.

### After edits

```bash
hyprctl reload && hyprctl configerrors
```

Optional per-window layout daemon (AUR): `hypr-kblayoutd-bin` — see [Installation](Installation).
