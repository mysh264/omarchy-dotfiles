# Golden Rules

Read this before changing anything. Most "it broke after I edited X" issues come from skipping one of these.

Learning path: [Coming from i3](Coming-from-i3) → [Learn Hyprland](Learn-Hyprland) → [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) → [Build This Rice](Build-This-Rice).

## 1. Never edit `/usr/share/omarchy/`

| Do | Don't |
|----|-------|
| Edit `~/.config/hypr/…` | Edit `/usr/share/omarchy/…` (`$OMARCHY_PATH`) |
| Edit `~/.config/omarchy/…` | Patch package files in place |
| Copy a built-in widget with `omarchy plugin clone <id>` and edit the copy | Hand-edit a first-party plugin and expect it to survive an update |

Omarchy (by DHH / Omacom) loads its defaults first, then your files in `~/.config/hypr/`. Package updates **overwrite** `/usr/share/omarchy/`; your `~/.config/` survives. Read the package files as a reference, override them from `~/.config/`.

In i3 you had one `~/.config/i3/config` and owned all of it. Here Omarchy owns the defaults and you own a thin layer on top.

## 2. Reload, then check `configerrors`

After **any** Hyprland Lua change:

```bash
hyprctl reload
hyprctl configerrors
```

`configerrors` must print **nothing**. A printed line is the bug: fix that line, do not ignore it. Hyprland may auto-reload on save; still run both so you see failures.

Bar / `shell.json` / plugin changes need `omarchy restart shell` instead.

## 3. Unbind before you rebind

Omarchy binds many Super keys first. A second `o.bind` on the same chord **does not replace** the first, so remove Omarchy's bind before adding yours.

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end

unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })
```

Give every bind a label (`"Terminal"`) so it shows in Omarchy's keybinding menu (`omarchy menu keybindings`). Check what actually loaded with `hyprctl binds`.

## 4. hy3 loads late (the NVIDIA rule)

This rice **does not** load hy3 from `hyprland.lua`. On this NVIDIA laptop, loading it (or even naming the `hy3` layout) while the renderer is still starting deadlocks Hyprland, and the login times out.

The flow instead:

1. Cold start uses **dwindle** (`hyprland.lua` and `looknfeel.lua` pick `dwindle` while `hl.plugin.hy3 == nil`).
2. `autostart.lua` runs `hyprpm reload && hyprctl reload` once the compositor is up.
3. On that reload hy3 is present, so the hy3 layout, the hy3 binds and the auto-tab logic apply.

Do **not** add an early `hl.plugin.load` of hy3, or set `layout = "hy3"` unconditionally. Keep the `hl.plugin.hy3 ~= nil and "hy3" or "dwindle"` guard. See [Autostart](Autostart) and [Look and Feel](Look-and-Feel).

## 5. Don't press Super+Shift+Backspace expecting smart gaps

`Super+Shift+Backspace` is Omarchy's **global** no-gaps toggle. It writes `~/.local/state/omarchy/toggles/hypr/window-no-gaps.lua`, which zeroes gaps **and borders** on every workspace, split windows included.

This rice already has i3-style `smart_gaps` in `hyprland.lua`:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

One tiled (or one fullscreen) window: no gaps. Two or more: `gaps_in = 8`, `gaps_out = 3`, `border_size = 5` from `looknfeel.lua`. If your splits suddenly have no gaps or borders, the toggle is on: press the key again, or delete the file and reload.

## 6. Workspace names live only in `hyprland.lua`

The `workspace_names` table in `~/.config/hypr/hyprland.lua` is the **one** place to name workspaces. The bar widget `mahmoud.workspaces` reads that table straight from the file and watches it for changes. Do not add a second name list to `Workspaces.qml` or `shell.json`; it would drift.

## 7. TildaZ is a layer, not a window

The dropdown terminal ([TildaZ](https://github.com/ensky0/tildaz)) is a Wayland **layer surface** with namespace `tildaz`. Window rules (`o.window`, `hl.window_rule`) never reach it. Style it with `hl.layer_rule({ match = { namespace = "tildaz" }, … })` and check it with `hyprctl layers` while it is shown.

Keep its hotkey an **F-key**. Hyprland matches the hotkey by the character typed, so a letter hotkey stops working while the Arabic layout is active. See [Dropdown Terminal](Dropdown-Terminal).

## 8. Bar config is not deep-merged

`~/.config/omarchy/shell.json` is canonical once you customize it. Omarchy does **not** merge your layout with its defaults. Reorder, add or remove widgets carefully and keep a backup. Prefer the CLI for stock widgets:

```bash
omarchy bar position bottom
omarchy bar move omarchy.clock --section center --index 0
omarchy plugin list
omarchy restart shell
```

## 9. Per-machine files

Always retune after install:

- `~/.config/hypr/monitors.lua`: panels, scale, refresh
- `~/.config/hypr/input.lua`: layouts, touchpad

Never copy `~/.config/hypr/tildaz.lua` between machines; run `tildaz --desktop add` on each one.

## 10. Backups from the installer

`./install.sh` copies every file it replaces to:

```text
~/.config/omarchy-dotfiles-backup-YYYYMMDD-HHMMSS/
```

Restore from there if an install went wrong.
