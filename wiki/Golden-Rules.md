# Golden Rules

Read this before changing anything. Most “it broke after I edited X” issues come from skipping these.

Learning path: [Learn Hyprland](Learn-Hyprland) → [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) → [Build This Rice](Build-This-Rice).

## 1. Edit user config only

| Do | Don’t |
|----|--------|
| Edit `~/.config/hypr/…` | Edit `/usr/share/omarchy/…` |
| Edit `~/.config/omarchy/…` | Patch package files in place |
| Clone plugins with `omarchy plugin clone` | Expect package updates to keep hand-edits in first-party plugins |

Omarchy package updates **overwrite** `/usr/share/omarchy/`. Your rice lives under `~/.config/` so it survives upgrades.

## 2. Reload and check errors

After **any** Hyprland Lua change:

```bash
hyprctl reload
hyprctl configerrors
```

`configerrors` must print **nothing**. A printed line is the bug — fix that line; do not ignore it.

Hyprland may auto-reload on save; still run both commands so you see failures.

## 3. Unbind before rebind

Omarchy binds many Super keys first. A second `o.bind` on the same chord **does not replace** the first.

```lua
local function unbind(key)
  pcall(hl.unbind, key)
end

unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })
```

Use `o.bind(..., "Label", …)` so the binding appears in Omarchy’s cheatsheet (`omarchy menu keybindings --print`).

## 4. hy3 loads late (especially on NVIDIA)

This rice **does not** force-load hy3 during cold start in `hyprland.lua`. On some NVIDIA setups that deadlocks the renderer and the login times out.

Flow:

1. Cold start uses **dwindle** briefly  
2. `autostart.lua` runs `hyprpm reload && hyprctl reload`  
3. After reload, hy3 layout + hy3 binds apply  

Do **not** add early `hl.plugin.load` of hy3 in `hyprland.lua` unless you know your GPU is fine with it. See [Autostart](Autostart) and [Look and Feel](Look-and-Feel).

## 5. Bar config is not deeply merged

`~/.config/omarchy/shell.json` is canonical once you customize. Omarchy does **not** deep-merge your layout with defaults. Reorder/add/remove widgets carefully; keep a backup.

Force shell restart:

```bash
omarchy restart shell
```

## 6. Per-machine files

Always retune after install:

- `~/.config/hypr/monitors.lua` — panels, scale, refresh  
- `~/.config/hypr/input.lua` — layouts, touchpad  

Do not copy another laptop’s `monitors.lua` blindly.

## 7. Backups from the installer

`./install.sh` copies replaced files to:

```text
~/.config/omarchy-dotfiles-backup-YYYYMMDD-HHMMSS/
```

Restore from there if an install went wrong.

## 8. Prefer CLI helpers when they exist

```bash
omarchy bar position bottom
omarchy bar move omarchy.clock --section right
omarchy plugin list
omarchy theme list
omarchy menu keybindings --print
```

Editing JSON/QML by hand is fine for custom modules; for stock widgets, CLI + `shell.json` is usually enough.
