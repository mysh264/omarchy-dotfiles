# Hyprland Core (`hyprland.lua`)

**Repo:** `hypr/hyprland.lua`  
**Live:** `~/.config/hypr/hyprland.lua`

This is the entry file, the one Hyprland reads first. It loads Omarchy's defaults, then your own files on top, then the i3 parts: named workspaces, app-to-workspace assignments and a few window rules. In i3 this was the top of `~/.config/i3/config` plus all your `workspace`, `assign` and `for_window` lines.

## Load order (do not reorder lightly)

```lua
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")
require("default.hypr.omarchy")   -- all Omarchy defaults

require("hypr.monitors")          -- your files, after the defaults
require("hypr.input")
require("hypr.looknfeel")
require("hypr.bindings")
require("hypr.autostart")

require("default.hypr.toggles")   -- Omarchy toggles + saved per-workspace layouts

-- then: force the hy3 layout, smart gaps, workspace names, assign(), window rules
-- last line: pcall(require, "tildaz")
```

Later settings win. Your files load after Omarchy's, so Omarchy updates can improve the defaults without touching your `~/.config/hypr` files. Never edit `/usr/share/omarchy`.

Optional flags (commented out at the top of the file):

- `omarchy_default_bindings = false` — drop every Omarchy bind; you own all keys
- `omarchy_preinstalled_bindings = false` — drop only the binds for Omarchy's preinstalled apps and web apps

## Why hy3 is not loaded here

Loading hy3 while the NVIDIA renderer is still starting deadlocks Hyprland on this laptop (black screen, login times out). So hy3 is loaded by [Autostart](Autostart) once the compositor is up (`hyprpm reload && hyprctl reload`). Even *naming* the `hy3` layout before the plugin is loaded triggers the deadlock, which is why every file checks `hl.plugin.hy3` first.

On a cold start `hl.plugin.hy3` is `nil`, so the layout is `dwindle`. After the autostart reload it is `hy3`.

## Force the hy3 layout on every workspace

Omarchy's Super+L toggle saves a layout per workspace under `~/.local/state/omarchy/workspace-layouts/`, and `require("default.hypr.toggles")` restores those saves. Saved rules had put workspaces 1, 2, 3 and 7 back on scrolling or dwindle, and there hy3 focus, move and close did nothing. This loop runs **after** that restore and wins:

```lua
local workspace_layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"
if hl.plugin.hy3 == nil then
  hl.config({ general = { layout = "dwindle" } })
end
for id = 1, 12 do
  hl.workspace_rule({ workspace = tostring(id), layout = workspace_layout })
end
```

Super+L is unbound in [Keybindings](Keybindings), so no new saves are written. If you had old saves, you can delete the files in that folder.

Check:

```bash
hyprctl getoption general:layout     # hy3 (after login reload)
hyprctl activeworkspace | grep tiledLayout   # tiledLayout: hy3
```

## Smart gaps (no gaps with one window)

```lua
-- Smart gaps: no gaps when a workspace has one tiled window, or one fullscreen window.
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

| Selector | Matches a workspace with… |
|----------|---------------------------|
| `w[tv1]` | exactly 1 **t**iled, **v**isible window (a hy3 tab group shows one window, so it counts as one) |
| `f[1]` | a **maximized** window (fullscreen state 1, e.g. Omarchy's Super+Alt+F "Full width"). |

This is i3-gaps' `smart_gaps on`. Everywhere else the gaps from [Look and Feel](Look-and-Feel) apply (`gaps_in = 8`, `gaps_out = 3`). Borders stay.

Do **not** use Super+Shift+Backspace for this. That is Omarchy's *global* gaps toggle: it zeroes gaps and borders on every workspace.

## Workspace names (icons)

```lua
local workspace_names = {
  "1:  ",
  "2:  ",
  -- … one string per workspace, up to 12
}

for id, name in ipairs(workspace_names) do
  hl.workspace_rule({ workspace = tostring(id), default_name = name })
  pcall(function()
    hl.dispatch(hl.dsp.workspace.rename({ workspace = tostring(id), name = name }))
  end)
