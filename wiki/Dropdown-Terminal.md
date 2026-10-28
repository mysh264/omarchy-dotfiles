# Dropdown terminal (Kitty + special workspace)

Quake-style terminal on Wayland using a Hyprland **special workspace** — not Guake/Yakuake (X11-oriented).

## How the pieces connect

| Piece | File | Role |
|-------|------|------|
| Window rule | `hyprland.lua` | Class `dropdown.terminal` → `special:dropdown`, float, 40% height |
| Autostart | `autostart.lua` | `kitty --class dropdown.terminal` at login |
| Toggle | `bindings.lua` | Favorites / KP Delete / mouse forward |

**Class must stay `dropdown.terminal`** so normal Kitty (`Super+Shift+Return`) is unaffected.

## Window rule (edit size / opacity)

```lua
o.window({ class = "^dropdown\\.terminal$" }, {
  workspace = "special:dropdown silent",
  float = true,
  move = { 0, 0 },
  size = { "monitor_w", "monitor_h * 0.4" },  -- change 0.4 for taller/shorter
  opacity = "0.95 0.95",
})
```

## Toggle binds (shipped)

| Shortcut | Action |
|----------|--------|
| `XF86Favorites` | Toggle dropdown |
| KP Delete (`code:91`) | Toggle dropdown |
| Mouse forward (`mouse:276`) | Toggle dropdown |
| Mouse back (`mouse:275`) | Previous workspace (not dropdown) |

`toggle_dropdown()` relaunches Kitty if you closed the window, then `toggle_special("dropdown")`.

**Do not** pass `{ mouse = true }` on click toggles — that flag is for drag/resize and the click never runs.

## Verify

```bash
hyprctl reload && hyprctl configerrors
uwsm-app -- kitty --class dropdown.terminal   # if not autostarted yet
# press Favorites / mouse forward twice

hyprctl clients -j | python3 -c 'import json,sys
for c in json.load(sys.stdin):
  if c.get("class")=="dropdown.terminal":
    print("ws", c.get("workspace"), "float", c.get("floating"), "size", c.get("size"))'
```

## Alternatives people use

| Option | Notes |
|--------|-------|
| Kitty / Ghostty / foot on `special:dropdown` | Best Hyprland fit |
| [TildaZ](https://github.com/ensky0/tildaz) | Dedicated Quake app |
| tilda-wayland | Older; `tilda -T` |

## Side buttons not working?

```bash
wev   # hold button over a window; want mouse:275 / mouse:276
hyprctl binds -j | python3 -c 'import json,sys
for b in json.load(sys.stdin):
  if str(b.get("key","")).startswith("mouse:27"):
    print(b.get("key"), b.get("description"))'
```
