# i3-style Hyprland on Omarchy

This is the setup on this machine, written so you can rebuild it on another laptop. Omarchy already runs Hyprland. The work is to add the [hy3](https://github.com/outfoxxed/hy3) layout (i3 containers: splits and tabs) and to put your i3 keys on top of Omarchy's keys.

Do the steps in order. Each later step assumes the earlier one is in place.

Your own files live in `~/.config/hypr/`. Leave `/usr/share/omarchy/` alone. Package updates overwrite that directory.

After every edit:

```bash
hyprctl reload
hyprctl configerrors
```

`configerrors` should print nothing. If it prints a line, that line is the thing to fix. Hyprland also reloads when you save a file, but run both commands anyway so you see the error.

## 1. Install the programs your keys launch

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox viewnior gwenview
```

`hyprpm` builds Hyprland plugins. The other names are the apps in the i3 config (terminal, browser, files, image viewers). The dropdown terminal is Kitty on a Hyprland special workspace (no xfce4-terminal). Install anything else you assigned to a workspace when you actually want that app.

## 2. Install hy3

hy3 is a plugin. It has to be compiled for the Hyprland version that is running. `hyprpm` does that.

```bash
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3
hyprpm update
hyprpm reload
hyprpm list
```

`hyprpm list` should show `hy3` with `enabled: true`.

The built library is:

```text
/var/cache/hyprpm/$USER/hy3/hy3.so
```

`$USER` is your username on that laptop. On this machine the folder is `mahmoud`. On the other laptop it will be that login name. Check with:

```bash
ls "/var/cache/hyprpm/$USER/hy3/hy3.so"
```

If `hyprpm update` fails after a Hyprland upgrade, run it again. hy3 refuses to load when it was built for a different Hyprland commit. `hyprpm update` rebuilds it.

Confirm the running compositor can see the plugin:

```bash
hyprctl plugin list
hyprctl repl 'return hl.plugin.hy3 ~= nil'
```

The second command should print `true`.

## 3. Load the plugin from your config

Open `~/.config/hypr/hyprland.lua`. Omarchy's default file loads its own config, then your files. Put the plugin load **after** `require("default.hypr.omarchy")` and **before** `require("hypr.looknfeel")` and `require("hypr.bindings")`. Those two files call hy3, so the plugin has to exist first.

```lua
local hy3_plugin = "/var/cache/hyprpm/" .. (os.getenv("USER") or "") .. "/hy3/hy3.so"
if hl.plugin.hy3 == nil then
  pcall(hl.plugin.load, hy3_plugin)
end
```

`pcall` means "try, and keep going if it fails." A bad path then shows up as a config error instead of taking Hyprland down.

In `~/.config/hypr/autostart.lua`, reload plugins at login. A config reload sometimes runs before hyprpm has finished loading hy3.

```lua
o.exec_on_start("hyprpm reload")
```

## 4. Turn on the hy3 layout

Omarchy's default layout is dwindle. i3-style splits and tabs come from hy3. In `~/.config/hypr/looknfeel.lua`:

```lua
hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 3,
    border_size = 0,
    layout = "hy3",
  },

  binds = {
    -- Super+1 while you are already on workspace 1 goes back to the previous one.
    workspace_back_and_forth = true,
  },
})

-- Omarchy turns decoration blur off. hy3 tab glass needs it on.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
    },
  },
})

if hl.plugin.hy3 ~= nil then
  hl.config({
    plugin = {
      hy3 = {
        -- One window: no tab bar. Two windows: tabs. See the next section.
        tab_first_window = false,
        group_inset = 0,
        tabs = {
          -- 8px text, translucent fills + blur. padding=0 keeps the bar flush
          -- with the window (no "box inside a box" gap under the titles).
          height = 22,
          padding = 0,
          text_height = 8,
          text_font = "JetBrainsMono Nerd Font",
          text_padding = 3,
          render_text = true,
          text_center = true,
          border_width = 1,
          radius = 0,
          blur = true,
          opacity = 1.0,
          colors = {
            -- Active: strong red border; text matches inactive soft white.
            -- Full table is in looknfeel.lua (active / inactive / urgent / …).
            active = "rgba(ff202030)",
            active_border = "rgba(ff2020ff)",
            active_text = "rgba(ffffffaa)",
            inactive = "rgba(cdd6f410)",
            inactive_border = "rgba(00000000)",
            inactive_text = "rgba(ffffffaa)",
          },
        },
        autotile = {
          enable = false,
        },
      },
    },
  })
end
```

### i3-style tab bar look

This machine’s tab bar is meant to look like a thin glass strip, not a solid title box.

**Active window tab:** strong red border (`#ff2020`), same soft-white title text as the inactive tabs (`rgba(ffffffaa)`). Only the border marks which tab is active — not a different text color.