end
```

The icons are Nerd Font glyphs (they may show as blanks in a browser without a Nerd Font). What ships:

| # | Icon | Used for |
|---|------|----------|
| 1 | terminal | Terminals |
| 2 | Chrome logo | Browsers |
| 3 | font | Kate (editor) |
| 4 | open folder | Dolphin |
| 5 | film | mpv, Haruna |
| 6 | picture | Viewnior, Gwenview |
| 7 | desktop | Stremio, Kodi, Jellyfin |
| 8 | magnet | qBittorrent |
| 9 | envelope | Thunderbird |
| 10 | dashboard | Typora |
| 11 | heartbeat | Plasma System Monitor |
| 12 | cog | System settings and admin tools |

`default_name` names a workspace when it is created. A workspace that already exists keeps its old name, so the loop also renames each existing one on every reload. Save the file and every workspace shows the new name.

**The bar reads this same table.** The bar widget `mahmoud.workspaces` (a clone of Omarchy's `omarchy.workspaces`, in `omarchy/plugins/mahmoud.workspaces/`) reads and watches `~/.config/hypr/hyprland.lua`. It always shows workspaces 1–7, shows 8–12 only while they exist, highlights the current one and dims empty ones. Edit names **only here**; the bar follows when you save.

The widget finds the table with a pattern, so keep its shape:

- the table is called `workspace_names`,
- one `"N: icon"` string per line,
- the closing `}` at the start of a line.

Copy glyphs from [nerdfonts.com/cheat-sheet](https://www.nerdfonts.com/cheat-sheet). More on the widget: [Plugins](Plugins) · [Status Bar](Status-Bar).

## App → workspace (`assign()`)

i3's `assign [class="Firefox"] 2` becomes:

```lua
-- assign: move the window and stay here. focus: move it and switch to that workspace.
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end

assign("([Ff]irefox|org\\.mozilla\\.firefox)", 2, true)
```

- `focus = true` — the window goes there **and** you follow it.
- `focus = false` — `" silent"`: the window goes there; you stay where you are.

**Terminals are not assigned.** They open on the workspace you are on.

What ships:

| Pattern | Workspace | Follow? |
|---------|-----------|---------|
| Brave, Firefox | 2 | yes |
| Kate | 3 | yes |
| Dolphin | 4 | no |
| mpv, Haruna | 5 | no |
| Viewnior, Gwenview | 6 | no |
| Stremio, Kodi | 7 | yes |
| Jellyfin Media Player | 7 | no |
| qBittorrent | 8 | yes |
| Thunderbird | 9 | yes |
| Typora | 10 | yes |
| Plasma System Monitor | 11 | yes |
| System Settings, KInfoCenter, firewall-config, GNOME Disks, Partition Manager, GParted, Flatseal, Grub Customizer | 12 | yes |

The class is a regex matched against the window class. In Lua strings a literal dot is written `\\.` (Lua turns it into the regex `\.`). Find a class with:

```bash
hyprctl activewindow | grep class
```

## Other window rules

### mpv tiled, not floating

Omarchy tags mpv as a floating window, pinned at 875×600 and centred. This removes the tag and tiles it:

```lua
o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })
```

### Viewnior does not move the pointer

Viewnior asks for focus as soon as it opens, and Hyprland then warps the pointer to its middle. This rule stops that:

```lua
o.window("(Viewnior|viewnior)", { no_initial_focus = true, focus_on_activate = false })
```

Opening an image leaves the pointer where it was. Clicking the window still focuses it.

## TildaZ loader

The last line loads the file that `tildaz --desktop add` writes:

```lua
pcall(require, "tildaz")
```

TildaZ is a layer surface, not a window, so it has no window rule here. Its look is a layer rule in `looknfeel.lua`. See [Dropdown Terminal](Dropdown-Terminal).

## How to edit safely

1. Change a name, an `assign()` line or a rule.
2. `hyprctl reload && hyprctl configerrors` (empty output = OK).
3. Open the app from another workspace and check where it lands:

```bash
hyprctl clients | grep -E 'class|workspace'
hyprctl workspaces | grep -E '^workspace'
```

Deep rebuild notes: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md) · Coming from i3: [Coming from i3](Coming-from-i3).
