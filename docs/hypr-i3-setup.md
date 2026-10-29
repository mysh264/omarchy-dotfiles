# i3-style Hyprland on Omarchy

This is how this machine was built, written so you can rebuild it on another laptop, or copy the parts you want into your own Hyprland. Omarchy already runs Hyprland. The work is to add the [hy3](https://github.com/outfoxxed/hy3) layout plugin by outfoxxed (i3 containers: splits and tabs), put the i3 keys on top of Omarchy's keys, and add a Quake-style dropdown terminal ([TildaZ](https://github.com/ensky0/tildaz) by ensky0).

If you used i3 for years, most of this will feel familiar: `bindsym` becomes `o.bind`, `assign` becomes an `o.window` rule, `split h` becomes `hy3.make_group("h")`. The comparison tables in each section show the i3 line next to the Hyprland one.

Do the steps in order. Each later step assumes the earlier ones are in place. The short version of every step, one page per feature, is in the [wiki](https://github.com/mysh264/omarchy-dotfiles/wiki).

## The Omarchy rules this guide follows

- Your files live in `~/.config/hypr/`. They are loaded **after** Omarchy's defaults, so anything you set there wins.
- Leave `/usr/share/omarchy/` alone. Package updates overwrite it. Read it to see what Omarchy binds by default, then override in `~/.config/hypr/`.
- Hyprland's config is **Lua** on Omarchy 4.x: `hyprland.lua`, `bindings.lua`, `looknfeel.lua`, and so on. Omarchy adds helpers such as `o.bind`, `o.window`, `o.exec_on_start` and `o.launch_on_start` next to Hyprland's own `hl.*` API.

After every edit:

```bash
hyprctl reload
hyprctl configerrors
```

`configerrors` should print nothing. If it prints a line, that line is the thing to fix. Hyprland also reloads when you save a file, but run both commands anyway so you see the error.

In this guide, "repo" means this dotfiles repository. `hypr/bindings.lua` in the repo is installed as `~/.config/hypr/bindings.lua`.

## 1. Install the programs your keys launch

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave-bin firefox viewnior gwenview
```

`hyprpm` builds Hyprland plugins. The other names are the apps the i3 config launched or assigned (terminal, browser, files, image viewers). `brave-bin` comes from the `[omarchy]` repo. Install anything else you assign to a workspace when you actually want that app.

TildaZ, the dropdown terminal, is not a pacman package. Section 6 installs it.

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

If `hyprpm update` fails after a Hyprland upgrade, run it again. hy3 refuses to load when it was built for a different Hyprland version, and `hyprpm update` rebuilds it.

Confirm the running compositor can see the plugin:

```bash
hyprctl plugin list
hyprctl repl 'return hl.plugin.hy3 ~= nil'
```

The second command should print `true`.

## 3. Load hy3 after login, not at cold start

In i3 the layout was built in. Here it is a plugin, and **when** it loads matters.

On this laptop (NVIDIA), loading hy3 while Hyprland is still creating its renderer deadlocks the compositor. Hyprland never finishes starting and the login times out. So hy3 is **not** loaded from `hyprland.lua`. `hyprland.lua` only has a comment where you might expect the load:

```lua
-- hy3 is loaded by autostart after the compositor is up. Loading it while
-- the NVIDIA renderer is still being created deadlocks this laptop, so
-- Hyprland never finishes startup and the login times out.
```

Instead, `hypr/autostart.lua` loads it once Hyprland is up, then reloads the config so the hy3 layout and keys apply:

```lua
o.exec_on_start("hyprpm reload && hyprctl reload")
```

`o.exec_on_start` runs once per login, not on every `hyprctl reload`.

That means every file runs twice at login: once without hy3, once with it. Each file that uses hy3 checks first:

| File | Without hy3 (cold start) | With hy3 (after the autostart reload) |
| --- | --- | --- |
| `looknfeel.lua` | `general.layout = "dwindle"`, no hy3 tab settings | `layout = "hy3"`, tab look, auto-tabs |
| `bindings.lua` | Hot corners and `Super+M` only, then `return` | The full i3 keymap |
| `hyprland.lua` | Workspaces 1–12 forced to `dwindle` | Workspaces 1–12 forced to `hy3` |

The check is always the same:

```lua
local layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"
```

Do **not** name the `hy3` layout, or call `hl.plugin.load`, before the plugin is in. On a machine without the NVIDIA problem you could load it earlier, but the deferred load works everywhere, so this repo keeps it.

Check after login:

```bash
hyprctl getoption general:layout
```

You want `hy3`. If it says `dwindle`, the autostart reload has not run or failed. Run `hyprpm reload && hyprctl reload` by hand and read `hyprctl configerrors`.

## 4. Turn on the hy3 layout

Omarchy's default layout is dwindle. i3-style splits and tabs come from hy3. In `~/.config/hypr/looknfeel.lua`:

```lua
local layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"

hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 3,
    border_size = 5,
    layout = layout,
  },
})

-- Omarchy turns blur off. hy3 tab glass and the translucent Omarchy bar need it.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
    },
  },
})