| Setting | Value | Why |
| --- | --- | --- |
| `tabs.text_height` | `8` | Small i3-like labels |
| `tabs.height` | `22` | Matches the default bar height |
| `tabs.padding` | `0` | Bar sits flush on the window (avoids nested-box gap) |
| `group_inset` | `0` | No extra inset around the group |
| `tabs.border_width` | `1` | Outline on the active tab |
| `tabs.blur` | `true` | Glass over the wallpaper / window |
| `tabs.colors.active_border` | strong red (`#ff2020`) | Active tab outline |
| `tabs.colors.active_text` | soft white (same as inactive) | Title color matches other tabs |
| `tabs.colors.inactive_text` | soft white `rgba(ffffffaa)` | Shared title color |
| `tabs.colors.*` | translucent `rgba(…)` | Blur only shows when fills are not opaque |
| `decoration.blur.enabled` | `true` | Omarchy defaults this to off; hy3 blur needs it |

To change the active outline, edit `active_border` (and `active_alt_monitor_border`) in `~/.config/hypr/looknfeel.lua`, then `hyprctl reload`. Keep `active_text` equal to `inactive_text` if you still want matching titles.

To go solid and larger again, raise `text_height` / `height`, set `blur = false`, and use opaque colors. Copy the full `colors` table from `looknfeel.lua` when rebuilding on another machine.

Check the layout:

```bash
hyprctl getoption general:layout
hyprctl getoption plugin:hy3:tab_first_window
hyprctl getoption plugin:hy3:tabs:padding
hyprctl getoption decoration:blur:enabled
```

You want `hy3`, `false`, `0`, and `true`.

### One window, no title bar

`tab_first_window = false` only affects a workspace hy3 creates from scratch. A workspace that is already a tab group keeps its bar until you change that group.

hy3's rule:

- `change_group("h")` makes the current container a horizontal split. One window in a split has no title bar.
- `change_group("tab")` makes it a tab group. Two or more windows then show the bar.

`looknfeel.lua` on this machine listens for `window.open`, `window.close`, and `window.move_to_workspace`. When the workspace has one tiled window it calls `change_group("h")`. When it has two or more it calls `change_group("tab")`. Copy that block from this machine's `looknfeel.lua` if you want the same behavior. The functions are `tiled_windows`, `apply_titlebar`, and `sync_titlebar`.

`hy3:changegroup` only affects the workspace that is focused. mpv is assigned to workspace 5 and Viewnior to workspace 6, so opening either one from somewhere else has to focus that workspace, run `change_group`, then focus back. Omarchy sets `cursor.warp_on_change_workspace = 1`, so each of those focuses throws the pointer to the middle of a window. A floating window skips this helper, which is why mpv did not do it until it was tiled.

`apply_titlebar` turns warps off for that hop and restores the previous settings afterwards:

```lua
hl.config({
  cursor = {
    no_warps = true,
    warp_on_change_workspace = 0,
  },
})
```

Read both values with `hl.get_config` before changing them, and write those saved values back after the hop, including when `change_group` throws. Otherwise a failed hop leaves warps disabled for the rest of the session.

`workspace_back_and_forth` matters inside that code. Focusing the workspace you are already on jumps to the previous workspace. The helper records the current workspace and only focuses another one when it has to.

### Saved layouts that silently disable hy3

Omarchy stores a layout per workspace when you press Super+L (the layout toggle). The files are:

```text
~/.local/state/omarchy/workspace-layouts/1.lua
~/.local/state/omarchy/workspace-layouts/2.lua
...
```

A file like `hl.workspace_rule({ workspace = "1", layout = "scrolling" })` wins over `general.layout = "hy3"` for that workspace. hy3 then ignores focus, move, and close there. The keys look dead.

Those files are loaded by `require("default.hypr.toggles")` in `hyprland.lua`. After that line, force every workspace back to hy3:

```lua
require("default.hypr.toggles")

for id = 1, 12 do
  hl.workspace_rule({ workspace = tostring(id), layout = "hy3" })
end
```

Later workspace rules override earlier ones, so this has to be **after** the toggles line.

Also unbind Super+L in `bindings.lua` (the next section). Otherwise that key writes a new scrolling or dwindle file and the shortcuts die again on that workspace.

Check what each workspace is actually using:

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

Every id you care about should say `hy3`.

## 5. Keys

Omarchy binds Super+Return, Super+arrows, Super+Q-style keys, and Super+number before your file runs. A second bind on the same key does not replace the first. You remove the old one, then add yours.

`~/.config/hypr/bindings.lua` on this machine is the full keymap. Copy that file, then fix the hy3 path only if you inlined a username anywhere (the bindings file itself does not contain one).

The pattern for one key:

```lua
hl.unbind("SUPER + E")  -- whatever Omarchy had there
o.bind("SUPER + E", "File manager", { launch = "dolphin" })
```

`{ launch = "..." }` starts the program through `uwsm-app`. A plain string runs in a shell. A hy3 call is neither of those: you pass the function hy3 returns.

```lua
local hy3 = hl.plugin.hy3
o.bind("SUPER + LEFT", "Focus left", hy3.move_focus("l"))
o.bind("SUPER + SHIFT + LEFT", "Move left", hy3.move_window("l"))
o.bind("SUPER + Q", "Kill", hy3.kill_active())
```

