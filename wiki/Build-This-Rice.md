# Build this rice step by step

From a **stock Omarchy** install to this i3-flavoured desktop: hy3 containers, i3 keys, named workspaces, app assigns, smart gaps, TildaZ dropdown, bottom bar. Do the steps **in order**; each one assumes the previous one works.

**Prereq:** Omarchy OS, *or* Arch with the [Arch Linux](Arch-Linux) stack installed. If you only want a copy-paste install, use [Installation](Installation). This page is for **learning by building**. Coming from i3? Keep [Coming from i3](Coming-from-i3) open next to it.

Every file you touch is under `~/.config/`. Never edit `/usr/share/omarchy/`.

After every Lua edit:

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

---

## Step 0: Install the apps your keys will launch

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave-bin firefox \
  viewnior gwenview grim wl-clipboard jq wev
```

`wev` shows key names and codes; you will need it for `code:NN` binds.

---

## Step 1: Install and enable hy3

hy3 (by outfoxxed) gives Hyprland i3's tree: containers, splits, tabs.

```bash
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3
hyprpm update
hyprpm reload
```

Check:

```bash
hyprpm list                                 # hy3 enabled
hyprctl plugin list                         # "Plugin hy3 by outfoxxed"
hyprctl repl 'return hl.plugin.hy3 ~= nil'  # true
```

The built plugin lives at `/var/cache/hyprpm/$USER/hy3/hy3.so`.

---

## Step 2: Load hy3 late (autostart)

**NVIDIA rule:** loading hy3 while the compositor is still starting can deadlock the renderer. So `hyprland.lua` never loads it. `~/.config/hypr/autostart.lua` does, once Hyprland is up:

```lua
o.exec_on_start("hyprpm reload && hyprctl reload")
```

`exec_on_start` runs at login only. The `hyprctl reload` re-reads your config with hy3 present, which is when the hy3 layout and binds apply. Until then you are on dwindle. See [Autostart](Autostart) and [Golden Rules](Golden-Rules).

---

## Step 3: hy3 layout, gaps, blur, glass tabs

Edit `~/.config/hypr/looknfeel.lua`. Always guard the layout name, because naming `hy3` before the plugin is loaded also deadlocks NVIDIA:

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

-- Omarchy turns blur off. hy3 tab glass and the translucent bar need it.
hl.config({ decoration = { blur = { enabled = true, size = 8, passes = 2 } } })
```

Then, inside `if hl.plugin.hy3 ~= nil then … end`, set `plugin.hy3.tabs.*` (height 22, padding 0, blur, translucent colours) and `tab_first_window = false`. Copy the block from the repo's `hypr/looknfeel.lua`. Full explanation: [Look and Feel](Look-and-Feel).

Check:

```bash
hyprctl getoption general:layout           # hy3 (after the autostart reload)
hyprctl getoption decoration:blur:enabled  # 1
```

---

## Step 4: Auto tabs (the i3 "second window becomes a tab" feel)

Still in the hy3 block of `looknfeel.lua`, listeners on `window.open`, `window.close` and `window.move_to_workspace` count tiled windows on the workspace:

| Tiled windows | What it does |
|---------------|--------------|
| 0–1 | `hy3.change_group("h")`: plain split, no tab bar |
| exactly 2 | `hy3.change_group("tab")`: tabs |
| 3 or more | Nothing. Your manual split/tab choice survives |

When a window opens on another workspace, the code hops there to change the group, with cursor warps switched off for the hop, then hops back. Keep that save/restore block or your pointer jumps around.

---

## Step 5: Stop saved layouts from overriding hy3

Omarchy's `Super+L` cycles a workspace between dwindle, scrolling and hy3, and saves the choice under:

```text
~/.local/state/omarchy/workspace-layouts/
```

Those saved rules win over `general.layout`. So, in `hyprland.lua`, **after** `require("default.hypr.toggles")`, force workspaces 1–12:

```lua
local workspace_layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"
if hl.plugin.hy3 == nil then
  hl.config({ general = { layout = "dwindle" } })
end
for id = 1, 12 do
  hl.workspace_rule({ workspace = tostring(id), layout = workspace_layout })
end
```

And unbind `SUPER + L` in `bindings.lua` (Step 6) so no new saves get written.

Check every workspace says `hy3`:

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

---

## Step 6: Keybindings (unbind Omarchy, then i3-style)

