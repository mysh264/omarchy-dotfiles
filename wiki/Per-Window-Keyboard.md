# Per-window keyboard layout

Hyprland’s `kb_layout` is **global**. Switching to Arabic in one window switches everywhere unless a helper restores layout on focus change.

This rice uses [hypr-kblayoutd](https://github.com/kengzzzz/hypr-kblayoutd).

## Base layouts (still required)

`~/.config/hypr/input.lua`:

```lua
kb_layout = "us,ara",
kb_options = "grp:win_space_toggle",  -- Win+Space
-- kb_variant = "intl",   -- uncomment for US-International
```

## Install & enable

```bash
# AUR — on Omarchy you can use:
# omarchy pkg aur add hypr-kblayoutd-bin
yay -S hypr-kblayoutd-bin

# Under uwsm: user unit only (do not also exec-once)
systemctl --user enable --now hypr-kblayoutd.service
systemctl --user status hypr-kblayoutd.service
```

## Optional config

`~/.config/hypr-kblayoutd/config.toml` — layout indexes follow `kb_layout` order (`us` = 0, `ara` = 1):

```toml
[layer_layouts]
"omarchy-menu" = 0
```

That keeps the Omarchy menu on English. You can set `[default_layouts]` per window class if desired.

## Expected behavior

1. Focus terminal → Win+Space → Arabic  
2. Focus browser → English (or its last layout)  
3. Focus terminal again → Arabic returns  
4. New windows default to layout `0` unless configured otherwise  
