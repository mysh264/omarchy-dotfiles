# Look and Feel (`looknfeel.lua`)

**Repo:** `hypr/looknfeel.lua`  
**Live:** `~/.config/hypr/looknfeel.lua`

The i3 look on top of hy3: gaps and borders, blur, a thin frosted tab strip (i3's title bars), layer rules for the bar and the dropdown terminal, and automatic switching between split and tabs. It loads after Omarchy's own `looknfeel.lua`, so anything set here wins.

## Gaps, borders, layout

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
```

| Setting | Value | i3 equivalent |
|---------|-------|---------------|
| `gaps_in` | `8` | `gaps inner` |
| `gaps_out` | `3` | `gaps outer` |
| `border_size` | `5` | `default_border pixel 5` |
| `layout` | `hy3` once the plugin is loaded, `dwindle` before | — |

The layout is only named `hy3` when the plugin is present. Naming it earlier deadlocks the NVIDIA renderer on this laptop (see [Golden Rules](Golden-Rules) and [Autostart](Autostart)).

### No gaps for a single window

That lives in `hypr/hyprland.lua`, not here:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

A workspace with one visible tiled window (a hy3 tab group counts as one) gets no gaps; so does a workspace with a maximized window (`f[1]`). Split windows keep `gaps_in` / `gaps_out`. This is i3-gaps' `smart_gaps on`. More: [Hyprland Core](Hyprland-Core#smart-gaps-no-gaps-with-one-window).

**Do not press Super+Shift+Backspace for this.** That is Omarchy's global "Toggle window gaps". It writes `~/.local/state/omarchy/toggles/hypr/window-no-gaps.lua`, which `require("default.hypr.toggles")` loads after your files. It sets gaps **and** `border_size` to 0 for every window, so split windows touch. Turn it off with the same keys or `omarchy-hyprland-window-gaps-toggle`.

### Workspace back and forth

```lua
hl.config({ binds = { workspace_back_and_forth = true } })
```

Pressing the key for the workspace you are already on takes you back to the previous one, like i3's `workspace_auto_back_and_forth yes`.

## Blur (needed for the glass)

Omarchy turns blur **off**. The hy3 tab glass, the translucent bar and TildaZ all need it **on**:

```lua
hl.config({
  decoration = {
    blur = { enabled = true, size = 8, passes = 2 },
  },
})
```

## Layer rules

The bar and TildaZ are Wayland **layer surfaces**, not windows. Window rules never reach them; layer rules do. Each rule matches a `namespace`. List the namespaces with `hyprctl layers` (TildaZ only shows while it is open).

### Bar (`omarchy-bar`)

```lua
hl.layer_rule({
  match = { namespace = "omarchy-bar" },
  blur = true,
  ignore_alpha = false,
  no_anim = false,
  animation = "none",
})
```

Blur behind the bar, and `animation = "none"` so it appears and hides without a slide (this includes the bar peek from [Keybindings](Keybindings)).

### Dropdown terminal (`tildaz`)

```lua
hl.layer_rule({
  match = { namespace = "tildaz" },
  blur = true,
  ignore_alpha = 0.1,
  animation = "slide top",
})
```

| Field | Effect |
|-------|--------|
| `blur = true` | Blur what shows through TildaZ's 90% opacity (`opacity_percent` in `~/.config/tildaz/config_0.toml`) |
| `ignore_alpha = 0.1` | Skip blur for almost-transparent pixels |
| `animation = "slide top"` | Slide down from the top edge. `"fade"` fades, `"popin"` grows from the centre, `"slide bottom"` suits `dock_position = "bottom"` |

Size, position and opacity come from TildaZ's config, not from Hyprland. Full page: [Dropdown Terminal](Dropdown-Terminal).

## hy3 tab strip (frosted glass)

Applied only when `hl.plugin.hy3 ~= nil`.

| Setting | Value | Effect |
|---------|-------|--------|
| `tab_first_window` | `false` | A lone window gets no tab bar |
| `group_inset` | `0` | No extra inset for groups |
| `tabs.height` | `22` | Strip height |
| `tabs.padding` | `0` | Flush to the window (no box inside a box) |
| `tabs.radius` | `0` | Square tabs, like i3 |
| `tabs.border_width` | `1` | Tab outline |
| `tabs.render_text` / `text_center` | `true` / `true` | Centred titles |
| `tabs.text_font` | `JetBrainsMono Nerd Font` | Title font |
| `tabs.text_height` / `text_padding` | `8` / `3` | Small i3-like labels |
| `tabs.blur` / `opacity` | `true` / `1.0` | Glass (fills are translucent colours) |
| `tabs.colors.active_border` | `rgba(ff2020ff)` | Strong red outline on the active tab |
| `tabs.colors.*_text` | `rgba(ffffffaa)` | Same soft white on every tab; the border marks the active one |
| `tabs.colors.urgent*` / `locked*` | pink / yellow | Urgent and locked groups |
| `autotile.enable` | `false` | No hy3 autotiling; you choose splits |

To recolour the active tab, change `active_border` and `active_alt_monitor_border`. For solid, larger tabs: raise `height` and `text_height`, set `blur = false`, and use opaque colours.

Check:

```bash
hyprctl getoption general:layout
hyprctl getoption plugin:hy3:tab_first_window
hyprctl getoption plugin:hy3:tabs:padding
hyprctl getoption decoration:blur:enabled
```

Expect `hy3`, `false`, `0`, `true` (once hy3 is loaded).

## Automatic split / tabs

Listeners on `window.open`, `window.close` and `window.move_to_workspace` count the **tiled** windows on the workspace:

| Tiled windows | What happens |
|---------------|--------------|
| 0 or 1 | `hy3.change_group("h")` — plain split, no title bar |
| exactly 2 | `hy3.change_group("tab")` — the container becomes tabs |
| 3 or more | left alone |

So the second window turns the container into tabs, close to i3's `workspace_layout tabbed`, except that a lone window has no title bar. If you then switch it to a split yourself (Super+W, or Super+H / Super+V), a third window keeps your choice instead of snapping back to tabs. On reload, every workspace with 0 or 1 tiled windows is set back to a plain split.

`hy3.change_group` only works on the **focused** workspace. When a window opens on another workspace (mpv → 5, for example), the helper briefly focuses that workspace, makes the change and comes back. Cursor warps are turned off for that hop, so the pointer does not jump.

Floating windows and special workspaces are skipped.

To turn auto tabs off, remove the three `hl.on(...)` blocks (and the loop after them) at the bottom of the file.

## After edits

```bash
hyprctl reload && hyprctl configerrors   # empty output = OK
```

Common pitfalls:

- No glass on tabs or bar → blur is off (`hyprctl getoption decoration:blur:enabled`).
- Tabs never appear → hy3 is not loaded yet (`hyprctl plugin list`), or you set `tab_first_window`/the listeners differently.
- Gaps gone everywhere and borders too → the Omarchy global no-gaps toggle is on (Super+Shift+Backspace again).
