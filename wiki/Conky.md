# Lean Conky (desktop panel)

Optional top-right desktop stats panel ([lean-conky-config](https://github.com/mysh264/lean-conky-config) / upstream [jxai/lean-conky-config](https://github.com/jxai/lean-conky-config)). It is a **layer under windows**, above the wallpaper — not a tiled window.

## Install

```bash
# Via this rice:
./install.sh --with-conky

# Or manually:
sudo pacman -S --needed conky
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
```

## Autostart

`~/.config/hypr/autostart.lua` (login only):

```lua
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")
```

Remove that line if you do not want Conky.

Manual start (skip 3s wait):

```bash
~/.config/conky/start-lcc.sh -n
```

## Configure appearance

Edit **`~/.config/conky/local.conf`** only (not upstream `conky.conf`).

Typical Wayland desktop-layer settings:

- `output_backend = "wayland"`  
- `own_window_type = "desktop"`  
- `own_window_hints` with `below`, `sticky`, skip taskbar/pager  
- `alignment = "top_right"`, `gap_x` / `gap_y`  
- Transparent background so wallpaper shows through  
- `lcc.panel = { … }` — which rows to show (replaces the whole list)  

Do **not** add a Hyprland window rule that floats/pins Conky — that draws it above tiled windows.

## Verify layer (not a client)

```bash
# Should NOT appear in clients:
hyprctl clients | rg -i conky || echo "ok: not a client"

hyprctl layers -j | python3 -c 'import json,sys
for mon, info in json.load(sys.stdin).items():
  for level, items in info["levels"].items():
    if not isinstance(items, list): continue
    for it in items:
      if it.get("namespace") == "desktop":
        print(mon, "level", level, it.get("x"), it.get("y"), it.get("w"), it.get("h"))'
```

Level **1** ≈ bottom layer (under windows). Higher levels sit on top of windows.

## Tips

- If the panel is taller than the screen, shorten `lcc.panel` row list  
- External IP field needs `curl` (some forks replaced upstream `wget`)  
- `start-lcc.sh` may patch a local `conky-wayland` binary for a Wayland font quirk — see the script comments in the Conky repo  
