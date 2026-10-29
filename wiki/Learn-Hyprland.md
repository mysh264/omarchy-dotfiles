# Learn Hyprland step by step

This page teaches **Hyprland itself** — how config works, how to change it safely, and how to debug. It does **not** assume Omarchy. For Omarchy’s Lua helpers and package layout, continue with [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland).

Official docs: [wiki.hypr.land](https://wiki.hypr.land/)

---

## 1. What Hyprland is

Hyprland is a **Wayland compositor** (window manager + display server). You configure:

| Area | Examples |
|------|----------|
| Monitors | Resolution, scale, position |
| Input | Keyboard layouts, touchpad |
| Look | Gaps, borders, blur, animations |
| Binds | Keys that launch apps or move windows |
| Window rules | Float, workspace, size for specific apps |
| Autostart | Programs that start at login |
| Plugins | Extra layouts (e.g. [hy3](https://github.com/outfoxxed/hy3)) |

Config lives under **`~/.config/hypr/`**. Never edit system packages for day-to-day rice.

---

## 2. Config formats: `.conf` vs `.lua`

| Format | Typical file | Notes |
|--------|--------------|-------|
| Classic | `hyprland.conf` | `bind = …`, `monitor = …` |
| Lua (newer Hyprland; this machine runs 0.56) | `hyprland.lua` | `hl.config({…})`, `hl.dispatch(…)` |

**Omarchy and this rice use Lua.** Same ideas apply: a setting is a key → value, a bind is a key → action. Coming from i3's plain-text config? See [Coming from i3](Coming-from-i3).

Minimal Lua idea:

```lua
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    layout = "dwindle",  -- stock Hyprland layout
  },
})
```

---

## 3. Your first safe edit (any Hyprland)

1. Open your main config (on Omarchy: `~/.config/hypr/monitors.lua` or `looknfeel.lua`).
2. Change **one** number (e.g. `gaps_in`).
3. Apply and check:

```bash
hyprctl reload
hyprctl configerrors
```

- Empty output from `configerrors` → OK  
- A printed line → that line is the bug; fix it before more edits  

**Rule:** one change → reload → verify. Do not edit ten things at once.

---

## 4. Discover the running system

```bash
# Monitors and modes
hyprctl monitors all

# Focused window (class/title for rules)
hyprctl activewindow

# All clients (normal windows)
hyprctl clients

# Layer surfaces: bar, wallpaper, dropdown terminal (not windows!)
hyprctl layers

# What keys are bound
hyprctl binds | less

# Current option value
hyprctl getoption general:gaps_in
hyprctl getoption general:layout

# Loaded plugins
hyprctl plugin list

# Live Lua (advanced)
hyprctl eval 'hl.config({ general = { gaps_in = 4 } })'   # run one Lua line (prints ok); a reload undoes it
hyprctl repl                    # interactive, Ctrl+D to exit
```

### Find a physical key’s code (`wev`)

```bash
sudo pacman -S --needed wev
wev
```

Press the key. Note **keycode** / keysym. In Hyprland Lua binds, X11-style codes are often `code:N` (evdev code + 8). This rice’s comments map US letters (Q=`code:24`, …).

---

## 5. Mental model: layouts

| Layout | Feel |
|--------|------|
| `dwindle` | Binary tree splits (Hyprland default) |
| `master` | Master + stack |
| `scrolling` | Horizontal strip (Omarchy can toggle this) |
| `hy3` | **Plugin** — i3-like containers, tabs, move whole groups |

hy3 is **not** built into Hyprland. Install with `hyprpm`, then set `general.layout = "hy3"`. Details: [Build This Rice](Build-This-Rice) and [Look and Feel](Look-and-Feel).

---

## 6. Binds in plain Hyprland Lua

Pattern:

```lua
-- Named key
hl.bind("SUPER + RETURN", function()
  -- launch or dispatch
end)

-- Or Omarchy helper (on Omarchy only):
-- o.bind("SUPER + RETURN", "Terminal", { launch = "kitty" })
```

**Important:** a second bind on the same key does **not** replace the first. Hyprland runs both. Unbind first (`pcall(hl.unbind, "SUPER + X")`); this rice does that for every Omarchy key it reuses, see [Keybindings](Keybindings).

Directions for window ops are usually `l` `d` `u` `r` (left/down/up/right).

---

## 7. Window rules

Goal: “when class is X, put it on workspace Y / float / size …”

1. Focus the app  
2. `hyprctl activewindow` → read `class:`  
3. Write a rule (Omarchy: `o.window("class-pattern", { … })`)  

Class patterns are regular expressions. A literal dot is `\.` in the regex, written `"\\."` inside a Lua string: `"(dolphin|org\\.kde\\.dolphin)"`.

See [Hyprland Core](Hyprland-Core) for this rice’s `assign()` helper.

---

## 8. Monitors

```bash
hyprctl monitors all
```

Then set output name, mode (`1920x1080@144` or `preferred`), position, scale. **Each laptop differs** — never copy blindly. Guide: [Monitors and Input](Monitors-and-Input).

---

## 9. Plugins with `hyprpm`

```bash
sudo pacman -S hyprpm
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3
hyprpm update
hyprpm reload
hyprpm list
hyprctl plugin list
```

After every **Hyprland upgrade**, run `hyprpm update` again — plugins are built for a specific compositor commit.

---

## 10. Practice checklist

Do these once so they stick:

1. [ ] Change gaps; reload; see the change  
2. [ ] Bind a free key to open a terminal; reload; press it  
3. [ ] Read `hyprctl activewindow` for your browser class  
4. [ ] Assign that browser to workspace 2; reopen it  
5. [ ] Run `hyprctl configerrors` after a deliberate typo; fix it  
6. [ ] List binds and find your description  

Then learn Omarchy’s layer: [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland).

---

## External reading

- [Hyprland Configuring](https://wiki.hypr.land/Configuring/Configuring-Hyprland/)  
- [Dispatchers](https://wiki.hypr.land/Configuring/Dispatchers/)  
- [Variables](https://wiki.hypr.land/Configuring/Variables/)  
- [hy3](https://github.com/outfoxxed/hy3)  
