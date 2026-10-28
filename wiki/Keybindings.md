# Keybindings (`bindings.lua`)

**Repo:** `hypr/bindings.lua`  
**Live:** `~/.config/hypr/bindings.lua`

Full i3-style keymap on top of Omarchy. Conflicting Omarchy binds are unbound first. hy3 dispatchers move/focus **containers**, like i3.

For a printable list see [Keybinding Cheatsheet](Keybinding-Cheatsheet).

## Before you change a key

1. See what Omarchy already bound: `omarchy menu keybindings --print`  
2. `unbind("SUPER + …")` (or the local `unbind` helper) **before** your `o.bind`  
3. Prefer `o.bind(key, "Human label", action)` so it shows in the cheatsheet  

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end
```

## Early return if hy3 missing

If `hl.plugin.hy3 == nil` (cold start before autostart reload), the file still sets up **hot corners + bar peek**, then `return`s. hy3 binds appear after the login reload.

## Feature blocks inside the file

### 1. Hot corners

Tunables at top of file:

| Variable | Default | Meaning |
|----------|---------|---------|
| `corner_size` | `8` | px from corner to trigger |
| `corner_release` | `48` | must leave this far before re-arm |

| Corner | Action |
|--------|--------|
| Top-left | Toggle bar hide (same as Super+M) |
| Top-right | Jump to workspace `97` |
| Bottom-right | Previous workspace |

Change `run_corner()` to remap corners.

### 2. Bar hide + edge peek

| Variable | Default | Meaning |
|----------|---------|---------|
| `bar_flag` | `~/.local/state/omarchy/toggles/bar-off` | persistence file |
| `bar_edge` | `4` | px from bottom to start peek |
| `bar_hover` | `36` | height treated as “on bar” |
| `bar_linger_ms` | `400` | delay before re-hiding after leave |

- **Super+M** — latch hide/show (`omarchy-shell` `syncHidden`)  
- When latched hidden, moving to the bottom edge **peeks** the bar (`setOverlay`); leaving schedules hide  

Super+Shift+M stays Omarchy Music (not rebound here).

### 3. Dropdown Kitty

`toggle_dropdown()` looks for class `dropdown.terminal`. If missing, launches Kitty with that class, then toggles `special:dropdown`. Bound to Favorites key, KP Delete, and mouse forward (276).

### 4. Applications

| Bind | Action |
|------|--------|
| Super+Return | Konsole |
| Super+Shift+Return | Kitty |
| Super+J | Brave |
| Super+Shift+J | Firefox |
| Super+N | Dolphin |

Edit the `{ launch = "…" }` strings to change apps.

### 5. Close / kill

| Bind | Action |
|------|--------|
| Super+Q / End | hy3 kill active |
| Super+right-click | close window |
| Super+X | kill all `mpv` |
| Super+Shift+X | kill Viewnior + Gwenview |
| Alt+X | kill Dolphin |

### 6. Focus / move (hy3)

Arrows + Super / Super+Shift. Also numpad focus/move variants. Directions: `l` `d` `u` `r` via `hy3.move_focus` / `hy3.move_window`.

**Do not** use string dispatchers like `hyprctl dispatch hy3:movefocus` — use the Lua plugin functions.

### 7. Screenshots

| Bind | Action |
|------|--------|
| Super+S | `omarchy-capture-screenshot fullscreen` |
| Super+Shift+S | `~/.config/hypr/scripts/screenshot-focused` |

See [Screenshots](Screenshots).

### 8. Layout (hy3)

| Bind | Action |
|------|--------|
| Super+H | horizontal group |
| Super+V | vertical group |
| Super+W | toggle tabbed ↔ split |
| Super+E | opposite split direction |
| Super+Z | toggle float |
| Super+A | focus parent |

### 9. Workspaces

- Super+` — previous  
- Super+1…0 (and 11–12 via codes) — focus; Super+Shift+N — move+follow  
- Super+Ctrl+Left/Right — move to e±1 and follow  
- Alt+Space — workspace 10  
- Numpad navigation / Shift+numpad → workspace (see cheatsheet)  
- Leftover nav keys (NumLock, KP Enter, Home, PgUp, PgDn) swallowed as nop  

### 10. Reload

Super+Shift+C and Super+Shift+R → `hyprctl reload` (Hyprland has no i3-style in-place restart).

## Keycodes vs named keys

| Style | Example | Notes |
|-------|---------|-------|
| Named | `SUPER + RETURN` | Portable across layouts for that keysym |
| Code | `SUPER + code:24` | X11 keycode (Q on US) — matches old i3 `bindcode` |

US letter codes used in comments in the file: Q=24, W=25, E=26, R=27, A=38, H=43, J=44, Z=52, X=53, C=54, V=55, N=57, grave=49; digits 1–0 → codes 10–19.

## Mouse binds caveat

For click actions (dropdown, previous workspace), **do not** pass `{ mouse = true }`. That flag is for drag/resize; a click command with it never runs. Super+right-click kill **does** use `{ mouse = true }` because it is a close-on-click gesture.

## Adding a new bind (recipe)

```lua
unbind("SUPER + B")
o.bind("SUPER + B", "My app", { launch = "my-app" })
```

Then:

```bash
hyprctl reload && hyprctl configerrors
```

## Find a key with `wev`

```bash
sudo pacman -S --needed wev
wev
```

Press the key. Use the X keycode with `code:N` in binds (often evdev + 8). US letter codes used in this file’s comments: Q=24, W=25, E=26, R=27, A=38, H=43, J=44, Z=52, X=53, C=54, V=55, N=57; digits 1–0 → codes 10–19.

## i3 → Hyprland (hy3) map

| i3 | This rice |
| --- | --- |
| `focus left/…` | `hy3.move_focus("l"/"d"/"u"/"r")` |
| `move left/…` | `hy3.move_window(…)` |
| `split h` / `v` | `hy3.make_group("h"|"v")` |
| `layout toggle tabbed split` | `hy3.change_group("toggletab")` |
| `layout toggle split` | `hy3.change_group("opposite")` |
| `focus parent` | `hy3.change_focus("raise")` |
| `kill` | `hy3.kill_active()` |
| `floating toggle` | `hl.dsp.window.float({ action = "toggle" })` |
| `workspace N` | `hl.dsp.focus({ workspace = "N" })` |
| `move container to workspace N` | `hy3.move_to_workspace("N", { follow = true })` |
| `reload` | `hyprctl reload` |

i3 stacking has no hy3 equivalent. i3 in-place `restart` does not exist — use reload.

**Always unbind** Omarchy’s conflicting keys first (lists at top of `bindings.lua`). Do not use string dispatchers like `hyprctl dispatch hy3:movefocus` — use the Lua plugin functions.

New to Omarchy binds? [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) · rebuild order: [Build This Rice](Build-This-Rice).
