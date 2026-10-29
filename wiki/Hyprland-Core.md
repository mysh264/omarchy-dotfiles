# Hyprland Core (`hyprland.lua`)

**Repo:** `hypr/hyprland.lua`  
**Live:** `~/.config/hypr/hyprland.lua`

This is the entry file. Omarchy’s bootstrap + defaults load first; your modules load after so package updates can improve defaults without wiping your rice.

## Load order (do not reorder lightly)

```lua
dofile(OMARCHY_PATH .. "/default/hypr/bootstrap.lua")
require("default.hypr.omarchy")

require("hypr.monitors")
require("hypr.input")
require("hypr.looknfeel")
require("hypr.bindings")
require("hypr.autostart")

require("default.hypr.toggles")

-- then: force hy3 workspace layouts, names, window rules…
```

Optional flags (commented in the file):

- `omarchy_default_bindings = false` — strip all Omarchy binds; you own everything  
- `omarchy_preinstalled_bindings = false` — drop only preinstalled-app binds  

## Why hy3 is not loaded here

Loading hy3 while the NVIDIA renderer is still starting can **deadlock** Hyprland (login timeout). This tree loads hy3 from [Autostart](Autostart) (`hyprpm reload && hyprctl reload`).

On cold start, if `hl.plugin.hy3` is nil, workspaces temporarily use **dwindle**. After autostart reload they switch to **hy3**.

## Force hy3 on every workspace

Omarchy’s Super+L layout toggle saves per-workspace layouts under:

```text
~/.local/state/omarchy/workspace-layouts/
```

Those can put workspaces back on scrolling/dwindle so hy3 focus/move/close look “dead”. This file re-applies hy3 (or dwindle if plugin not up yet) for workspaces 1–12 **after** `require("default.hypr.toggles")`.

`Super+L` is unbound in [Keybindings](Keybindings) so new bad saves are not written.

## Smart gaps

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })  -- one tiled window
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })    -- fullscreen
```

## Workspace names (icons)

Edit the `workspace_names` table (workspaces 1–12). Examples shipped:

| # | Label idea |
|---|------------|
| 1 | Terminal |
| 2 | Browser |
| 3 | Editor |
| 4 | Files |
| 5 | Video |
| 6 | Images |
| 7 | Media centers |
| 8 | Torrents |
| 9 | Mail |
| 10 | Docs |
| 11 | System monitor |
| 12 | Settings |

Existing workspaces keep old names until renamed; empty ones pick up `default_name`. The loop after the table renames existing workspaces on every reload, so a save applies everywhere.

The bar widget `mahmoud.workspaces` reads this same table from the file, so changing an icon here changes it on the bar too, for empty and occupied workspaces alike. Keep the table's shape (one `"N: icon"` string per line, closing `}` at the start of a line). See [Plugins](Plugins).

Icons are Nerd Font glyphs. Copy them from [nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet).

## App → workspace assignments

Helper:

```lua
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end
```

- `focus = true` — move window **and** switch to that workspace  
- `focus = false` — move silently; you stay where you are  

**Terminals are not assigned** — they open on the current workspace.

Shipped examples (edit to match your apps):

| Pattern | Workspace | Focus? |
|---------|-----------|--------|
| Brave / Firefox | 2 | yes |
| Dolphin | 4 | no |
| Kate | 3 | yes |
| mpv / Haruna | 5 | no |
| Viewnior / Gwenview | 6 | no |
| Stremio / Kodi / Jellyfin | 7 | varies |
| qBittorrent | 8 | yes |
| Thunderbird | 9 | yes |
| Typora | 10 | yes |
| Plasma System Monitor | 11 | yes |
| System settings / disks / Flatseal / … | 12 | yes |

Class patterns are Lua/PCRE-style regex strings as accepted by Omarchy’s `o.window`.

## Special window rules

### mpv tiled (not Omarchy’s floating pin)

Omarchy tags mpv as a floating 875×600 window. This rice strips that and tiles:

```lua
o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })
```

### Viewnior — don’t steal the cursor

```lua
o.window("(Viewnior|viewnior)", { no_initial_focus = true, focus_on_activate = false })
```

Opening an image leaves the pointer where it was; clicking still focuses.

### Dropdown Kitty (`special:dropdown`)

```lua
o.window({ class = "^dropdown\\.terminal$" }, {
  workspace = "special:dropdown silent",
  float = true,
  move = { 0, 0 },
  size = { "monitor_w", "monitor_h * 0.4" },
  opacity = "0.95 0.95",
})
```

**Class must stay `dropdown.terminal`** so it does not match normal Kitty (`Super+Shift+Return`). Autostart + binds launch with `--class dropdown.terminal`.

## How to edit safely

1. Change names / `assign()` lines / rules  
2. `hyprctl reload && hyprctl configerrors`  
3. Open a test app and confirm workspace + focus behavior  

Deep rebuild notes: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
