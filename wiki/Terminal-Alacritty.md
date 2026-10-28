# Terminal (Alacritty)

**Repo:** `alacritty/alacritty.toml`  
**Live:** `~/.config/alacritty/alacritty.toml`

This rice only ships a small Alacritty override (mainly font size). Colors come from the active Omarchy theme.

## Contents

| Section | Shipped behavior |
|---------|------------------|
| `general.import` | `~/.local/state/omarchy/current/theme/alacritty.toml` |
| Font family | JetBrainsMono Nerd Font (Regular / Bold / Italic) |
| Font size | **11** (stock Omarchy often uses 9) |
| Window padding | 14×14, decorations none |
| `TERM` | `xterm-256color` |
| OSC 52 | CopyPaste |
| Shift+Insert / Ctrl+Insert | Paste / Copy |
| Shift+Return | CSI-u so TUIs can distinguish from Return |
| Alt+Shift+Return | CSI-u for tmux `M-S-Enter` |

## How to edit

```bash
$EDITOR ~/.config/alacritty/alacritty.toml
# Alacritty live-reloads on save for most settings
```

Change `size = 11` under `[font]` for larger/smaller text. Keep the `general.import` line so Omarchy themes still recolor the terminal.

## Other terminals

Default launch keys use **Konsole** (Super+Return) and **Kitty** (Super+Shift+Return / dropdown). Those configs are not fully vendored here — use Omarchy themes or each app’s `~/.config/` tree.

Dropdown Kitty class must stay `dropdown.terminal` — see [Hyprland Core](Hyprland-Core) and [Autostart](Autostart).
