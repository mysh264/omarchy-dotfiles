# Per-window keyboard layout

Hyprland's `kb_layout` is **global**. Switch to Arabic in one window and every window is in Arabic, unless a helper puts the right layout back each time focus changes. (i3 users did this with `xkb-switch` or `kbdd`.)

This setup uses [hypr-kblayoutd](https://github.com/kengzzzz/hypr-kblayoutd).

## Base layouts (still required)

`~/.config/hypr/input.lua` (repo: `hypr/input.lua`):

```lua
kb_layout = "us,ara",
kb_options = "grp:win_space_toggle",  -- Win+Space
-- kb_variant = "intl",               -- uncomment for US-International
```

## Install and enable

```bash
# AUR package. On Omarchy:
omarchy pkg aur add hypr-kblayoutd-bin
# or: yay -S hypr-kblayoutd-bin

# Under uwsm, use the systemd user unit (do not also start it from autostart.lua)
systemctl --user enable --now hypr-kblayoutd.service
```

## Config

`~/.config/hypr-kblayoutd/config.toml` (not in this repo). Layout indexes follow the `kb_layout` order: `us` = 0, `ara` = 1.

```toml
# Keep the Omarchy menu on English so app search stays on Latin keys.
[layer_layouts]
"omarchy-menu" = 0
```

`[layer_layouts]` is keyed by layer-surface namespace (`hyprctl layers` shows them). You can also set `[default_layouts]` per window class. New windows start on layout 0 unless listed.

## Expected behaviour

1. Focus a terminal → Win+Space → Arabic
2. Focus the browser → English (or whatever it last had)
3. Back to the terminal → Arabic again
4. A new window starts on layout 0

## Check it worked

```bash
systemctl --user status hypr-kblayoutd.service
hyprctl devices | grep -A6 Keyboards   # "active keymap" changes as you switch windows
```

Pitfalls:

- Layout does not follow focus → the service is not running, or it was started twice (unit **and** an autostart line). Keep only the unit.
- Indexes look wrong → they follow the order in `kb_layout`. Change that order and update the config.
- The dropdown terminal's global hotkey can stop working while Arabic is active if it is a letter. Keep it an F-key ([Dropdown Terminal](Dropdown-Terminal#keep-the-hotkey-on-an-f-key)).