hl.config({
  binds = {
    -- Pressing the key for the workspace you are already on goes back.
    workspace_back_and_forth = true,
  },
})
```

`workspace_back_and_forth` is the i3 option of the same name.

The tab look lives in the same file, inside `if hl.plugin.hy3 ~= nil then`:

```lua
if hl.plugin.hy3 ~= nil then
  hl.config({
    plugin = {
      hy3 = {
        tab_first_window = false,
        group_inset = 0,
        tabs = {
          height = 22,
          padding = 0,
          render_text = true,
          text_center = true,
          text_font = "JetBrainsMono Nerd Font",
          text_height = 8,
          text_padding = 3,
          border_width = 1,
          radius = 0,
          blur = true,
          opacity = 1.0,
          colors = {
            -- Glass strip; active tab keeps a strong red border, same text as others.
            active = "rgba(ff202030)",
            active_border = "rgba(ff2020ff)",
            active_text = "rgba(ffffffaa)",
            active_alt_monitor = "rgba(cdd6f418)",
            active_alt_monitor_border = "rgba(ff2020aa)",
            active_alt_monitor_text = "rgba(ffffffaa)",
            focused = "rgba(cdd6f418)",
            focused_border = "rgba(bac2de66)",
            focused_text = "rgba(ffffffaa)",
            inactive = "rgba(cdd6f410)",
            inactive_border = "rgba(00000000)",
            inactive_text = "rgba(ffffffaa)",
            urgent = "rgba(f38ba840)",
            urgent_border = "rgba(f38ba8ee)",
            urgent_text = "rgba(f38ba8ff)",
            locked = "rgba(f9e2af40)",
            locked_border = "rgba(f9e2afee)",
            locked_text = "rgba(f9e2afff)",
          },
        },
        autotile = {
          enable = false,
        },
      },
    },
  })
  -- … auto-tab helpers, see "One window, no title bar" below …
end
```

### i3-style tab bar look

The tab bar is the i3 title bar: a thin glass strip flush on the window, not a solid title box.

**Active tab:** strong red border (`#ff2020`), same soft-white title text as the other tabs (`rgba(ffffffaa)`). Only the border marks which tab is active.

| Setting | Value | Why |
| --- | --- | --- |
| `tabs.text_height` | `8` | Small i3-like labels |
| `tabs.height` | `22` | Matches the bar height |
| `tabs.padding` | `0` | Bar sits flush on the window (no nested-box gap) |
| `group_inset` | `0` | No extra inset around the group |
| `tabs.border_width` | `1` | Outline on the active tab |
| `tabs.blur` | `true` | Glass over the wallpaper / window |
| `tabs.colors.active_border` | `rgba(ff2020ff)` | Active tab outline |
| `tabs.colors.active_text` | `rgba(ffffffaa)` | Same as `inactive_text` |
| `tabs.colors.*` | translucent `rgba(…)` | Blur only shows through fills that are not opaque |
| `decoration.blur.enabled` | `true` | Omarchy defaults this to off; hy3 blur needs it |

To change the active outline, edit `active_border` (and `active_alt_monitor_border`) in `~/.config/hypr/looknfeel.lua`, then `hyprctl reload`. Keep `active_text` equal to `inactive_text` if you want matching titles.

To go solid and larger, raise `text_height` / `height`, set `blur = false`, and use opaque colors.

Check:

```bash
hyprctl getoption general:layout
hyprctl getoption general:border_size
hyprctl getoption plugin:hy3:tab_first_window
hyprctl getoption plugin:hy3:tabs:padding
hyprctl getoption decoration:blur:enabled
```

You want `hy3`, `5`, `false`, `0`, and `true`.

### No gaps around a single window

i3 users know this as `smart_gaps on`. In `hyprland.lua`:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