In `~/.config/hypr/bindings.lua`:

1. `pcall(hl.unbind, key)` for every Omarchy key you reuse. A second `o.bind` does not replace the first.
2. `o.bind(key, "Label", action)` using hy3's Lua API (`hl.plugin.hy3`), not strings like `"hyprctl dispatch hy3:…"`.
3. Put anything that must work on cold start (hot corners, bar hide/peek, Super+M) **above** this line, because the hy3 binds below it only load after the autostart reload:
   ```lua
   local hy3 = hl.plugin.hy3
   if hy3 == nil then
     return
   end
   ```

The core of the keymap:

| Key | Action | API |
|-----|--------|-----|
| Super+Arrows | Focus | `hy3.move_focus("l"/"d"/"u"/"r")` |
| Super+Shift+Arrows | Move | `hy3.move_window(...)` |
| Super+H / Super+V | Split horizontal / vertical | `hy3.make_group("h")` / `("v")` |
| Super+W | Toggle tabbed / split | `hy3.change_group("toggletab")` |
| Super+E | Toggle split direction | `hy3.change_group("opposite")` |
| Super+A | Focus parent | `hy3.change_focus("raise")` |
| Super+Q, End | Kill | `hy3.kill_active()` |
| Super+Z | Float | `hl.dsp.window.float({ action = "toggle" })` |
| Super+1…12, Super+Shift+1…12 | Go to / move to workspace | `code:(N + 9)`, `hy3.move_to_workspace(...)` |
| Super+D | Omarchy menu (was Super+Space) | `"omarchy-menu toggle"` |

Letter keys are bound by keycode (`SUPER + code:24` = Q) so they keep working under the Arabic layout. Full map: [Keybindings](Keybindings) · [Keybinding Cheatsheet](Keybinding-Cheatsheet).

Find a key's code:

```bash
wev    # press the key, read "keycode"
```

Check a bind loaded:

```bash
hyprctl binds | grep -A3 'Focus left'
```

`modmask: 64` = Super · `65` = Super+Shift · `8` = Alt.

---

## Step 7: Workspaces: names, smart gaps, app assigns

All in `hyprland.lua`.

**Smart gaps** (i3 `smart_gaps on`). One tiled or one fullscreen window gets no gaps:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

Do **not** use `Super+Shift+Backspace` for this. That is Omarchy's global no-gaps toggle; it removes gaps and borders everywhere.

**Names** (i3 `set $ws1 "1: "`). One table, `workspace_names`, then a loop that sets `default_name` and renames existing workspaces. This table is the only place names live; the bar reads it (Step 10).

**Assigns** (i3 `assign [class="..."]`):

```lua
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end

assign("(Brave-browser|brave-browser)", 2, true)   -- move and follow
assign("(dolphin|org\\.kde\\.dolphin)", 4, false)  -- move, stay here
```

Plus two app fixes: mpv drops Omarchy's floating tag and tiles; Viewnior gets `no_initial_focus` so the pointer is not warped.

Learn a window's class:

```bash
hyprctl activewindow | grep -E 'class|title'
```

Guide: [Hyprland Core](Hyprland-Core).

---

## Step 8: Dropdown terminal (TildaZ)

