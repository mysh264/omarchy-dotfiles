# Keybindings (`bindings.lua`)

**Repo:** `hypr/bindings.lua`  
**Live:** `~/.config/hypr/bindings.lua`

This is the i3 keymap, moved onto Omarchy. Omarchy's own binds load first (from `/usr/share/omarchy/default/hypr/bindings/`). This file runs after them: it removes the Omarchy binds that use the same keys, then adds the i3 ones. The window commands come from [hy3](https://github.com/outfoxxed/hy3) (by outfoxxed), so focus, move and close act on **containers**, the way they do in i3.

In i3 you wrote `bindsym $mod+q kill` in `~/.config/i3/config`. Here it is:

```lua
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
```

Printable list: [Keybinding Cheatsheet](Keybinding-Cheatsheet). Coming from i3? See [Coming from i3](Coming-from-i3).

## Before you change a key

1. See what is bound right now: press **Super+K** (Omarchy's keybindings menu), or run `hyprctl binds`.
2. Look up the Omarchy default you are replacing: `grep -rn '"SUPER + X"' /usr/share/omarchy/default/hypr/bindings/` (read only, never edit it).
3. Unbind it **before** your `o.bind`. Hyprland runs every bind that matches a key, so a second bind on the same key does not replace the first one. Both fire.
4. Use `o.bind(key, "Label", action)`. The label is what Super+K shows.

The file has a small helper that ignores "not bound" errors:

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end
```

## How the file is laid out

The order matters, because the file stops halfway when hy3 is not loaded yet.

| Part | Runs without hy3? | What it does |
|------|-------------------|--------------|
| Hot corners | yes | Three screen corners run actions |
| Bar hide + peek | yes | `Super+M` hides the bar; the bottom edge peeks it |
| `if hy3 == nil then return end` | — | On a cold start hy3 is not loaded yet, so the file stops here |
| Unbind loop | no | Removes the Omarchy binds listed below |
| Everything else | no | Apps, close, focus/move, screenshots, layout, workspaces, numpad, reload |

hy3 is loaded by [Autostart](Autostart) a moment after login (`hyprpm reload && hyprctl reload`). That reload runs this file again with hy3 present, and the second half applies. If the i3 keys do nothing right after login, see [Troubleshooting](Troubleshooting).

## Hot corners

Tunables at the top of the file:

| Variable | Value | Meaning |
|----------|-------|---------|
| `corner_size` | `8` | The pointer must be within this many px of the corner to fire |
| `corner_release` | `48` | It must move this far away before the same corner can fire again |

| Corner | Action |
|--------|--------|
| Top-left | Hide / show the bar (same as Super+M) |
| Top-right | Go to workspace `97` |
| Bottom-right | Previous workspace |

A 50 ms timer checks the pointer on the monitor under the cursor. Change `run_corner()` to remap the corners.

## Bar hide and edge peek

| Variable | Value | Meaning |
|----------|-------|---------|
| `bar_flag` | `~/.local/state/omarchy/toggles/bar-off` | Flag file that keeps the bar hidden across reloads |
| `bar_edge` | `4` | px from the bottom edge that start a peek |
| `bar_hover` | `36` | Height counted as "on the bar" while peeking |
| `bar_linger_ms` | `400` | Delay before the bar hides again after you leave it |

- **Super+M** latches the bar hidden or shown (writes or removes the flag, then `omarchy-shell -q omarchy.bar syncHidden`).
- While it is hidden, touching the bottom edge shows it as an overlay (`setOverlay yes`). Leaving it hides it again after 400 ms.
- The bar sits on the bottom edge (`"position": "bottom"` in `omarchy/shell.json`). If you move it, change `pointer_on_bottom_edge()` too.
- Super+Shift+M stays Omarchy's Music. Super+Shift+Space (Omarchy's "Toggle top bar") is still bound too.

## Omarchy defaults this file removes

Every key in the unbind loop, with what Omarchy had there:

| Key | Omarchy default | Here it becomes |
|-----|-----------------|-----------------|
| Super+Return | Terminal | Konsole |
| Super+Shift+Return | Browser | Kitty |
| Super+W | Close window | Toggle tabbed / split |
| Super+J | Toggle window split | Brave |
| Super+S | Toggle scratchpad | Fullscreen screenshot |
| Super+Shift+S | Google Maps web app | Focused-window screenshot |
| Super+V | Universal paste | Split vertical |
| Super+X | Universal cut | Kill mpv |
| Super+Shift+C | Calendar web app | Reload |
| Super+Shift+X | X web app | Kill image viewers |
| Super+Left/Right/Up/Down | Focus (dwindle) | hy3 focus |
| Super+Shift+arrows | Swap window | hy3 move |
| Super+Ctrl+Left/Right | Focus inside a Hyprland group | Move window to previous / next workspace |
| Super+L | Toggle workspace layout (dwindle / scrolling / hy3) | nothing (it fights hy3) |
| Super+Space | Omarchy menu | nothing (menu moved to **Super+D**; Win+Space switches keyboard layout, see [Monitors and Input](Monitors-and-Input)) |
| Super+Minus / Super+Equal | Resize window | Workspace 11 / 12 |
| Super+Shift+Minus / Super+Shift+Equal | Resize window | Move to workspace 11 / 12 |
| Super+right-click drag | Resize window with the mouse | Close the window under the click |
| Super+1…0, Super+Shift+1…0 | Workspace / move window (not hy3) | Same jobs, with hy3 moves |
| mouse:275 / mouse:276 | (cleared before rebinding) | Previous workspace / dropdown terminal |

Super+M is also unbound before it gets "Hide bar". Omarchy does not use it.

### Omarchy defaults that are still active

Everything not in the table keeps working. The ones you are most likely to use:

| Key | Action |
|-----|--------|
| Super+K | Keybindings menu (searchable list of every bind) |
| Super+Escape | System menu |
| Super+F | Full screen |
| Super+T | Toggle floating (same as Super+Z here) |
| Super+C | Universal copy |
| Super+Tab / Super+Shift+Tab | Next / previous workspace |
| Super+Ctrl+Tab | Former workspace |
| Super+Shift+Alt+1…0 | Move window to workspace N silently (you stay) |
| Super+Alt+S | Move window to the scratchpad |
| Super+Alt+Minus/Equal (+Shift) | Resize a little (25 px) |
| Super+Ctrl+Minus/Equal (+Shift) | Resize a lot (300 px) |
| Super+left-drag | Move a window with the mouse |
| Super+G | Hyprland window group (not a hy3 tab group) |
| Super+Backspace | Toggle window transparency |
| Super+Shift+Backspace | Omarchy's **global** no-gaps toggle (see [Look and Feel](Look-and-Feel)) |
| Super+Ctrl+N | Toggle night light |
| Print | Screenshot (Omarchy's picker) |
| Ctrl+Alt+Delete | Close all windows |

**Scratchpad:** Omarchy's Super+Alt+S still sends a window to `special:scratchpad`. Omarchy's key to show it (Super+S) is the screenshot key here, so `bindings.lua` moves the toggle to **Super+Shift+Alt+S**:

```lua
o.bind("SUPER + SHIFT + ALT + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
```

## The i3 binds

### Menu and apps

| Key | Action | Code |
|-----|--------|------|
| Super+D | Omarchy menu | `"omarchy-menu toggle"` |
| Super+Return | Konsole | `{ launch = "konsole" }` |
| Super+Shift+Return | Kitty | `{ launch = "kitty" }` |
| Super+J | Brave | `code:44` |
| Super+Shift+J | Firefox | `code:44` |
| Super+N | Dolphin | `code:57` |

`{ launch = "app" }` runs the app through `uwsm-app --`, the way Omarchy starts GUI apps. Change the string to use another app.

### Dropdown terminal (TildaZ)

| Key | Action |
|-----|--------|
| F1 | TildaZ's own global hotkey (set in `~/.config/tildaz/config_0.toml`, not in this file) |
| XF86Favorites | `tildaz --toggle` |
| KP Delete (`code:91`) | `tildaz --toggle` |
| Mouse forward (`mouse:276`) | `tildaz --toggle` |

Details: [Dropdown Terminal](Dropdown-Terminal).

### Close

| Key | Action |
|-----|--------|
| Super+Q (`code:24`) | `hy3.kill_active()` |
| End (`code:115`) | `hy3.kill_active()` — **End never reaches apps** |
| Super+right-click | Close the window under the click (`{ mouse = true }`) |
| Super+X (`code:53`) | Close every window whose class contains `mpv` |
| Super+Shift+X | `killall viewnior ; killall gwenview` |
| Alt+X | `killall dolphin` |

### Focus and move (hy3)

| Key | Action |
|-----|--------|
| Super+Left/Down/Up/Right | `hy3.move_focus("l"/"d"/"u"/"r")` |
| Super+Shift+Left/Down/Up/Right | `hy3.move_window(...)` |
| KP 1 / KP 3 (`code:87` / `code:89`) | Focus left / right |
| KP 7 / KP 9 (`code:79` / `code:81`) | Move left / right |

Use the Lua plugin functions (`hl.plugin.hy3.*`). Do not use string dispatchers such as `hyprctl dispatch hy3:movefocus`.

### Layout (hy3)

| Key | Action | i3 |
|-----|--------|----|
| Super+H (`code:43`) | `hy3.make_group("h")` | `split h` |
| Super+V (`code:55`) | `hy3.make_group("v")` | `split v` |
| Super+W (`code:25`) | `hy3.change_group("toggletab")` | `layout toggle tabbed split` |
| Super+E (`code:26`) | `hy3.change_group("opposite")` | `layout toggle split` |
| Super+Z (`code:52`) | Toggle floating | `floating toggle` |
| Super+A (`code:38`) | `hy3.change_focus("raise")` | `focus parent` |

[Look and Feel](Look-and-Feel) also switches containers between split and tabs on its own when the 1st and 2nd window open.

### Screenshots

| Key | Action |
|-----|--------|
| Super+S | `omarchy-capture-screenshot fullscreen` |
| Super+Shift+S | `~/.config/hypr/scripts/screenshot-focused` |

See [Screenshots](Screenshots).

### Workspaces

| Key | Action |
|-----|--------|
| Super+1 … Super+0 | Workspace 1–10 (`code:10`–`code:19`) |
| Super+Minus / Super+Equal | Workspace 11 / 12 (`code:20` / `code:21`) |
| Super+Shift+(any of those) | `hy3.move_to_workspace(N, { follow = true })` — move and follow |
| Super+` (`code:49`) | Previous workspace |
| Alt+Space | Workspace 10 |
| Super+Ctrl+Left / Right | Move window to previous / next workspace (`e-1` / `e+1`) and follow |
| Mouse back (`mouse:275`) | Previous workspace |
| KP 4 / KP 6 (`code:83` / `code:85`) | Previous / next workspace (`e-1` / `e+1`) |
| KP 0 / KP 5 (`code:90` / `code:84`) | Previous workspace |
| KP 8 (`code:80`) | Lowest-numbered existing workspace |
| KP 2 (`code:88`) | Highest-numbered existing workspace |
| Shift+KP 1…9, Shift+KP 0 | Workspace 1–9, 10 |

The loop builds workspace N from `code:(N + 9)`:

```lua
for workspace = 1, 12 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("SUPER + " .. key, "Workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move to workspace " .. workspace, hy3.move_to_workspace(tostring(workspace), { follow = true }))
end
```

`workspace_back_and_forth = true` (in `looknfeel.lua`) means pressing the key of the workspace you are on takes you back, like i3's `workspace_auto_back_and_forth yes`.

### Swallowed keys

These are bound to `hl.dsp.no_op()` so they never type into apps (the old i3 config did the same with `bindcode`):

| Code | Key |
|------|-----|
| 77 | Num Lock |
| 104 | KP Enter |
| 110 | Home |
| 112 | Page Up |
| 117 | Page Down |

Together with End (kill) and the numpad binds above, this means **Home, End, Page Up, Page Down and the numpad do not reach apps**. Remove the code from the `ipairs({ 77, 104, 110, 112, 117 })` list if you need one back.

### Reload

| Key | Action |
|-----|--------|
| Super+Shift+C (`code:54`) | `hyprctl reload` |
| Super+Shift+R (`code:27`) | `hyprctl reload` |

Hyprland has no i3-style in-place restart, so both keys reload. Hyprland also auto-reloads when it sees a config file change (`misc:disable_autoreload` is `false`); the keys are for when you want to be sure.

## Named keys vs keycodes

| Style | Example | Notes |
|-------|---------|-------|
| Named | `SUPER + RETURN` | Matches the key symbol |
| Code | `SUPER + code:24` | Matches the physical key, like i3's `bindcode` |

Most letter binds here use codes, so they stay on the same physical key whatever layout is active.

US codes used in the file: Q=24, W=25, E=26, R=27, A=38, H=43, J=44, grave=49, Z=52, X=53, C=54, V=55, N=57, digits 1–0 = 10–19, Minus=20, Equal=21.

Find any key's code with `wev`:

```bash
sudo pacman -S --needed wev
wev
```

## Mouse binds

For click actions (previous workspace, dropdown) **do not** pass `{ mouse = true }`. That flag is for drag and resize binds; a click command with it never runs. Super+right-click close does use `{ mouse = true }`, the same way Omarchy's right-drag resize bind on that button did.

## Add a bind (recipe)

```lua
unbind("SUPER + B")
o.bind("SUPER + B", "My app", { launch = "my-app" })
```

Put it after the `if hy3 == nil then return end` line if it uses hy3, before it if it must work on a cold start.

Check it:

```bash
hyprctl reload && hyprctl configerrors   # empty output = OK
hyprctl binds | grep -A3 "My app"
```

## i3 → this file

| i3 | Here |
| --- | --- |
| `focus left` | `hy3.move_focus("l")` |
| `move left` | `hy3.move_window("l")` |
| `split h` / `split v` | `hy3.make_group("h")` / `hy3.make_group("v")` |
| `layout toggle tabbed split` | `hy3.change_group("toggletab")` |
| `layout toggle split` | `hy3.change_group("opposite")` |
| `focus parent` | `hy3.change_focus("raise")` |
| `kill` | `hy3.kill_active()` |
| `floating toggle` | `hl.dsp.window.float({ action = "toggle" })` |
| `workspace N` | `hl.dsp.focus({ workspace = "N" })` |
| `move container to workspace N; workspace N` | `hy3.move_to_workspace("N", { follow = true })` |
| `workspace back_and_forth` | `hl.dsp.focus({ workspace = "previous" })` |
| `reload` / `restart` | `hyprctl reload` |

i3's `layout stacking` has no hy3 equivalent (hy3 groups are h, v or tab). There is no resize mode; see [Coming from i3](Coming-from-i3#resize-mode).

New to Omarchy binds? [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) · rebuild order: [Build This Rice](Build-This-Rice).
