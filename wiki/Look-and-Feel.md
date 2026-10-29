# Look and Feel (`looknfeel.lua`)

**Repo:** `hypr/looknfeel.lua`  
**Live:** `~/.config/hypr/looknfeel.lua`

i3-style visuals on top of hy3: gaps, blur, frosted tab strip, and automatic tab/split switching.

## Gaps & layout

```lua
general = {
  gaps_in = 8,
  gaps_out = 3,
  border_size = 0,
  layout = "hy3",   -- or dwindle if plugin not loaded yet
}
```

Edit `gaps_in` / `gaps_out` / `border_size` to taste. `layout` becomes `hy3` only when the plugin is present (see NVIDIA note in [Golden Rules](Golden-Rules)).

### No gaps for a single window

In `hypr/hyprland.lua`:

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })
```

A workspace with one visible tiled window (a hy3 tab group counts as one) or one fullscreen window gets no gaps. Split windows keep `gaps_in` / `gaps_out`.

**Do not press `Super+Shift+Backspace` for this.** That is Omarchy's global "Toggle window gaps". It writes `~/.local/state/omarchy/toggles/hypr/window-no-gaps.lua`, which is loaded after your files by `require("default.hypr.toggles")`. It sets gaps **and** `border_size` to 0 for every window, so split windows touch. Turn it off with the same keys or `omarchy-hyprland-window-gaps-toggle`.

Also enabled: `workspace_back_and_forth = true` (pressing the key for the current workspace goes back).

## Blur (required for glass)

Omarchy turns blur **off**. hy3 tab glass and the translucent bar need it **on**:

```lua
decoration.blur = { enabled = true, size = 8, passes = 2 }
```

Bar layer blur:

```lua
hl.layer_rule({
  match = { namespace = "omarchy-bar" },
  blur = true,
  ignore_alpha = true,
  no_anim = true,
  animation = "none",
})
```

## hy3 tab strip (frosted glass)

Only applied when `hl.plugin.hy3 ~= nil`.

| Setting | Shipped | Effect |
|---------|---------|--------|
| `tab_first_window` | `false` | Single window → no tab bar |
| `group_inset` | `0` | No extra inset |
| `tabs.height` | `22` | Strip height |
| `tabs.padding` | `0` | Flush to window (no nested box) |
| `tabs.text_height` | `8` | Small i3-like labels |
| `tabs.text_font` | JetBrainsMono Nerd Font | Title font |
| `tabs.blur` | `true` | Glass |
| `tabs.colors.active_border` | strong red `#ff2020` | Active outline |
| `tabs.colors.active_text` | soft white (same as inactive) | Titles match; border marks active |
| `autotile.enable` | `false` | Manual tiling |

**Active tab cue:** red border only — not a different text color. Change `active_border` / `active_alt_monitor_border` to recolor.

For solid larger tabs: raise `text_height`/`height`, set `blur = false`, use opaque colors.

Verify:

```bash
hyprctl getoption general:layout
hyprctl getoption plugin:hy3:tab_first_window
hyprctl getoption plugin:hy3:tabs:padding
hyprctl getoption decoration:blur:enabled
```

Expect: `hy3`, `false`, `0`, `true` (after hy3 is loaded).

## Auto titlebar behavior

Listeners on `window.open` / `window.close` / `window.move_to_workspace`:

- **≤1 tiled window** → `change_group("h")` (no title bar)  
- **≥2 tiled windows** → `change_group("tab")`  

`hy3:changegroup` only affects the **focused** workspace. When a window opens on another workspace (e.g. mpv → 5), the helper briefly focuses that workspace, runs the change, then returns — with cursor warps disabled for the hop so the pointer doesn’t jump.

Floating / special workspaces are skipped.

To disable auto tabs: remove or comment the `hl.on(...)` block at the bottom of the file.

## After edits

```bash
hyprctl reload && hyprctl configerrors
```