[TildaZ](https://github.com/ensky0/tildaz) by ensky0 is a Quake-style terminal. It is a Wayland **layer surface** (namespace `tildaz`), not a window, so window rules do not apply to it.

1. Install (user-local, no sudo):
   ```bash
   curl -LsSf https://tildaz.dev/install.sh | sh
   ```
2. Config: copy the repo's `tildaz/config_0.toml` to `~/.config/tildaz/config_0.toml`. It sets `hotkey = "F1"`, docked top, 95% wide, 50% high, 90% opacity. Keep an F-key: a letter hotkey stops working while the Arabic layout is active.
3. Autostart: `tildaz --desktop add`. It writes `~/.config/hypr/tildaz.lua`, which the last line of `hyprland.lua` loads:
   ```lua
   pcall(require, "tildaz")
   ```
4. Look, in `looknfeel.lua`:
   ```lua
   hl.layer_rule({
     match = { namespace = "tildaz" },
     blur = true,
     ignore_alpha = 0.1,
     animation = "slide top",
   })
   ```
5. Extra toggle keys, in `bindings.lua`:
   ```lua
   o.bind("XF86Favorites", "Dropdown terminal", { launch = "tildaz --toggle" })
   o.bind("code:91", "Dropdown terminal", { launch = "tildaz --toggle" }) -- KP Delete
   o.bind("mouse:276", "Dropdown terminal", { launch = "tildaz --toggle" })
   ```

Check: press F1, then `hyprctl layers | grep tildaz` while it is shown. More: [Dropdown Terminal](Dropdown-Terminal).

---

## Step 9: Monitors and input (per machine)

```bash
hyprctl monitors all
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
```

This rice's `input.lua`: `kb_layout = "us,ara"`, `kb_options = "grp:win_space_toggle"` (Win+Space switches), `kb_variant = "intl"` left commented out. See [Monitors and Input](Monitors-and-Input). Optional per-window layout: [Per-window Keyboard](Per-Window-Keyboard).

---

## Step 10: Status bar and Omarchy shell

1. Clone the stock widgets you want to change. Clones live in `~/.config/omarchy/plugins/` and survive updates:
   ```bash
   omarchy plugin clone omarchy.bar          # → mahmoud.bar in this repo
   omarchy plugin clone omarchy.workspaces   # → mahmoud.workspaces
   omarchy plugin clone omarchy.network      # → mahmoud.network
   ```
   A clone is named `$USER.<name>` and Omarchy switches to it right away, which is why this repo's copies are `mahmoud.*`. If your user is not `mahmoud` and you install the repo's copies, keep the `mahmoud.*` ids in `shell.json` as they are.
2. `~/.config/omarchy/shell.json`: `"position": "bottom"`, `"id": "mahmoud.bar"`, and `mahmoud.workspaces` / `mahmoud.network` in the layout in place of the stock ids.
3. The workspaces widget shows 1–7 always (`alwaysShown: 7` in `Workspaces.qml`) and 8–12 only while they exist. Labels come from `workspace_names` in `hyprland.lua`; current is highlighted, empty is dimmed.
4. Custom modules: [Hardware Stats](Hardware-Stats), [Wallpaper Widget](Wallpaper-Widget).
5. Glass: `themed/shell.toml.tpl` sets `background-alpha = 0.55`; `looknfeel.lua` adds the bar layer rule:
   ```lua
   hl.layer_rule({
     match = { namespace = "omarchy-bar" },
     blur = true,
     ignore_alpha = false,
     no_anim = false,
     animation = "none",
   })
   ```

```bash
omarchy restart shell
```

[Status Bar](Status-Bar) · [Plugins](Plugins) · [Themes and Fonts](Themes-and-Fonts)

---

## Step 11: Screenshots, night light, portal, Conky

- Super+S fullscreen (`omarchy-capture-screenshot fullscreen`) · Super+Shift+S focused window (`~/.config/hypr/scripts/screenshot-focused`) → [Screenshots](Screenshots)
- `hyprsunset.conf`, `xdph.conf` → [Night Light and Portal](Night-Light-and-Portal)
- Conky: `autostart.lua` runs `~/.config/conky/start-lcc.sh` at login → [Conky](Conky)

---

## Step 12: Acceptance checks

Log out and back in, then:

```bash
hyprctl configerrors           # nothing
hyprctl plugin list            # hy3
hyprctl getoption general:layout   # hy3
```

On one workspace:

- One window: no gaps, no tab bar.
- Open a second: it becomes tabs. Super+W switches to a split, gaps appear.
- Super+Arrows focus · Super+Shift+Arrows move · Super+Q kill.
- Super+Return opens Konsole. F1 drops TildaZ down.
- The bar shows named workspaces 1–7 at the bottom.

If a key does nothing:

1. `hyprctl configerrors`
2. `hyprctl repl 'return hl.plugin.hy3 ~= nil'`
3. `hyprctl binds`: is your label there?
4. Is the workspace layout still `hy3` (Step 5)?
5. Did you forget to `unbind`, so Omarchy still owns the key?

---

## Fast path: copy the finished files

Once hy3 works, `./install.sh` copies everything; then retune only `monitors.lua` and `input.lua`. Or copy selectively:

```text
~/.config/hypr/{hyprland,looknfeel,bindings,autostart}.lua
~/.config/tildaz/config_0.toml
~/.config/omarchy/shell.json   # plus plugins/ and bar/ as needed
```

Long-form original narrative: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
