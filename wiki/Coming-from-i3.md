# Coming from i3

You have a `~/.config/i3/config` you have tuned for years and you want the same feel on [Omarchy](https://omarchy.org) (Arch + Hyprland, by DHH / Omacom). This page maps i3 ideas onto this setup, one concept at a time, and points to the page with the details.

The short version:

- **Hyprland** is the window manager (a Wayland compositor). Its config is **Lua**, split over several files in `~/.config/hypr/`.
- **Omarchy** ships the defaults in `/usr/share/omarchy/` (never edit it) and loads your files after them. You override; you do not fork.
- **[hy3](https://github.com/outfoxxed/hy3)** (by outfoxxed) is a Hyprland plugin that brings i3's tree back: containers, `split h` / `split v`, tabs, focus parent.
- **[TildaZ](https://github.com/ensky0/tildaz)** (by ensky0) is the Quake-style dropdown terminal.

## Concept map

| i3 (`~/.config/i3/config`) | Here | File | Details |
|----------------------------|------|------|---------|
| One config file | Several Lua files, loaded in order | `hypr/hyprland.lua` + `monitors`, `input`, `looknfeel`, `bindings`, `autostart` | [Hyprland Core](Hyprland-Core) |
| `$mod+Shift+c` reload | `hyprctl reload` (Super+Shift+C) | `bindings.lua` | [Config and reload](#config-file-and-reload) |
| `$mod+Shift+r` restart | Also `hyprctl reload` (Super+Shift+R); there is no in-place restart | `bindings.lua` | |
| `i3 -C` (check config) | `hyprctl configerrors` | — | |
| `set $mod Mod4` | Write `SUPER` in each bind | `bindings.lua` | |
| `bindsym` / `bindcode` | `o.bind("SUPER + Q", …)` / `o.bind("SUPER + code:24", …)` | `bindings.lua` | [Keybindings](Keybindings) |
| `exec` | `o.exec_on_start` / `o.launch_on_start` | `autostart.lua` | [Autostart](Autostart) |
| `exec_always` | No direct equivalent | — | [exec](#exec-and-exec_always) |
| `set $ws1 "1: "` + `workspace $ws1` | `workspace_names` table | `hyprland.lua` | [Workspaces](#workspaces-and-names) |
| `workspace_auto_back_and_forth yes` | `binds.workspace_back_and_forth = true` | `looknfeel.lua` | |
| `assign [class="X"] N` | `assign("X", N, false)` | `hyprland.lua` | [assign](#assign-and-for_window) |
| `for_window [class="X"] …` | `o.window("X", { … })` | `hyprland.lua` | |
| `split h` / `split v` | `hy3.make_group("h")` / `("v")` | `bindings.lua` | [Layouts](#splits-tabs-and-stacking) |
| `layout tabbed` / `toggle split` | `hy3.change_group("toggletab")` / `("opposite")` | `bindings.lua` | |
| `layout stacking` | Not available in hy3 | — | |
| `focus parent` | `hy3.change_focus("raise")` | `bindings.lua` | |
| `focus` / `move left` … | `hy3.move_focus("l")` / `hy3.move_window("l")` | `bindings.lua` | |
| `floating toggle` | `hl.dsp.window.float({ action = "toggle" })` | `bindings.lua` | [Floating](#floating) |
| `floating_modifier $mod` | Super+left-drag moves (Omarchy) | Omarchy default | |
| `move scratchpad` / `scratchpad show` | Hyprland special workspace: Super+Alt+S / Super+Shift+Alt+S | `bindings.lua` (+ Omarchy default) | [Scratchpad](#scratchpad-and-the-quake-terminal) |
| Quake terminal on the scratchpad | TildaZ on F1 | `~/.config/tildaz/config_0.toml` | [Dropdown Terminal](Dropdown-Terminal) |
| `gaps inner 8` / `gaps outer 3` | `gaps_in = 8` / `gaps_out = 3` | `looknfeel.lua` | [Gaps](#gaps-and-borders) |
| `smart_gaps on` | `w[tv1]` + `f[1]` workspace rules | `hyprland.lua` | |
| `default_border pixel 5` | `border_size = 5` | `looknfeel.lua` | |
| `client.focused` colours | Omarchy theme (`omarchy theme set …`) | theme | |
| i3 title bars | hy3 tab strip | `looknfeel.lua` | [Look and Feel](Look-and-Feel) |
| `focus_follows_mouse yes` | `input.follow_mouse = 1` | `input.lua` | [Monitors and Input](Monitors-and-Input) |
| `exec setxkbmap -layout us,ara …` | `kb_layout`, `kb_options` | `input.lua` | |
| `xrandr` / `output` lines | `hl.monitor({ … })` | `monitors.lua` | |
| `bar { status_command i3status }` | Omarchy bar (`shell.json`) + widgets | `~/.config/omarchy/` | [Bar](#i3bar-and-i3status) |
| `mode "resize"` | No mode here; Omarchy's resize keys | — | [Resize](#resize-mode) |
| `i3-msg …` | `hyprctl dispatch …` / `hyprctl eval '…'` | — | |
| `xprop` (find a class) | `hyprctl activewindow` | — | |

## Config file and reload

In i3 everything was in one text file, and you pressed `$mod+Shift+c` to reload or `$mod+Shift+r` to restart in place.

Here `~/.config/hypr/hyprland.lua` loads Omarchy's defaults first, then your files:

```lua
require("default.hypr.omarchy")   -- Omarchy defaults
require("hypr.monitors")          -- yours, so yours win
require("hypr.input")
require("hypr.looknfeel")
require("hypr.bindings")
require("hypr.autostart")
```

- Hyprland **auto-reloads** when it sees a config change (`misc:disable_autoreload` is `false` here). Super+Shift+C and Super+Shift+R both run `hyprctl reload` for when you want to be sure. There is no i3-style restart.
- After every edit, check for errors. Empty output means OK:

```bash
hyprctl reload && hyprctl configerrors
```

- Like i3's nagbar, Hyprland keeps running on a bad config and reports the error. Fix the line and reload.

## `bindsym` → `o.bind`

i3:

```text
bindsym $mod+Return exec konsole
bindsym $mod+q kill
```

Here (`hypr/bindings.lua`):

```lua
o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
```

- The second argument is a label. Super+K (Omarchy's keybindings menu) shows it.
- `code:N` is a physical key, like i3's `bindcode`. Most letter binds here use codes so they keep working on the Arabic layout. Find codes with `wev`.
- **Unbind first.** Omarchy already uses many keys, and Hyprland runs *every* bind on a key, so both would fire. `bindings.lua` unbinds every Omarchy key it reuses:

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end
unbind("SUPER + RETURN")
```

Full keymap and the list of Omarchy keys it replaces: [Keybindings](Keybindings) · printable: [Keybinding Cheatsheet](Keybinding-Cheatsheet).

## `exec` and `exec_always`

| i3 | Here |
|----|------|
| `exec --no-startup-id conky` | `o.exec_on_start("~/.config/conky/start-lcc.sh")` (a shell command, once at login) |
| `exec firefox` | `o.launch_on_start("firefox")` (same, started through `uwsm-app --` the way Omarchy starts apps) |
| `exec_always …` | No direct equivalent |

Both helpers run on Hyprland's `hyprland.start` event, which does **not** fire on reload. Lua in your config files does run again on every reload, but a program started from there would start again every time. In practice you rarely need `exec_always`: settings re-apply on reload by themselves.

Omarchy already starts the bar, notifications, the first-run setup and more. Put only your extras in `autostart.lua`. See [Autostart](Autostart).

## Workspaces and names

i3:

```text
set $ws1 "1: "
bindsym $mod+1 workspace $ws1
bindsym $mod+Shift+1 move container to workspace $ws1
```

Here the names are one table in `hypr/hyprland.lua`:

```lua
local workspace_names = {
  "1:  ",
  "2:  ",
  -- … up to 12
}
```

A loop gives each workspace that name (`default_name`) and renames existing ones on every reload. The keys are generic, in `bindings.lua`: Super+1…0 and Super+Minus / Super+Equal for 11 and 12, Super+Shift+same to move a window there and follow it.

**The bar reads the same table.** The `mahmoud.workspaces` widget watches `hyprland.lua`, so a saved edit updates the bar. Workspaces 1–7 always show; 8–12 show only while they exist. Edit names only in `hyprland.lua`. Details: [Hyprland Core](Hyprland-Core#workspace-names-icons).

Other i3 workspace habits:

| i3 | Here |
|----|------|
| `workspace back_and_forth` | Super+` or KP 0 / KP 5 / mouse back |
| `workspace_auto_back_and_forth yes` | `workspace_back_and_forth = true` in `looknfeel.lua` |
| `workspace next` / `workspace prev` | KP 6 / KP 4, or Omarchy's Super+Tab / Super+Shift+Tab |
| `workspace N output HDMI-1` | `hl.workspace_rule({ workspace = "N", monitor = "HDMI-A-1" })` (not used in this repo) |

## `assign` and `for_window`

i3:

```text
assign [class="Firefox"] 2
assign [class="dolphin"] 4
for_window [class="mpv"] floating disable
```

Here (`hypr/hyprland.lua`):

```lua
-- assign: move the window and stay here. focus: move it and switch to that workspace.
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end

assign("([Ff]irefox|org\\.mozilla\\.firefox)", 2, true)   -- go there with it
assign("(dolphin|org\\.kde\\.dolphin)", 4, false)          -- send it, stay here

o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })
```

- i3's `assign` never followed the window; here you choose with the third argument (`" silent"` = stay).
- `for_window` becomes `o.window(class, { rules })`.
- The class is a regex. Wayland apps often use a reverse-DNS class (`org.kde.dolphin`), so match both forms. Find it with `hyprctl activewindow` (the `xprop` of Hyprland).

The full list: [Hyprland Core](Hyprland-Core#app--workspace-assign).

## Splits, tabs and stacking

Hyprland's own layouts (dwindle, master, scrolling) do not have i3's container tree. hy3 adds it back. The binds in `bindings.lua`:

| i3 | Key here | hy3 call |
|----|----------|----------|
| `split h` | Super+H | `hy3.make_group("h")` |
| `split v` | Super+V | `hy3.make_group("v")` |
| `layout toggle tabbed split` | Super+W | `hy3.change_group("toggletab")` |
| `layout toggle split` | Super+E | `hy3.change_group("opposite")` |
| `focus parent` | Super+A | `hy3.change_focus("raise")` |
| `layout stacking` | — | hy3 has only h, v and tab groups |

One addition you did not have in i3: [Look and Feel](Look-and-Feel) makes the **second** window on a workspace turn the container into tabs automatically, and puts a lone window back to a plain split. With three or more windows it leaves your choice alone.

hy3 is loaded a moment after login, not at startup (loading it early deadlocks NVIDIA on this laptop). Until then the layout is `dwindle` and the hy3 keys are not bound. See [Autostart](Autostart).

## Focus and move

| i3 | Key here |
|----|----------|
| `focus left/down/up/right` | Super+arrows (`hy3.move_focus`) |
| `move left/down/up/right` | Super+Shift+arrows (`hy3.move_window`) |
| `kill` | Super+Q, or End |
| `move container to workspace N` (and follow) | Super+Shift+N |
| `move container to workspace next` | Super+Ctrl+Right (and follow) |
| `focus_follows_mouse yes` | `follow_mouse = 1` in `input.lua` |

Omarchy's dwindle focus/swap keys on the arrows are unbound and replaced. The numpad and side mouse buttons are bound too, the way the old i3 config had them; see [Keybindings](Keybindings).

## Floating

| i3 | Here |
|----|------|
| `floating toggle` | Super+Z (also Omarchy's Super+T) |
| `for_window [class="X"] floating enable` | `o.window("X", { float = true })` |
| `floating_modifier $mod` | Super+left-drag moves (Omarchy). Super+right-click **closes** the window here, so there is no mouse resize |
| `sticky toggle` | Omarchy's Super+O "Pop window out" floats and pins a window |

## Scratchpad and the Quake terminal

i3's scratchpad is Hyprland's **special workspace**: a hidden workspace that slides over the current one.

- Omarchy's Super+Alt+S sends a window to `special:scratchpad`.
- Omarchy's Super+S showed it, but here **Super+S is the screenshot key**, so `bindings.lua` puts the toggle on **Super+Shift+Alt+S** (your i3 `scratchpad show`):

```lua
o.bind("SUPER + SHIFT + ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
```

For the classic "terminal on the scratchpad" setup you do not need a special workspace at all. **TildaZ** is a dedicated dropdown terminal: **F1** shows and hides it, and the Favorites key, KP Delete and mouse forward run `tildaz --toggle` too. Its size, dock edge, font and opacity live in `~/.config/tildaz/config_0.toml`. It is a layer surface, so it is styled with a layer rule, not a window rule. See [Dropdown Terminal](Dropdown-Terminal).

## Gaps and borders

| i3 / i3-gaps | Here (`looknfeel.lua` unless noted) |
|--------------|-------------------------------------|
| `gaps inner 8` | `gaps_in = 8` |
| `gaps outer 3` | `gaps_out = 3` |
| `smart_gaps on` | `hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })` and the same for `f[1]`, in `hyprland.lua` |
| `default_border pixel 5` | `border_size = 5` |
| `hide_edge_borders smart` | Not set; borders stay with one window |
| `client.focused` … colours | `general.col.active_border` / `inactive_border`, set by the Omarchy theme (`~/.local/state/omarchy/current/theme/hyprland.lua`). Change theme with `omarchy theme set <name>` |
| Title bars | hy3's tab strip (thin, frosted, red outline on the active tab) |

`w[tv1]` matches a workspace with exactly one tiled, visible window; `f[1]` matches a workspace with a maximized window.

Do not use Omarchy's Super+Shift+Backspace for smart gaps. It is a *global* toggle that zeroes gaps and borders on every workspace.

## i3bar and i3status

i3bar + i3status (or i3blocks) become the **Omarchy bar**, part of Omarchy's Quickshell shell. You do not write a status script; you arrange widgets.

| i3 | Here |
|----|------|
| `bar { position bottom }` | `"position": "bottom"` in `~/.config/omarchy/shell.json`, or `omarchy bar position bottom` |
| Block order in i3status | `bar.layout.left` / `center` / `right` lists in `shell.json`, or `omarchy bar move <id> --section right` |
| An i3blocks script | A `"type": "command"` widget with `exec` and `interval` (this repo's `hw-stats` block: temperatures, clocks, load, RAM, swap) |
| Editing i3bar's source | `omarchy plugin clone <id>` copies a built-in widget into `~/.config/omarchy/plugins/` for you to change |
| `bar { mode hide }` | Super+M hides the bar; touching the bottom edge peeks it |

This repo uses two clones: `mahmoud.bar` (from `omarchy.bar`) and `mahmoud.workspaces` (from `omarchy.workspaces`, the one that reads your workspace names). Restart the shell after changes with `omarchy restart shell`. See [Status Bar](Status-Bar), [Plugins](Plugins) and [Hardware Stats](Hardware-Stats).

## Resize mode

i3:

```text
mode "resize" {
  bindsym Left resize shrink width 10 px
  …
  bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"
```

**This setup has no resize mode.** `bindings.lua` defines none, and Super+R is not a resize key here (Super+Shift+R reloads). What you have instead are Omarchy's resize keys that are still bound:

| Key | Action |
|-----|--------|
| Super+Alt+Minus / Super+Alt+Equal | Resize width a little (25 px) |
| Super+Shift+Alt+Minus / Equal | Resize height a little |
| Super+Ctrl+Minus / Super+Ctrl+Equal | Resize width a lot (300 px) |
| Super+Ctrl+Shift+Minus / Equal | Resize height a lot |

Omarchy's plain Super+Minus / Super+Equal resize keys are unbound because those keys are workspaces 11 and 12 here, and Super+right-drag resize is replaced by "close window".

Hyprland does support i3-style modes; it calls them **submaps** (the Lua API has `hl.define_submap`, see `/usr/share/hypr/stubs/hl.meta.lua` and the [Hyprland wiki](https://wiki.hypr.land/)). If you want your resize mode back, that is the place to start.

## Checking your work

```bash
hyprctl reload && hyprctl configerrors    # config OK?
hyprctl binds | grep -A3 "Label"          # is my bind there?
hyprctl activewindow                      # class for assign / o.window
hyprctl clients                           # every window and its workspace
hyprctl layers                            # bar, wallpaper, TildaZ (while shown)
hyprctl getoption general:layout          # hy3 once loaded
hyprctl plugin list                       # hy3 loaded?
```

## Where next

| Goal | Page |
|------|------|
| Learn Hyprland's basics | [Learn Hyprland](Learn-Hyprland) |
| Learn Omarchy's layer (`o.*`, the CLI) | [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) |
| Rebuild this setup step by step | [Build This Rice](Build-This-Rice) |
| Rules that save you from breakage | [Golden Rules](Golden-Rules) |
| Something broke | [Troubleshooting](Troubleshooting) |