`w[tv1]` means "exactly one visible tiled window" (a hy3 tab group counts as one). `f[1]` means "a maximized window" (Omarchy's Super+Alt+F, Full width). Split windows keep `gaps_in = 8` / `gaps_out = 3` from `looknfeel.lua`.

Do **not** use `Super+Shift+Backspace` for this. That is Omarchy's **global** "Toggle window gaps". It writes `~/.local/state/omarchy/toggles/hypr/window-no-gaps.lua`, which loads after your files and sets gaps **and** borders to 0 for every window. Split windows then touch with no border. Press the same keys again, or run `omarchy-hyprland-window-gaps-toggle`, to turn it off.

### One window, no title bar; two windows, tabs

`tab_first_window = false` only affects a container hy3 creates from scratch. A workspace that is already a tab group keeps its bar until you change that group.

hy3's rule:

- `change_group("h")` makes the container a horizontal split. One window in a split has no title bar.
- `change_group("tab")` makes it a tab group, which shows the bar.

`looknfeel.lua` listens for `window.open`, `window.close`, and `window.move_to_workspace` and counts the tiled windows on that workspace:

| Tiled windows | What happens |
| --- | --- |
| 0 or 1 | `change_group("h")`: plain split, no title bar |
| exactly 2 | `change_group("tab")`: the second window turns the container into tabs |
| 3 or more | Left alone, so a split you chose by hand (`Super+W`, `Super+E`) survives |

```lua
local total_windows = tiled_windows(workspace_id, except_address)
if total_windows <= 1 then
  hl.dispatch(hl.plugin.hy3.change_group("h"))
elseif total_windows == 2 then
  -- Only force "tab" when a 2nd window opens up initially.
  -- If you manually choose a layout later, it won't be trapped here.
  hl.dispatch(hl.plugin.hy3.change_group("tab"))
end
```

The helper functions are `tiled_windows`, `apply_titlebar`, and `sync_titlebar`. Copy the whole block from the repo's `looknfeel.lua` if you want the same behavior.

`hy3.change_group` only affects the focused workspace. mpv is assigned to workspace 5 and Viewnior to workspace 6, so opening either one from somewhere else has to focus that workspace, run `change_group`, then focus back. Omarchy sets `cursor.warp_on_change_workspace = 1`, so each of those focuses throws the pointer to the middle of a window.

`apply_titlebar` turns warps off for that hop and restores the previous settings afterwards:

```lua
hl.config({
  cursor = {
    no_warps = true,
    warp_on_change_workspace = 0,
  },
})
```

It reads both values with `hl.get_config` before changing them and writes them back after the hop, even when `change_group` throws. Otherwise a failed hop would leave warps disabled for the rest of the session.

`workspace_back_and_forth` matters here too. Focusing the workspace you are already on jumps to the previous one. The helper records the current workspace and only focuses another one when it has to.

### Saved layouts that silently disable hy3

Omarchy stores a layout per workspace when you press `Super+L` ("Toggle workspace layout"). The files are:

```text
~/.local/state/omarchy/workspace-layouts/1.lua
~/.local/state/omarchy/workspace-layouts/2.lua
...
```

A file like `hl.workspace_rule({ workspace = "1", layout = "scrolling" })` wins over `general.layout` for that workspace. hy3 then ignores focus, move, and close there. The keys look dead.

`require("default.hypr.toggles")` in `hyprland.lua` loads those files. After that line, force every workspace back. It uses the same hy3 check as section 3, so a cold start does not name hy3 before it is loaded:

```lua
require("default.hypr.toggles")

local workspace_layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"
if hl.plugin.hy3 == nil then
  hl.config({ general = { layout = "dwindle" } })
end
for id = 1, 12 do
  hl.workspace_rule({ workspace = tostring(id), layout = workspace_layout })
end
```

Later workspace rules override earlier ones, so this has to be **after** the toggles line.

`bindings.lua` also unbinds `Super+L` (section 5). Otherwise that key writes a new scrolling or dwindle file and the shortcuts die again on that workspace.

Check what each workspace is using:

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

Every id you care about should say `hy3`.

## 5. Keys

Omarchy binds `Super+Return`, `Super+arrows`, `Super+number` and more before your file runs. A second bind on the same key does not replace the first. You remove the old one, then add yours.

The repo's `hypr/bindings.lua` is the full keymap. Copy that file; it has no usernames or machine paths in it.

The pattern for one key:

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end

unbind("SUPER + RETURN")   -- whatever Omarchy had there
o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })
```

`hl.unbind` throws if the key was not bound. `pcall` runs it and ignores that error.

What `o.bind` accepts as the action:

| You pass | What runs |
| --- | --- |
| `{ launch = "konsole" }` | The program, started through `uwsm-app` |
| `"omarchy-menu toggle"` | A shell command |
| `hy3.move_focus("l")` | A hy3 dispatcher (the function hy3 returns) |
| `hl.dsp.focus({ workspace = "2" })` | A Hyprland dispatcher |
| a Lua function | Your own code, for example `toggle_bar` |

The description (second argument) is what Omarchy's keybinding menu shows (`omarchy menu keybindings`).

```lua
local hy3 = hl.plugin.hy3
o.bind("SUPER + LEFT", "Focus left", hy3.move_focus("l"))
o.bind("SUPER + SHIFT + LEFT", "Move left", hy3.move_window("l"))
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
```

Directions are `l`, `d`, `u`, `r`.

Do **not** write `hyprctl dispatch hy3:movefocus l` inside a bind. The Lua functions above are what this Hyprland runs.

hy3 binds only exist after the autostart reload (section 3). `bindings.lua` stops early on a cold start:

```lua
local hy3 = hl.plugin.hy3
if hy3 == nil then
  -- Cold start has not loaded hy3 yet. autostart.lua loads it after the
  -- compositor is up and reloads this file, which is when these binds apply.
  return
