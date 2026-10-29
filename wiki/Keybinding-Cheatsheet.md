# Keybinding Cheatsheet

Defaults from `hypr/bindings.lua`. Mod = Super (Windows key) unless noted.

## Launch & menu

| Shortcut | Action |
|----------|--------|
| Super+Return | Konsole |
| Super+Shift+Return | Kitty |
| Super+D | Omarchy menu |
| Super+J | Brave |
| Super+Shift+J | Firefox |
| Super+N | Dolphin |
| XF86Favorites / KP Delete / Mouse forward | Dropdown terminal (TildaZ, `tildaz --toggle`) |
| Mouse back | Previous workspace |

## Close

| Shortcut | Action |
|----------|--------|
| Super+Q / End | Kill active (hy3) |
| Super+right-click | Close window |
| Super+X | Kill mpv |
| Super+Shift+X | Kill image viewers |
| Alt+X | Kill Dolphin |

## Focus & move (hy3)

| Shortcut | Action |
|----------|--------|
| Super+Arrows | Focus |
| Super+Shift+Arrows | Move window/container |
| KP_1 / KP_3 | Focus left / right |
| KP_7 / KP_9 | Move left / right |

## Layout (hy3)

| Shortcut | Action |
|----------|--------|
| Super+H | Split horizontal |
| Super+V | Split vertical |
| Super+W | Toggle tabbed ↔ split |
| Super+E | Toggle split direction |
| Super+Z | Toggle float |
| Super+A | Focus parent |

## Workspaces

| Shortcut | Action |
|----------|--------|
| Super+1 … Super+0 | Workspace 1–10 |
| Super+code for 11–12 | Workspaces 11–12 |
| Super+Shift+N | Move focused to workspace N (follow) |
| Super+` | Previous workspace |
| Super+Ctrl+Left/Right | Move window to prev/next WS (follow) |
| Alt+Space | Workspace 10 |
| KP_4 / KP_6 | Prev / next workspace |
| KP_0 / KP_5 | Previous workspace |
| KP_8 / KP_2 | First / last workspace |
| Shift+KP_1…0 | Jump to workspace 1–10 |

## Screenshots & bar

| Shortcut | Action |
|----------|--------|
| Super+S | Fullscreen screenshot |
| Super+Shift+S | Focused window screenshot |
| Super+M | Hide / show status bar |
| Top-left hot corner | Same as Super+M |
| Top-right hot corner | Workspace 97 |
| Bottom-right hot corner | Previous workspace |

## Reload

| Shortcut | Action |
|----------|--------|
| Super+Shift+C | `hyprctl reload` |
| Super+Shift+R | `hyprctl reload` |

## Input (from `input.lua`, not bindings)

| Shortcut | Action |
|----------|--------|
| Win+Space | Toggle keyboard layout (`us` ↔ `ara`) |

## Intentionally unbound Omarchy defaults

These are cleared so this rice can own them (partial list): Super+Return, Super+arrows, Super+S / Shift+S, Super+Space (menu moved to Super+D), Super+L (layout toggle — fights hy3), workspace number row, and others listed in the unbind loop in `bindings.lua`.
