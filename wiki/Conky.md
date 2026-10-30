# Lean Conky (desktop stats panel)

An optional stats panel at the top right of the desktop, using [lean-conky-config](https://github.com/mysh264/lean-conky-config) (the owner's fork of [jxai/lean-conky-config](https://github.com/jxai/lean-conky-config)). It is not a window. It is a Wayland **layer surface** on the *bottom* layer: above the wallpaper, under every window. So tiled windows cover it and it never takes a tile.

If you ran Conky on i3 with `own_window_type = 'desktop'`, the idea is the same. On Wayland the "desktop" type turns into a layer surface.

## Where it lives

| What | Path |
|------|------|
| Conky config (separate git repo, not in this rice) | `~/.config/conky/` |
| Your settings | `~/.config/conky/local.conf` |
| Starter script | `~/.config/conky/start-lcc.sh` |
| Autostart line | `hypr/autostart.lua` → `~/.config/hypr/autostart.lua` |

## Install

```bash
# With this rice:
./install.sh --with-conky

# Or by hand:
sudo pacman -S --needed conky
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
```

`--with-conky` installs the `conky` package if it is missing, then does the clone and the copy. It skips the clone if `~/.config/conky` already exists; update an existing clone with `git -C ~/.config/conky pull`.

The config repo does **not** contain Conky itself. Without the `conky` package, `start-lcc.sh` stops with `ERROR: Conky is not installed.` and the install command (older copies of the script instead printed `cp: cannot stat '/usr/bin/conky'` and a Python traceback).

## Autostart

In `hypr/autostart.lua` (runs at login only, not on `hyprctl reload`):

```lua
-- Lean Conky Config. start-lcc.sh waits 3 seconds, kills a previous copy
-- started by this script, and installs its font. This runs on login only.
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")
```

Remove that line if you do not want Conky. (In i3 this was `exec --no-startup-id ~/.config/conky/start-lcc.sh`.)

By hand:

```bash
~/.config/conky/start-lcc.sh -n   # start now, skip the 3-second wait
~/.config/conky/start-lcc.sh -r   # reload the running panel after editing local.conf
```

## Change how it looks

Edit **`~/.config/conky/local.conf`** only, not `conky.conf`, so pulling the Conky repo never conflicts with your changes.

The Wayland example ships these desktop-layer settings:

```lua
  output_backend = "wayland",
  own_window_type = "desktop",
  own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",
  alignment = "top_right",
  gap_x = 20,
  gap_y = 40,
  own_window_transparent = true,
  own_window_argb_value = 0,
```

- `gap_x` / `gap_y`: distance from the corner. `gap_y` clears a top bar or hy3 tab strip.  
- `own_window_transparent` + `own_window_argb_value = 0`: no background, the wallpaper shows through.  
- `lcc.panel = { … }`: which rows to show. It **replaces** the whole default list, so list every row you want.

Do **not** add a Hyprland window rule to float or pin Conky. That makes it a normal window drawn above your tiles.

## Check it is a layer, not a window

```bash
hyprctl clients | grep -i conky || echo "ok: not a window"
hyprctl layers | grep -B1 "namespace: desktop"
```

You should see it under `Layer level 1 (bottom)`, with namespace `desktop`, for example:

```text
	Layer level 1 (bottom):
		Layer 5589a71e8cd0: xywh: 1612 40 288 970, a: 1, namespace: desktop, pid: 4332
```

Level 0 is the background (Omarchy's wallpaper, `omarchy-background`), level 1 is under windows, levels 2–3 are above them (the bar is on level 2).

## Tips

- If the panel is taller than the screen, shorten the `lcc.panel` list.  
- Rows that fetch web data (such as the external IP) use `curl`.  
- **Why the process is called `conky-wayland`:** Conky's Wayland output calls `set_font()` once before the fonts are loaded, and an `assert` there aborts distro builds (they keep asserts on). `start-lcc.sh` runs `tools/patch-conky-wayland`, which copies `/usr/bin/conky` to `~/.config/conky/conky-wayland` and turns that one assert into a plain return (4 bytes). It finds the code by its shape, anchored on the binary's import of `pango_layout_set_font_description`, so it works on Arch's build, **CachyOS's x86-64-v3/v4 rebuilds** (where an older fixed-byte patch found nothing), and later versions with the same code. `conky-wayland.source` records the system binary's path and checksum; any Conky update re-patches on the next start. If a build does not match, nothing is patched, a warning is printed, and the system `conky` runs as is.
- Check the fix by hand: `python3 ~/.config/conky/tools/patch-conky-wayland /usr/bin/conky /tmp/conky-test` prints the file offset it patched, or why it refused.  