Directions are `l`, `d`, `u`, `r`.

Do **not** write `hyprctl dispatch hy3:movefocus l` inside a bind. This Hyprland version does not accept that dispatcher string. The Lua functions above are the ones that run.

`hl.unbind` throws if the key was not bound. Wrap it:

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end
```

`pcall` runs the function and ignores the error. Use it for unbind. Use a real `error(...)` if hy3 is missing, so you notice:

```lua
if hl.plugin.hy3 == nil then
  error("hy3 is not loaded")
end
```

### Named keys and keycodes

Two ways to name a key:

| You write | Meaning |
| --- | --- |
| `SUPER + RETURN` | The key Hyprland calls Return |
| `SUPER + code:24` | X11 keycode 24, which is Q on a US keyboard |

Your i3 `bindcode` lines use the same numbers as `code:`. `bindsym $mod+Return` becomes `SUPER + RETURN`. `bindsym $mod+Left` becomes `SUPER + LEFT`.

`$mod` in the i3 config is Super. `$alt` is Alt.

In `~/.config/hypr/bindings.lua`, every `code:` bind has an inline comment with the key name, for example:

```lua
o.bind("SUPER + code:44", "Brave", { launch = "brave" }) -- J
o.bind("code:91", "Dropdown terminal", toggle_dropdown()) -- KP Delete
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
```

US keycodes from the i3 config (same as those comments):

| Key | code | Key | code |
| --- | ---: | --- | ---: |
| 1–9 | 10–18 | 0 | 19 |
| minus | 20 | equal | 21 |
| Q | 24 | W | 25 |
| E | 26 | R | 27 |
| A | 38 | S | 39 |
| H | 43 | J | 44 |
| Z | 52 | X | 53 |
| C | 54 | V | 55 |
| N | 57 | grave | 49 |

Numpad and other codes used in this config:

| Key | code | This config |
| --- | ---: | --- |
| KP Left / KP_4 | 83 | previous workspace |
| KP Begin / KP_5 | 84 | previous workspace |
| KP Right / KP_6 | 85 | next workspace |
| KP Home / KP_7 | 79 | move window left |
| KP Up / KP_8 | 80 | first workspace |
| KP Prior / KP_9 | 81 | move window right |
| KP End / KP_1 | 87 | focus left |
| KP Down / KP_2 | 88 | last workspace |
| KP Next / KP_3 | 89 | focus right |
| KP Insert / KP_0 | 90 | previous workspace |
| KP Delete | 91 | dropdown terminal |
| End | 115 | close window |
| Num_Lock | 77 | nop (swallowed) |
| KP_Enter | 104 | nop (swallowed) |
| Home | 110 | nop (swallowed) |
| PageUp | 112 | nop (swallowed) |
| PageDown | 117 | nop (swallowed) |
| mouse right click | 273 | Super+right-click kill |
| mouse back | 275 | previous workspace |
| mouse forward | 276 | dropdown terminal |

Workspace number keys are `code:(workspace + 9)`. Workspace 1 is `code:10`. Workspace 12 is `code:21`.

Find a key you are unsure about with `wev`. Press the key and read `keysym` and the X keycode. Hyprland's `code:` value is that X keycode (evdev code + 8).

### What the i3 keys became

| i3 | Hyprland |
| --- | --- |
| `focus left/down/up/right` | `hy3.move_focus("l"/"d"/"u"/"r")` |
| `move left/...` | `hy3.move_window(...)` |
| `split h` / `split v` | `hy3.make_group("h")` / `hy3.make_group("v")` |
| `layout toggle tabbed split` | `hy3.change_group("toggletab")` |
| `layout toggle split` | `hy3.change_group("opposite")` |
| `focus parent` | `hy3.change_focus("raise")` |
| `kill` | `hy3.kill_active()` |
| `floating toggle` | `hl.dsp.window.float({ action = "toggle" })` |
| `workspace N` | `hl.dsp.focus({ workspace = "N" })` |
| `move container to workspace N` | `hy3.move_to_workspace("N", { follow = true })` |
| `workspace back_and_forth` | `hl.dsp.focus({ workspace = "previous" })` |
| `reload` | `hyprctl reload` |

i3 `layout stacking` has no hy3 command. Super+S is only unbound, so Omarchy's scratchpad does not keep that key. i3 `restart` (in-place) does not exist here. Super+Shift+R reloads the config. Same for Super+Shift+C.

Unbind at least these before rebinding them, because Omarchy uses them too: Super+Return, Super+Shift+Return, Super+W, Super+J, Super+S, Super+V, Super+X, the arrow keys with Super, Super+Shift, and Super+Ctrl, Super+L, Super+Space, and `SUPER + code:10` through `SUPER + code:19` plus the Shift variants. The lists are at the top of `bindings.lua`.

### Where Omarchy's default Hyprland files live

Do not edit anything under `/usr/share/omarchy/` — package updates overwrite it. Read it to find stock binds, then override in `~/.config/hypr/`.

| Path | What it is |
| --- | --- |
| `/usr/share/omarchy/default/hypr/` | Packaged Hyprland defaults (bindings, apps, looknfeel, …) |
| `/usr/share/omarchy/default/hypr/bindings/` | Default keybindings |
| `/usr/share/omarchy/default/hypr/bindings/utilities.lua` | Menu, themes, capture, and other utility binds |
| `/usr/share/omarchy/config/hypr/` | Templates copied into `~/.config/hypr/` on refresh |
| `~/.config/hypr/` | Your editable config (overrides load after defaults) |
| `~/.config/hypr/bindings.lua` | Your keybinding overrides |

Layout of the defaults tree:

```text
/usr/share/omarchy/default/hypr/
├── bindings/          # default keybindings (including utilities.lua)
├── apps/
├── toggles/
├── omarchy.lua
├── looknfeel.lua
└── ...
```

### Omarchy menu on Super+D

The stock Super+Space menu bind is this line in the packaged defaults:

```lua
-- /usr/share/omarchy/default/hypr/bindings/utilities.lua
o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle")
```

You will not find that bind in `~/.config/hypr/` until you override it. This machine moves the menu to Super+D so Space stays free.

In `~/.config/hypr/bindings.lua`:

1. Unbind the default key (add `"SUPER + SPACE"` to the unbind list, or call `hl.unbind("SUPER + SPACE")`).
2. Bind the new key:

```lua
o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")
```

3. Reload and check:

```bash
hyprctl reload
hyprctl configerrors
hyprctl binds | rg -A2 'Omarchy menu'
```

You should see `key: D` with modmask Super, and no Super+Space Omarchy menu bind. Super+D was free on stock Omarchy (Super+Shift+D is Docker, Super+Ctrl+D is Display).

### Per-window keyboard language

Hyprland does not remember the keyboard layout per window by itself. Layouts are global until a helper restores them on focus change.

This machine uses [hypr-kblayoutd](https://github.com/kengzzzz/hypr-kblayoutd):

1. Layouts stay in `~/.config/hypr/input.lua` (`kb_layout = "us,ara"`, toggle with Super+Space via `grp:win_space_toggle`).
2. Install the daemon (AUR):

```bash
omarchy pkg aur add hypr-kblayoutd-bin
```

3. Under uwsm, enable the user unit (do not also `exec-once` it):

```bash
systemctl --user enable --now hypr-kblayoutd.service
```

4. Optional config: `~/.config/hypr-kblayoutd/config.toml`. Layout indexes follow `kb_layout` order (`us` = 0, `ara` = 1). This machine keeps the Omarchy menu on English:

```toml
[layer_layouts]
"omarchy-menu" = 0
```

Behavior: switch to Arabic in one window, focus another (it starts on English or its last layout), focus the first again and Arabic comes back. New windows default to layout `0` (English) unless you set a class under `[default_layouts]`.

Check it is running:

```bash
systemctl --user status hypr-kblayoutd.service
```

### Dropdown terminal (Kitty + special workspace)

Guake, Yakuake, and stock Tilda are weak on pure Wayland. xfce4-terminal dropdown needed `GDK_BACKEND=x11` and pin/menu hacks. For Hyprland, the approach that works well is a **named special workspace** with a real Wayland terminal ([Omarchy discussion](https://github.com/basecamp/omarchy/discussions/3617)). Omarchy already animates special workspaces with `slidevert`.

This machine uses **Kitty** (already installed). Alternatives people use:

| Option | Notes |
| --- | --- |
| Kitty / Ghostty / foot on `special:dropdown` | Best Hyprland fit. Native Wayland, no X11. |
| [TildaZ](https://github.com/ensky0/tildaz) | Dedicated Quake-style app with Hyprland support (Arch `.pkg.tar.zst` from GitHub Releases). |
| tilda-wayland | Older GTK fork; toggle via `tilda -T`. |

Setup on this machine:

1. Window rule in `hyprland.lua` — class `dropdown.terminal` goes to `special:dropdown` as a top strip (40% height):

```lua
o.window({ class = "^dropdown\\.terminal$" }, {
  workspace = "special:dropdown silent",
  float = true,
  move = { 0, 0 },
  size = { "monitor_w", "monitor_h * 0.4" },
  opacity = "0.95 0.95",
})
```

2. Autostart in `autostart.lua` (login only):

```lua
o.launch_on_start("kitty --class dropdown.terminal")
```

3. Toggle in `bindings.lua` — Favorites key, keypad Delete, and mouse forward. Relaunches Kitty if you closed that window. Comments name the `code:` / mouse numbers:

```lua
o.bind("XF86Favorites", "Dropdown terminal", toggle_dropdown())
o.bind("code:91", "Dropdown terminal", toggle_dropdown()) -- KP Delete
-- Side buttons. 275 is back, 276 is forward.
o.bind("mouse:275", "Previous workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("mouse:276", "Dropdown terminal", toggle_dropdown()) -- mouse forward
```

`toggle_dropdown` calls `hl.dsp.workspace.toggle_special("dropdown")`. Normal Kitty stays on `Super+Shift+Return` without that class.

| Shortcut | What it is |
| --- | --- |
| `XF86Favorites` | Favorites / star key on some keyboards |
| `code:91` | KP Delete (keypad `.` / Delete) |
| `mouse:276` | Mouse forward side button |
| `mouse:275` | Mouse back side button (previous workspace, not dropdown) |

After switching away from xfce:

```bash
killall xfce4-terminal 2>/dev/null
hyprctl reload
hyprctl configerrors
uwsm-app -- kitty --class dropdown.terminal
```

Then press the Favorites key or mouse forward. Press again to hide. Check:

```bash
hyprctl clients -j | python3 -c 'import json,sys
for c in json.load(sys.stdin):
    if c.get("class")=="dropdown.terminal":
        print("ws", c.get("workspace"), "float", c.get("floating"), "size", c.get("size"))'
```

### Lean Conky Config

[Lean Conky Config](https://github.com/jxai/lean-conky-config) is the desktop panel on the top right. It is a layer under the windows, on top of the wallpaper, not a window you can raise or tile.

```bash
sudo pacman -S --needed conky
git clone https://github.com/jxai/lean-conky-config ~/.config/conky
```

`~/.config/conky/local.conf` is your copy of the settings. The upstream `conky.conf` says not to edit it. This puts the panel on the Wayland bottom layer. Hyprland draws that layer after the wallpaper and before any window, which is the desktop-widget place. A floating or pinned Conky window is drawn on top of tiled windows, so do not add a window rule for it.

```lua
lcc.fonts = {
  default = T_ "Noto Sans:size=$sc{8}",
  icon = T_ "LeanConkyConfig:size=$sc{12}",
  icon_alt = T_ "Noto Sans:size=$sc{12}",
}

conky.config = {
  output_backend = "wayland",
  own_window_type = "desktop",
  own_window_hints = "undecorated,below,sticky,skip_taskbar,skip_pager",
  own_window_namespace = "desktop",
  alignment = "top_right",
  gap_x = 20,
  gap_y = 40,
  own_window_transparent = true,
  own_window_color = "#00000000",
  draw_outline = true,
  font = T_ "Noto Sans:size=$sc{8}",
}
```

`own_window_transparent` and a fully clear `own_window_color` leave no box behind the text. The wallpaper shows through, the same as the 0.9.0 panel. `draw_outline` is on in that config.

`below` is the bottom layer, under windows and above the wallpaper. `gap_x = 20` and `gap_y = 40` are the margins from the old 0.9.0 config. `gap_y` starts the panel below the hy3 tab bar.

That old config left storage out of the panel. With storage included, the panel is taller than the screen and the last rows sit on the bottom bar. `local.conf` sets `lcc.panel` to the old row list: datetime, weather, system, cpu, memory, network. The `:normal:` pattern in the upstream font lines is rejected by fontconfig here, so `local.conf` restates the fonts with Noto Sans and the LeanConkyConfig icon font. The full list is in that file. `T_` and `$sc{}` still scale the sizes.

Conky 1.25 calls `set_font` once before that font list exists, and the Wayland backend aborts. The X11 backend only logs a warning for the same call. `start-lcc.sh` copies `/usr/bin/conky` to `~/.config/conky/conky-wayland` and changes that one check so an empty list returns instead of aborting. The next instruction loads the fonts and draws. When the Conky package is newer than that copy, the script makes the copy again. Pass `-p` if you want a different binary.

Start it from `autostart.lua`. `o.exec_on_start` runs on login, not on every `hyprctl reload`.

```lua
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")
```

`start-lcc.sh` waits 3 seconds, installs the LeanConkyConfig font into `~/.local/share/fonts`, refreshes `conky-wayland` when `/usr/bin/conky` is newer, and replaces an older copy that this same script started. To start it once without logging out:

```bash
~/.config/conky/start-lcc.sh -n
```

`-n` skips the 3 second wait. The panel should be a bottom-layer surface named `desktop`, and it should not appear in `hyprctl clients`:

```bash
hyprctl layers -j | python3 -c 'import json,sys
for mon, info in json.load(sys.stdin).items():
    for level, items in info["levels"].items():
        if not isinstance(items, list):
            continue
        for it in items:
            if it.get("namespace") == "desktop":
                print(mon, "level", level, it.get("x"), it.get("y"), it.get("w"), it.get("h"))'
```

Level 1 is the bottom layer, under windows. Level 2 and above are on top of windows.

The NETWORK section shows local addresses from `ip a` and the external IP from `curl` against `https://checkip.amazonaws.com` (refreshed every hour). Upstream uses `wget`, which is not installed here, so `lib/components/core.lua` was changed to `curl -sf --max-time 10`. Without `curl`, that field stays blank.

Colors, scale, and which rows are shown go in `~/.config/conky/local.conf`. Copy `local.conf.example` there if you do not have one yet. Setting `lcc.panel` replaces the whole row list, so include every row you still want.

If a side button does nothing, hold it over a window and run `wev`. The line you want is `code:` for that button. Back should print 275 and forward 276. Use that number after `mouse:`.

Confirm both binds loaded:

```bash
hyprctl reload
hyprctl configerrors
hyprctl binds -j | python3 -c 'import json,sys
for b in json.load(sys.stdin):
    if str(b.get("key","")).startswith("mouse:27"):
        print(b.get("key"), b.get("description"))'
```

You want `mouse:275 Previous workspace` and `mouse:276 Dropdown terminal`.

List what is actually bound:

```bash
hyprctl binds | less
```

Search that output for the description you set (`Kill`, `Focus left`, `Workspace 1`). `modmask: 64` is Super. `65` is Super+Shift. `8` is Alt.

## 6. Workspaces, names, and assignments

Still in `hyprland.lua`, after the hy3 layout loop.

No gaps when a workspace has a single tiled window, or one fullscreen window:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

`w[tv1]` means "tiled windows, exactly one." `f[1]` means "one fullscreen window."

Names. The trailing space is intentional; it matches the i3 names.

```lua
local workspace_names = {
  "1:  ",
  "2:  ",
  "3:  ",
  "4:  ",
  "5:  ",
  "6:  ",
  "7:  ",
  "8:  ",
  "9:  ",
  "10:  ",
  "11:  ",
  "12:  ",
}

for id, name in ipairs(workspace_names) do
  hl.workspace_rule({ workspace = tostring(id), default_name = name })
  pcall(function()
    hl.dispatch(hl.dsp.workspace.rename({ workspace = tostring(id), name = name }))
  end)
end
```

`default_name` applies to a workspace that does not exist yet. `workspace.rename` renames one that already exists. `pcall` is there because renaming an empty id can fail on a fresh login.

Assign an app to a workspace. The class is a Lua pattern. Dots in real class names are escaped as `%.` because `.` in a pattern means "any character."

```lua
local function assign(class, workspace, focus)
  o.window(class, {
    workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent"),
  })
end

assign("(dolphin|org%.kde%.dolphin)", 3, false)  -- open it, stay here
```

`true` matches i3 `for_window [class=...] focus` plus `assign`. `false` matches `assign` alone (the window opens on that workspace and this workspace stays put).

To learn a window's class:

```bash
hyprctl activewindow | awk '/class:|title:/'
```

Focus the window, run that, and use the `class:` line in `assign`.

The full assign list is at the bottom of `hyprland.lua`.

### mpv opens as a small floating window

Omarchy's defaults tag `mpv` as a floating window. That tag does three things: float the window, center it, and force the size to 875 by 600. Your `window-maximized=yes` in `~/.config/mpv/mpv.conf` never gets a chance to matter, because the window is floating at that fixed size.

User rules load after Omarchy's, and the last matching rule wins. Put this after the `assign` calls in `~/.config/hypr/hyprland.lua`:

```lua
o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })
```

`-floating-window` removes the tag. `tile = true` and `float = false` undo the float that the tag already applied. A tiled mpv then fills its space on workspace 5 like any other window.

Reload and open a video. The window should be tiled:

```bash
hyprctl reload
hyprctl configerrors
hyprctl clients | awk '/class: mpv/,/floating:/'
```

`floating:` should be `0`. If it is `1`, the rule did not match. Check the class with `hyprctl activewindow` while mpv is focused. The pattern `^(mpv)$` has to match that class exactly.

### Opening mpv or Viewnior jumps the cursor to the center

That jump is the title-bar hop in the section above, not the app. Both windows are tiled and assigned to another workspace, so `apply_titlebar` focuses that workspace and focuses back. Each focus warps the pointer to the middle of a window. Floating mpv used to skip the helper, so tiling it made mpv start jumping the cursor too.

The fix lives in `apply_titlebar` in `~/.config/hypr/looknfeel.lua`: set `cursor.no_warps` and `cursor.warp_on_change_workspace = 0` before the hop, then put the old values back. The steps and the reason are in "One window, no title bar" above.

Viewnior also has this rule, matching the i3 config, which assigns it without focusing it:

```lua
o.window("(Viewnior|viewnior)", { no_initial_focus = true, focus_on_activate = false })
```

That rule stops Viewnior from taking focus. It does not stop the title-bar hop. Without the `no_warps` pair in `apply_titlebar`, the cursor still jumps.

Reload, note the cursor, then open an image or a video from the file manager. The cursor should stay on the file you clicked, and the workspace should stay the one you were on.

```bash
hyprctl reload
hyprctl configerrors
hyprctl cursorpos
```

## 7. Viewnior on X11

Viewnior on Wayland is the broken one. Force the X11 backend with a user desktop file. Copying into `~/.local/share/applications/` overrides `/usr/share/applications/` for your user only.

```bash
cp /usr/share/applications/viewnior.desktop ~/.local/share/applications/viewnior.desktop
```

Change the `Exec=` line to:

```ini
Exec=env GDK_BACKEND=x11 GTK_THEME=Adwaita:dark /usr/bin/viewnior %F
```

`GTK_THEME=Adwaita:dark` is the dark theme. Section 8 explains why Viewnior needs it spelled out.

Then:

```bash
update-desktop-database ~/.local/share/applications
```

Open an image from the file manager. The process environment should contain the backend:

```bash
tr '\0' '\n' < /proc/$(pgrep -n viewnior)/environ | grep GDK_BACKEND
```

You want `GDK_BACKEND=x11`.

## 8. App themes

Omarchy paints the desktop from one theme. Apps are separate toolkits, so a theme change does not always reach every window.

### The whole desktop

```bash
omarchy theme list
omarchy theme current
omarchy theme set "Catppuccin"
```

`omarchy theme set` rewrites the bar, terminal, Hyprland colors, and the GNOME settings that GTK apps read. Whether that result is light or dark comes from the theme itself. Catppuccin on this machine is dark (`mode = "dark"` in its `colors.toml`). A theme with `mode = "light"` switches GTK apps to light.

### Omarchy bar glass

The bottom status bar is lightly translucent with Hyprland blur behind it (same idea as the hy3 tab strip).

| Piece | Where | Value |
| --- | --- | --- |
| Bar fill alpha | `~/.config/omarchy/themed/shell.toml.tpl` → `[bar] background-alpha` | `0.55` (a little see-through; `1.0` is solid) |
| Live theme file | `~/.local/state/omarchy/current/theme/shell.toml` | Regenerated on `omarchy theme set` / `refresh` from that template |
| Layer blur | `~/.config/hypr/looknfeel.lua` | `hl.layer_rule` on namespace `omarchy-bar` with `blur = true`, `ignore_alpha = true` |
| Compositor blur | same `looknfeel.lua` | `decoration.blur.enabled = true` (Omarchy defaults this off) |

Keep `"transparent": false` in `~/.config/omarchy/shell.json`. That flag makes the bar fully clear (no fill). Partial glass uses `background-alpha` instead.

After editing the template, re-apply the theme so the live `shell.toml` updates:

```bash
omarchy theme refresh
# or: omarchy theme set catppuccin
```

### Wallpaper slideshow

Your images live in `~/.Wallpapers` (including subfolders like `w` and `wall-archive`). A user service walks them in sorted order and sets each one with `omarchy theme bg set`. Default interval is **5 minutes**.

Files:

| Path | Role |
| --- | --- |
| `~/.local/bin/wallpaper-slideshow` | Script (`--next` once, `--loop` forever) |
| `~/.config/wallpaper-slideshow.conf` | Folder and interval |
| `~/.config/systemd/user/wallpaper-slideshow.service` | Starts the loop with the graphical session |

**Change how often it rotates** — edit `INTERVAL_SEC` in the config (seconds), then restart the service:

```bash
# Examples: 60 = 1 min, 300 = 5 min, 600 = 10 min, 1800 = 30 min
$EDITOR ~/.config/wallpaper-slideshow.conf
systemctl --user restart wallpaper-slideshow.service
```

**Useful commands:**

```bash
wallpaper-slideshow --next          # jump to the next image now
wallpaper-slideshow --prev          # previous image
wallpaper-slideshow --toggle        # pause / resume
systemctl --user status wallpaper-slideshow.service
systemctl --user stop wallpaper-slideshow.service    # pause rotation
systemctl --user start wallpaper-slideshow.service   # resume
systemctl --user disable --now wallpaper-slideshow.service  # off at login too
```

**Bar controller** — `wallpaper` in `~/.config/omarchy/shell.json` loads `~/.config/omarchy/bar/modules/wallpaper.qml` (before the tray). Previous · pause/resume · next. Scroll over it for prev/next. Tooltip shows the current file and interval.

`WALLPAPER_DIR` in the same config file is the folder it scans. Leave it as `$HOME/.Wallpapers` unless you move the collection.

See what GTK is using:

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
```

Dark looks like `prefer-dark` and `Adwaita-dark`. Light looks like `prefer-light` and `Adwaita`.

To change only the light/dark switch, without picking a new Omarchy theme:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

Swap those two values for light: `prefer-light` and `Adwaita`. New windows pick this up. A window that is already open keeps the theme it started with until you close it.

Qt apps (Dolphin, Konsole, Kate) follow the same choice when `QT_QPA_PLATFORMTHEME` is `gtk3`, which is the Omarchy default. They do not have their own theme file in this setup.

### Apps you forced onto X11

Viewnior runs with `GDK_BACKEND=x11`. An X11 GTK3 app does not read the Wayland theme. It reads `~/.config/gtk-3.0/settings.ini`. Create that file:

```ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=Yaru-purple
```

`gtk-icon-theme-name` should match `gsettings get org.gnome.desktop.interface icon-theme`, or the icons change too. For a light theme, use `gtk-theme-name=Adwaita` and `gtk-application-prefer-dark-theme=0`.

One app can be pinned without changing the others. Put the theme in its desktop file, next to the X11 flag:

```ini
Exec=env GDK_BACKEND=x11 GTK_THEME=Adwaita:dark /usr/bin/viewnior %F
```

`Adwaita:dark` means the Adwaita theme, dark variant. `GTK_THEME=Adwaita` is the light variant.

### Viewnior's own background

The GTK theme colors the menus and buttons. The area around the picture is a separate Viewnior switch, and it defaults to a light canvas.

Either open Viewnior and enable **View → Dark background**, or edit `~/.config/viewnior/viewnior.conf` while Viewnior is closed:

```ini
dark-background=true
```

Close Viewnior before editing that file. On exit it writes the file from whatever is on screen, so a still-open window will put `dark-background=false` back.

## 9. Mouse corners

Hyprland has no corner bind. `bindings.lua` polls the cursor every 50ms and fires once when it enters an 8px square in a corner of the monitor it is on. The corner stays quiet until the pointer is 48px away, so holding it in the corner does not repeat.

This block is above the hy3 early return, so the corners still work on a cold start before the plugin has loaded.

| Corner | Action |
| --- | --- |
| Top left | Hide the bar. The same corner shows it again and leaves it shown |
| Top right | Workspace 97, an empty workspace, which is the show-desktop |
| Bottom right | `focus` workspace `previous`, which swaps the current workspace and the one you just left |

Super+M does the same hide as the top-left corner. It was not bound before this. Super+Shift+M is still Music.

The bar is on the bottom edge (`"position": "bottom"` in `~/.config/omarchy/shell.json`). Hiding creates `~/.local/state/omarchy/toggles/bar-off` and tells the shell to re-read it:

```lua
hl.exec_cmd("mkdir -p ~/.local/state/omarchy/toggles && touch ~/.local/state/omarchy/toggles/bar-off && omarchy-shell -q omarchy.bar syncHidden")
```

Showing deletes that file and runs `syncHidden` again. `toggle_bar` in `bindings.lua` is the function both Super+M and the top-left corner call.

While the bar is hidden, the bottom 4px of the screen brings it back over the windows. The `bar-off` flag stays in place, so the windows do not shrink to make room. That overlay is `barOverlay` in the cloned bar, `~/.config/omarchy/plugins/mahmoud.bar/Bar.qml`. The stock bar always reserves space when it is visible, which is why the peek could not be done there. `omarchy plugin clone omarchy.bar` made this copy and pointed `bar.id` in `shell.json` at `mahmoud.bar`. The layout of widgets is unchanged.

```lua
hl.exec_cmd("omarchy-shell -q omarchy.bar setOverlay yes")
```

`setOverlay no` parks the bar off the bottom edge again. Moving the pointer off the bar starts a 400ms wait (`bar_linger_ms`). If the pointer comes back onto the bar during that wait, the wait is cancelled. Super+M or the top-left corner during a peek leaves the bar shown for good, in its normal place, because that is the "show it" half of the toggle. A bar that is shown for good does reserve its strip.

`bar_edge` is the strip that reveals the bar. `bar_hover` is how close to the bottom still counts as "on the bar" once it is visible. The bar itself is about 26px tall, and `bar_hover` is 36 so the pointer has to clearly leave it.

`corner_size` is how close to a corner the pointer must be. `corner_release` is how far it must move before that corner arms again. Raise `corner_size` if a corner is hard to hit.

Hide the bar with Super+M or the top-left corner, touch the bottom edge, then move the pointer up. The bar should stay about a second and then hide. Super+M again leaves it shown.

## 10. Check the result

```bash
hyprctl reload
hyprctl configerrors
hyprctl plugin list
hyprctl getoption general:layout
```

Then, on a workspace with two windows:

- Super+Left / Right moves focus.
- Super+Shift+Left / Right moves the window.
- Super+Q closes the focused window.
- Super+H splits horizontal, Super+V splits vertical, Super+W toggles tabs.
- Super+Return opens Konsole on workspace 1 and follows it.

On a workspace with one window, there is no title bar. Open a second window there and the bar appears. Close it and the bar goes away.

If a key does nothing:

1. `hyprctl configerrors`
2. `hyprctl repl 'return hl.plugin.hy3 ~= nil'` must be `true`
3. `hyprctl binds` and search for your description. If it is missing, the bind did not load.
4. The workspace layout from section 4. A scrolling or dwindle workspace ignores hy3.
5. You forgot `hl.unbind` and Omarchy's bind is the one that runs.

## Copying this machine instead of retyping

On the other laptop, after `hyprpm enable hy3` has succeeded, you can copy the finished files and then fix the username inside `hyprland.lua` if you copied the hardcoded path:

```text
~/.config/hypr/hyprland.lua
~/.config/hypr/looknfeel.lua
~/.config/hypr/bindings.lua
~/.config/hypr/autostart.lua
~/.config/hypr-kblayoutd/config.toml
~/.local/share/applications/viewnior.desktop
~/.config/gtk-3.0/settings.ini
~/.config/viewnior/viewnior.conf
```

Also install `hypr-kblayoutd-bin` and run `systemctl --user enable --now hypr-kblayoutd.service` for per-window keyboard language.

`monitors.lua` and `input.lua` stay the other laptop's own files. Screens and keyboards differ.

Reload, then run the checks in section 10.