end
```

Anything that must work before hy3 loads (hot corners, `Super+M`) goes above that line.

### Named keys and keycodes

Two ways to name a key:

| You write | Meaning |
| --- | --- |
| `SUPER + RETURN` | The key Hyprland calls Return |
| `SUPER + code:24` | X11 keycode 24, which is Q on a US keyboard |

Your i3 `bindcode` lines use the same numbers as `code:`. `bindsym $mod+Return` becomes `SUPER + RETURN`. `bindsym $mod+Left` becomes `SUPER + LEFT`. `$mod` in the i3 config is Super. `$alt` is Alt.

Letters are bound by `code:` on purpose. With the Arabic layout active, `SUPER + Q` would not match, because Q no longer types `q`. The keycode stays the same in every layout.

Every `code:` bind in `bindings.lua` has a comment with the key name:

```lua
o.bind("SUPER + code:44", "Brave", { launch = "brave" }) -- J
o.bind("code:91", "Dropdown terminal", { launch = "tildaz --toggle" }) -- KP Delete
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
```

US keycodes used here:

| Key | code | Key | code |
| --- | ---: | --- | ---: |
| 1–9 | 10–18 | 0 | 19 |
| minus | 20 | equal | 21 |
| Q | 24 | W | 25 |
| E | 26 | R | 27 |
| A | 38 | H | 43 |
| J | 44 | Z | 52 |
| X | 53 | C | 54 |
| V | 55 | N | 57 |
| grave | 49 | | |

Numpad, mouse and other codes used in this config:

| Key | code | This config |
| --- | ---: | --- |
| KP End / KP_1 | 87 | focus left (Shift: workspace 1) |
| KP Down / KP_2 | 88 | last workspace (Shift: 2) |
| KP Next / KP_3 | 89 | focus right (Shift: 3) |
| KP Left / KP_4 | 83 | previous workspace (`e-1`) (Shift: 4) |
| KP Begin / KP_5 | 84 | previous workspace (Shift: 5) |
| KP Right / KP_6 | 85 | next workspace (`e+1`) (Shift: 6) |
| KP Home / KP_7 | 79 | move window left (Shift: 7) |
| KP Up / KP_8 | 80 | first workspace (Shift: 8) |
| KP Prior / KP_9 | 81 | move window right (Shift: 9) |
| KP Insert / KP_0 | 90 | previous workspace (Shift: 10) |
| KP Delete | 91 | dropdown terminal |
| End | 115 | close window |
| Num_Lock, KP_Enter, Home, PageUp, PageDown | 77, 104, 110, 112, 117 | nop (swallowed) |
| mouse right click | `mouse:273` | `Super` + right-click closes the window |
| mouse back | `mouse:275` | previous workspace |
| mouse forward | `mouse:276` | dropdown terminal |

The numpad binds have no modifier, so they swallow the key in every app, the same as the i3 `bindcode` lines.

Workspace number keys are `code:(workspace + 9)`. Workspace 1 is `code:10`, workspace 10 is `code:19` (the 0 key), 11 is `code:20` (minus), 12 is `code:21` (equal).

Find a key you are unsure about with `wev`. Press the key and read the keysym and the keycode. Hyprland's `code:` value is the X keycode (evdev code + 8).

### What the i3 keys became

| i3 | Key here | Hyprland |
| --- | --- | --- |
| `focus left/down/up/right` | `Super+arrows` | `hy3.move_focus("l"/"d"/"u"/"r")` |
| `move left/…` | `Super+Shift+arrows` | `hy3.move_window(…)` |
| `split h` / `split v` | `Super+H` / `Super+V` | `hy3.make_group("h")` / `hy3.make_group("v")` |
| `layout toggle tabbed split` | `Super+W` | `hy3.change_group("toggletab")` |
| `layout toggle split` | `Super+E` | `hy3.change_group("opposite")` |
| `focus parent` | `Super+A` | `hy3.change_focus("raise")` |
| `kill` | `Super+Q`, `End` | `hy3.kill_active()` |
| `floating toggle` | `Super+Z` | `hl.dsp.window.float({ action = "toggle" })` |
| `workspace N` | `Super+1` … `Super+=` | `hl.dsp.focus({ workspace = "N" })` |
| `move container to workspace N` | `Super+Shift+1` … | `hy3.move_to_workspace("N", { follow = true })` |
| `workspace back_and_forth` | `` Super+` `` | `hl.dsp.focus({ workspace = "previous" })` |
| `reload` / `restart` | `Super+Shift+C`, `Super+Shift+R` | `hyprctl reload` |
| `exec konsole` | `Super+Return` | `{ launch = "konsole" }` |

`Super+Ctrl+Left/Right` moves the window to the previous / next workspace and follows it. `Alt+Space` jumps to workspace 10.

i3 `layout stacking` has no hy3 equivalent here. i3's in-place `restart` does not exist in Hyprland; both `Super+Shift+C` and `Super+Shift+R` reload the config.

Other keys this config sets that are not i3 commands:

| Key | Action |
| --- | --- |
| `Super+Shift+Return` | Kitty |
| `Super+J` / `Super+Shift+J` | Brave / Firefox |
| `Super+N` | Dolphin |
| `Super+S` | Full-screen screenshot (`omarchy-capture-screenshot fullscreen`) |
| `Super+Shift+S` | Focused-window screenshot (`~/.config/hypr/scripts/screenshot-focused`) |
| `Super+X` / `Super+Shift+X` / `Alt+X` | Kill all mpv / image viewers / Dolphin |
| `Super+M` | Hide or show the bar (section 10) |
| `Super+D` | Omarchy menu |

The unbind list at the top of `bindings.lua` is every Omarchy key this keymap reuses: `Super+Return`, `Super+Shift+Return`, `Super+W`, `Super+J`, `Super+S`, `Super+Shift+S`, `Super+V`, `Super+X`, `Super+Shift+C`, `Super+Shift+X`, the arrows with `Super`, `Super+Shift` and `Super+Ctrl`, `Super+L`, `Super+Space`, `Super+minus/equal` (with and without Shift), `Super`+right-click, and `Super+1`…`Super+0` plus their Shift variants. Add to that list when you take another Omarchy key.

### Where Omarchy's default Hyprland files live

Read these to find stock binds. Do not edit them.

| Path | What it is |
| --- | --- |
| `/usr/share/omarchy/default/hypr/` | Packaged Hyprland defaults (bindings, apps, looknfeel, toggles, …) |
| `/usr/share/omarchy/default/hypr/bindings/` | Default keybindings: `tiling.lua`, `utilities.lua`, `applications.lua`, … |
| `/usr/share/omarchy/config/hypr/` | The starter files Omarchy copies into `~/.config/hypr/` |
| `~/.config/hypr/` | Your config (loaded after the defaults) |

To see what is actually bound right now:

```bash
hyprctl binds | less
omarchy menu keybindings     # searchable menu with the descriptions
```

In `hyprctl binds`, `modmask: 64` is Super, `65` is Super+Shift, `8` is Alt.

### Omarchy menu on Super+D

The stock menu bind is in the packaged defaults:

```lua
-- /usr/share/omarchy/default/hypr/bindings/utilities.lua
o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle")
```

This machine moves the menu to `Super+D` (dmenu's old key in i3). `"SUPER + SPACE"` is in the unbind list, then:

```lua
o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")
```

Check:

```bash
hyprctl binds | grep -B4 'Omarchy menu'
```

You should see `key: D` with `modmask: 64`, and no `Super+Space` menu bind. `Super+D` is free on stock Omarchy (`Super+Shift+D` is Docker, `Super+Ctrl+D` is Display).

### Mouse side buttons

```lua
-- Side buttons. 275 is back, 276 is forward.
-- Do not pass mouse = true here. That flag is for drag and resize binds.
-- A click command with that flag never runs.
unbind("mouse:275")
unbind("mouse:276")
o.bind("mouse:275", "Previous workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("mouse:276", "Dropdown terminal", { launch = "tildaz --toggle" })
```

If a side button does nothing, run `wev`, press it over its window, and read the button code. Back should be 275 and forward 276. Then check both binds loaded:

```bash
hyprctl binds -j | python3 -c 'import json,sys
for b in json.load(sys.stdin):
    if str(b.get("key","")).startswith("mouse:27"):
        print(b.get("key"), b.get("description"))'
```

You want `mouse:275 Previous workspace` and `mouse:276 Dropdown terminal`.

### Keyboard layouts and per-window language

`hypr/input.lua` sets the layouts:

```lua
kb_layout = "us,ara",
kb_options = "grp:win_space_toggle",
-- kb_variant = "intl",
```

`Win+Space` toggles between US and Arabic. `kb_variant = "intl"` (US-International) is commented out; uncomment it if you want dead keys.

Hyprland does not remember the layout per window by itself. This machine uses [hypr-kblayoutd](https://github.com/kengzzzz/hypr-kblayoutd) for that:

```bash
omarchy pkg aur add hypr-kblayoutd-bin
systemctl --user enable --now hypr-kblayoutd.service
```

Under uwsm, use the user unit; do not also start it from autostart.

Optional config: `~/.config/hypr-kblayoutd/config.toml`. Layout indexes follow `kb_layout` order (`us` = 0, `ara` = 1). This machine keeps the Omarchy menu on English:

```toml
[layer_layouts]
"omarchy-menu" = 0
```

Switch to Arabic in one window, focus another (it starts on English or its last layout), focus the first again, and Arabic comes back. New windows start on layout `0` unless you set a class under `[default_layouts]`.

```bash
systemctl --user status hypr-kblayoutd.service
```

## 6. Dropdown terminal (TildaZ)

i3 users usually had a Quake terminal: a script around `xfce4-terminal --drop-down`, Guake, or a scratchpad. On Wayland most of those either need X11 or fight the compositor. [TildaZ](https://github.com/ensky0/tildaz) ([tildaz.dev](https://tildaz.dev)) is a dropdown terminal made for this: native Wayland, its own global hotkey, tabs and panes.

### Install

`install.sh` does this for you (skip with `--skip-tildaz`). By hand:

```bash
curl -LsSf https://tildaz.dev/install.sh | sh      # official installer, user-local, no sudo
mkdir -p ~/.config/tildaz
cp tildaz/config_0.toml ~/.config/tildaz/config_0.toml   # from the repo
tildaz --desktop add
```

The binary ends up in `~/.local/bin/tildaz`.

### How it starts

`tildaz --desktop add` writes `~/.config/hypr/tildaz.lua`, which starts TildaZ when Hyprland starts. That file holds an absolute path for this user, so it is **not** in the repo; every machine writes its own. The last line of `hyprland.lua` loads it if it exists:

```lua
pcall(require, "tildaz")
```

`pcall` keeps a machine without TildaZ from getting a config error. `tildaz --desktop remove` deletes the file again. There is no TildaZ line in `autostart.lua`.

### Keys

TildaZ registers its own global hotkey, **`F1`**, from `~/.config/tildaz/config_0.toml`:

```toml
hotkey = "F1"
```

You do not bind `F1` in `bindings.lua`. TildaZ adds that bind to Hyprland itself; `hyprctl binds` lists it with a description like `…/tildaz --toggle 0 · F1`.

`hypr/bindings.lua` adds three more keys that call `tildaz --toggle`:

```lua
o.bind("XF86Favorites", "Dropdown terminal", { launch = "tildaz --toggle" })
o.bind("code:91", "Dropdown terminal", { launch = "tildaz --toggle" }) -- KP Delete
o.bind("mouse:276", "Dropdown terminal", { launch = "tildaz --toggle" })
```

| Key | What it is |
| --- | --- |
| `F1` | TildaZ's own hotkey (added by TildaZ, so it does not wait for hy3) |
| `XF86Favorites` | Favorites / star key on some keyboards |
| `code:91` | KP Delete (keypad `.` / Delete) |
| `mouse:276` | Mouse forward side button |

The three Hyprland binds sit after the hy3 check in `bindings.lua`, so they work once hy3 has loaded. `F1` always works.

Keep the hotkey on an F-key. Hyprland matches TildaZ's hotkey by the character the key types, so a **letter** hotkey (for example `ctrl+t`) stops working while the Arabic layout is active. F-keys type the same thing in every layout.

### Size and look

Also in `config_0.toml`: docked at the top, 95% wide, 50% high, 90% opacity, theme `Tilda`, DejaVu Sans Mono 15, `/usr/bin/bash`.

```toml
[window]
dock_position   = "top"
width_percent   = 95.0
height_percent  = 50.0
opacity_percent = 90.0
```

TildaZ is a Wayland **layer surface** (namespace `tildaz`), not a window. Window rules (`o.window`) never match it, and it does not show in `hyprctl clients`. Its blur and slide animation come from a layer rule in `looknfeel.lua`:

```lua
hl.layer_rule({
  match = { namespace = "tildaz" },
  blur = true,
  ignore_alpha = 0.1,
  animation = "slide top",
})
```

`ignore_alpha = 0.1` blurs behind everything that is at least 10% opaque, which is the whole 90% terminal.

### Check

```bash
pgrep -a tildaz                 # running
ls ~/.config/hypr/tildaz.lua    # autostart written
hyprctl layers | grep tildaz    # press F1 first; it is a layer, not a client
hyprctl binds | grep -B4 'Dropdown terminal'
hyprctl binds | grep -B4 'tildaz --toggle'   # the F1 bind TildaZ added
```

If `F1` does nothing, check that TildaZ is running and that no other app grabs `F1`. If a change to `config_0.toml` does not show up, restart TildaZ (`pkill tildaz`, then run `tildaz`) or log out and in. Every setting is explained in TildaZ's `CONFIG.md`.

## 7. Workspaces, names, and assignments

All in `hyprland.lua`, after the layout loop from section 4.

### Names

i3: `set $ws1 "1: >_"` and `workspace $ws1`. Here, a table. The trailing space is intentional; it matches the i3 names. The icons are Nerd Font glyphs.

```lua
local workspace_names = {
  "1:  ",
  "2:  ",
  "3: ",
  "4:  ",
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
  -- Existing workspaces keep their old name until renamed. Empty ones pick up default_name.
  pcall(function()
    hl.dispatch(hl.dsp.workspace.rename({ workspace = tostring(id), name = name }))
  end)
end
```

`default_name` applies to a workspace that does not exist yet. `workspace.rename` renames one that already exists. `pcall` is there because renaming an empty id can fail on a fresh login.

The bar shows these names. The cloned workspaces widget (`omarchy/plugins/mahmoud.workspaces/`) reads this table from `~/.config/hypr/hyprland.lua` and watches the file. It always shows workspaces 1–7 (`alwaysShown: 7` in its `Workspaces.qml`), shows 8–12 only while they exist, highlights the current one and dims empty ones. Edit names **only** here; the widget follows. Details: [Plugins](https://github.com/mysh264/omarchy-dotfiles/wiki/Plugins).

### Assign an app to a workspace

i3: `assign [class="dolphin"] 4` and `for_window [class="Brave"] focus`. Here:

```lua
-- assign: move the window and stay here. focus: move it and switch to that workspace.
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end

assign("(Brave-browser|brave-browser)", 2, true)
assign("(dolphin|org\\.kde\\.dolphin)", 4, false)
```

The class is a **regular expression**. Dots in real class names are escaped as `\\.` (a backslash for the regex, doubled inside a Lua string) because `.` alone means "any character."

`true` matches i3 `assign` plus `for_window … focus` (you follow the window). `false` matches `assign` alone (the window opens there, you stay put).

Terminals are not assigned. They open on the workspace you are on.

The current list:

| Workspace | Apps | Follow? |
| --- | --- | --- |
| 2 | Brave, Firefox | yes |
| 3 | Kate | yes |
| 4 | Dolphin | no |
| 5 | mpv, Haruna | no |
| 6 | Viewnior, Gwenview | no |
| 7 | Stremio, Kodi (follow); Jellyfin Media Player (no follow) | mixed |
| 8 | qBittorrent | yes |
| 9 | Thunderbird | yes |
| 10 | Typora | yes |
| 11 | Plasma System Monitor | yes |
| 12 | System settings, disks, partition tools, firewall, Flatseal, Grub Customizer | yes |

To learn a window's class, focus it and run:

```bash
hyprctl activewindow | grep -E 'class:|title:'
```

Use the `class:` value in `assign`.

### mpv opens as a small floating window

Omarchy's defaults tag `mpv` as a floating window: float, center, and a fixed 875×600 size. Your `window-maximized=yes` in `~/.config/mpv/mpv.conf` never matters, because the window is floating at that size.

User rules load after Omarchy's, and the last matching rule wins. After the `assign` calls:

```lua
o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })
```

`-floating-window` removes the tag. `tile = true` and `float = false` undo the float the tag already applied. A tiled mpv then fills its space on workspace 5 like any other window.

```bash
hyprctl reload
hyprctl configerrors
hyprctl clients -j | jq '.[] | select(.class == "mpv") | .floating'
```

It should print `false`. If it prints `true`, the rule did not match. Check the class with `hyprctl activewindow` while mpv is focused.

### Opening mpv or Viewnior jumps the cursor to the center

That jump is the title-bar hop from section 4, not the app. Both windows are tiled and assigned to another workspace, so `apply_titlebar` focuses that workspace and focuses back, and each focus warps the pointer. The fix is the `no_warps` pair in `apply_titlebar` (section 4).

Viewnior also has this rule, matching the i3 config, which assigned it without focusing it:

```lua
o.window("(Viewnior|viewnior)", { no_initial_focus = true, focus_on_activate = false })
```

That rule stops Viewnior from taking focus. It does not stop the title-bar hop; the `no_warps` pair does.

Note the cursor, open an image or a video from the file manager, and check the cursor stayed on the file you clicked:

```bash
hyprctl cursorpos
```

## 8. Viewnior on X11

Viewnior misbehaves on Wayland here. Force the X11 backend with a user desktop file. A copy in `~/.local/share/applications/` overrides `/usr/share/applications/` for your user only.

```bash
cp /usr/share/applications/viewnior.desktop ~/.local/share/applications/viewnior.desktop
```

Change the `Exec=` line to:

```ini
Exec=env GDK_BACKEND=x11 GTK_THEME=Adwaita:dark /usr/bin/viewnior %F
```

`GTK_THEME=Adwaita:dark` is the dark theme. Section 9 explains why Viewnior needs it spelled out.

```bash
update-desktop-database ~/.local/share/applications
```

Open an image from the file manager, then:

```bash
tr '\0' '\n' < /proc/$(pgrep -n viewnior)/environ | grep GDK_BACKEND
```

You want `GDK_BACKEND=x11`.

This desktop file is machine-local; it is not in the repo.

## 9. Themes, bar glass and wallpapers

Omarchy paints the desktop from one theme. Apps use separate toolkits, so a theme change does not always reach every window.

### The whole desktop

```bash
omarchy theme list
omarchy theme current
omarchy theme set "Catppuccin"
```

`omarchy theme set` rewrites the bar, terminal, Hyprland colors, and the GNOME settings that GTK apps read. Light or dark comes from the theme itself. Catppuccin is dark (`mode = "dark"` in its `colors.toml`).

### Omarchy bar glass

The bottom bar is lightly translucent with Hyprland blur behind it, the same idea as the hy3 tab strip.

| Piece | Where | Value |
| --- | --- | --- |
| Bar fill alpha | `~/.config/omarchy/themed/shell.toml.tpl` → `[bar] background-alpha` | `0.55` (`1.0` is solid) |
| Live theme file | `~/.local/state/omarchy/current/theme/shell.toml` | Regenerated from that template on `omarchy theme set` / `omarchy theme refresh` |
| Layer blur | `~/.config/hypr/looknfeel.lua` | `hl.layer_rule` on namespace `omarchy-bar` |
| Compositor blur | same file | `decoration.blur.enabled = true` (Omarchy defaults this off) |

The layer rule:

```lua
hl.layer_rule({
  match = { namespace = "omarchy-bar" },
  blur = true,
  ignore_alpha = false,
  no_anim = false,
  animation = "none",
})
```

Keep `"transparent": false` in `~/.config/omarchy/shell.json`. That flag makes the bar fully clear (no fill). Partial glass comes from `background-alpha` instead.

After editing the template, re-apply the theme so the live `shell.toml` updates:

```bash
omarchy theme refresh
```

### Wallpaper slideshow

Wallpapers rotate from `~/.Wallpapers` with a small user service. The script, its config and the service are in the repo under `wallpaper/` and `install.sh` installs them (`--skip-wallpaper` to skip). The bar control is `omarchy/bar/modules/wallpaper.qml`, wired as `{ "id": "wallpaper", "type": "qml" }` in `shell.json`.

| Path | Role |
| --- | --- |
| `~/.local/bin/wallpaper-slideshow` | Script (`--next`, `--prev`, `--toggle`, `--loop`) |
| `~/.config/wallpaper-slideshow.conf` | `WALLPAPER_DIR` and `INTERVAL_SEC` |
| `~/.config/systemd/user/wallpaper-slideshow.service` | Runs the loop with the graphical session |

```bash
$EDITOR ~/.config/wallpaper-slideshow.conf      # INTERVAL_SEC=300 is 5 minutes
systemctl --user restart wallpaper-slideshow.service
wallpaper-slideshow --next
```

Each image is set with `omarchy theme bg set`. The bar control gives previous · pause/resume · next; scroll over it for prev/next. More: [Wallpaper Widget](https://github.com/mysh264/omarchy-dotfiles/wiki/Wallpaper-Widget).

### GTK light / dark

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
```

Dark is `prefer-dark` and `Adwaita-dark`. Light is `prefer-light` and `Adwaita`. To flip only that, without picking a new Omarchy theme:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

New windows pick this up. Open windows keep their theme until you close them.

Qt apps (Dolphin, Konsole, Kate) follow the same choice when `QT_QPA_PLATFORMTHEME` is `gtk3`, which is the Omarchy default.

### Apps forced onto X11

An X11 GTK3 app such as Viewnior does not read the Wayland theme. It reads `~/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=Yaru-purple
```

`gtk-icon-theme-name` should match `gsettings get org.gnome.desktop.interface icon-theme`. For light, use `gtk-theme-name=Adwaita` and `gtk-application-prefer-dark-theme=0`.

One app can be pinned without changing the others by putting the theme in its desktop file, next to the X11 flag (section 8). `Adwaita:dark` is the dark variant; `GTK_THEME=Adwaita` is light.

### Viewnior's own background

The area around the picture is a separate Viewnior switch and defaults to light. Enable **View → Dark background**, or edit `~/.config/viewnior/viewnior.conf` while Viewnior is closed:

```ini
dark-background=true
```

Viewnior writes that file on exit from whatever is on screen, so an open window puts `dark-background=false` back.

## 10. Mouse corners and the hidden bar

Hyprland has no corner bind. `bindings.lua` polls the cursor every 50 ms and fires once when it enters an 8 px square in a corner of the monitor it is on. The corner stays quiet until the pointer is 48 px away, so resting in the corner does not repeat.

This block is above the hy3 early return, so the corners work on a cold start too.

| Corner | Action |
| --- | --- |
| Top left | Hide the bar. The same corner shows it again |
| Top right | Workspace 97, an empty workspace: show desktop |
| Bottom right | Workspace `previous`: swap with the one you just left |

`Super+M` does the same as the top-left corner. `Super+Shift+M` is still Omarchy's Music.

The bar is on the bottom edge (`"position": "bottom"` in `shell.json`). Hiding creates `~/.local/state/omarchy/toggles/bar-off` and tells the shell to re-read it:

```lua
hl.exec_cmd(shell .. " && omarchy-shell -q omarchy.bar syncHidden")
```

Showing deletes that file and runs `syncHidden` again. `toggle_bar` in `bindings.lua` is the function both `Super+M` and the top-left corner call.

While the bar is hidden, touching the bottom 4 px of the screen brings it back **over** the windows. The `bar-off` flag stays, so windows do not shrink to make room. That overlay is `barOverlay` in the cloned bar, `~/.config/omarchy/plugins/mahmoud.bar/Bar.qml`. The stock bar always reserves space when visible, which is why the peek could not be done without a clone. `omarchy plugin clone omarchy.bar` made the copy and pointed `bar.id` in `shell.json` at `mahmoud.bar`; see `omarchy/plugins/mahmoud.bar/README.md` in the repo for the exact change.

```lua
hl.exec_cmd("omarchy-shell -q omarchy.bar setOverlay yes")
```

`setOverlay no` parks the bar off the bottom edge again. Moving the pointer off the bar starts a 400 ms wait (`bar_linger_ms`). Coming back onto the bar cancels it. `Super+M` or the top-left corner during a peek shows the bar for good, in its normal place, reserving its strip.

| Variable | Default | Meaning |
| --- | --- | --- |
| `bar_edge` | `4` | Strip at the bottom that reveals the bar |
| `bar_hover` | `36` | How close to the bottom still counts as "on the bar" (the bar is about 26 px) |
| `bar_linger_ms` | `400` | Wait before hiding after the pointer leaves |
| `corner_size` | `8` | How close to a corner the pointer must be. Raise it if a corner is hard to hit |
| `corner_release` | `48` | How far the pointer must move before the corner arms again |

Test: hide the bar with `Super+M`, touch the bottom edge, then move the pointer up. The bar stays a moment and hides. `Super+M` again leaves it shown.

## 11. Lean Conky Config

[Lean Conky Config](https://github.com/jxai/lean-conky-config) by jxai is the desktop panel on the top right. It is a layer under the windows, on top of the wallpaper, not a window you can raise or tile. This machine uses a fork with Wayland fixes, [mysh264/lean-conky-config](https://github.com/mysh264/lean-conky-config). `./install.sh --with-conky` clones it.

```bash
sudo pacman -S --needed conky
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
```

`~/.config/conky/local.conf` is your copy of the settings. Upstream `conky.conf` says not to edit it. The Wayland settings put the panel on the bottom layer, which Hyprland draws after the wallpaper and before any window. Do not add a window rule for it; a floating or pinned Conky window would sit on top of tiled windows.

```lua
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
}
```

`own_window_transparent` and a fully clear `own_window_color` leave no box behind the text. `gap_y = 40` starts the panel below the hy3 tab bar.

`local.conf` also sets `lcc.panel` to a shorter row list (datetime, weather, system, cpu, memory, network) so the panel fits above the bottom bar, and restates the fonts with Noto Sans and the LeanConkyConfig icon font, because fontconfig rejects the `:normal:` pattern in the upstream font lines. Setting `lcc.panel` replaces the whole row list, so include every row you want.

Conky 1.25 calls `set_font` once before that font list exists, and the Wayland backend aborts. `start-lcc.sh` copies `/usr/bin/conky` to `~/.config/conky/conky-wayland` with that one check changed, and redoes the copy when the Conky package is newer.

Start it from `autostart.lua` (login only):

```lua
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")
```

`start-lcc.sh` waits 3 seconds, installs the LeanConkyConfig font into `~/.local/share/fonts`, refreshes `conky-wayland` if needed, and replaces an older copy that the same script started. To start it now without logging out:

```bash
~/.config/conky/start-lcc.sh -n
```

`-n` skips the wait. The panel is a layer named `desktop` and does not appear in `hyprctl clients`:

```bash
hyprctl layers | grep -E 'Layer level|namespace: desktop'
```

The `desktop` line should sit under `Layer level 1 (bottom)`, which is under the windows.

The NETWORK section reads the external IP with `curl` from `https://checkip.amazonaws.com` every hour. Without `curl`, that field stays blank.

Remove the `start-lcc.sh` line from `autostart.lua` if you do not use Conky. More: [Conky](https://github.com/mysh264/omarchy-dotfiles/wiki/Conky).

## 12. Check the result

```bash
hyprctl reload
hyprctl configerrors
hyprctl plugin list
hyprctl getoption general:layout
```

Then:

- `Super+Return` opens Konsole on the current workspace. One window: no title bar, no gaps.
- `Super+Return` again: the two windows become tabs.
- `Super+Left` / `Right` moves focus; `Super+Shift+Left` / `Right` moves the window.
- `Super+H` / `Super+V` start a split, `Super+W` toggles tabs, `Super+E` flips the split.
- `Super+Q` closes the focused window. Close one of two and the title bar goes away.
- `F1` drops TildaZ down from the top. `F1` again hides it.
- `Super+D` opens the Omarchy menu.

If a key does nothing:

1. `hyprctl configerrors`
2. `hyprctl repl 'return hl.plugin.hy3 ~= nil'` must print `true`. If not, run `hyprpm reload && hyprctl reload`
3. `hyprctl binds` and search for your description. If it is missing, the bind did not load
4. The workspace layout check from section 4. A scrolling or dwindle workspace ignores hy3
5. You forgot to unbind, and Omarchy's bind is the one that runs

## Copying this machine instead of retyping

`./install.sh` copies the repo files for you. These files are machine-local and not in the repo; copy them by hand if you want them on the other laptop:

```text
~/.config/hypr-kblayoutd/config.toml
~/.local/share/applications/viewnior.desktop
~/.config/gtk-3.0/settings.ini
~/.config/viewnior/viewnior.conf
~/.config/conky/local.conf
```

Do **not** copy `~/.config/hypr/tildaz.lua`; run `tildaz --desktop add` on the new machine so it writes its own path.

Also install `hypr-kblayoutd-bin` and run `systemctl --user enable --now hypr-kblayoutd.service` for per-window keyboard language.

`monitors.lua` and `input.lua` stay the other laptop's own files. Screens and keyboards differ.

Log out and back in once, then run the checks in section 12.
