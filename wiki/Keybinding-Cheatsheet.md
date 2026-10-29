# Keybinding Cheatsheet

Everything `hypr/bindings.lua` binds, plus the Omarchy defaults you will still reach for. Super = the Windows key. Explanations and code: [Keybindings](Keybindings).

Live list on your machine: **Super+K**, or `hyprctl binds`.

## Menu & apps

| Shortcut | Action |
|----------|--------|
| Super+D | Omarchy menu |
| Super+Return | Konsole |
| Super+Shift+Return | Kitty |
| Super+J | Brave |
| Super+Shift+J | Firefox |
| Super+N | Dolphin |

## Dropdown terminal (TildaZ)

| Shortcut | Action |
|----------|--------|
| F1 | Show / hide TildaZ (its own hotkey, from `config_0.toml`) |
| XF86Favorites / KP Delete / Mouse forward | `tildaz --toggle` |

## Close

| Shortcut | Action |
|----------|--------|
| Super+Q | Kill active (hy3) |
| End | Kill active (hy3) |
| Super+right-click | Close the window under the pointer |
| Super+X | Close all mpv windows |
| Super+Shift+X | Kill Viewnior and Gwenview |
| Alt+X | Kill Dolphin |

## Focus & move (hy3)

| Shortcut | Action |
|----------|--------|
| Super+Arrows | Focus |
| Super+Shift+Arrows | Move window / container |
| KP 1 / KP 3 | Focus left / right |
| KP 7 / KP 9 | Move left / right |

## Layout (hy3)

| Shortcut | Action |
|----------|--------|
| Super+H | Split horizontal |
| Super+V | Split vertical |
| Super+W | Toggle tabbed ↔ split |
| Super+E | Toggle split direction |
| Super+A | Focus parent |
| Super+Z | Toggle floating |

## Workspaces

| Shortcut | Action |
|----------|--------|
| Super+1 … Super+0 | Workspace 1–10 |
| Super+Minus / Super+Equal | Workspace 11 / 12 |
| Super+Shift+(1…0, Minus, Equal) | Move window to that workspace and follow |
| Super+` | Previous workspace |
| Alt+Space | Workspace 10 |
| Super+Ctrl+Left / Right | Move window to previous / next workspace and follow |
| Mouse back | Previous workspace |
| KP 4 / KP 6 | Previous / next workspace |
| KP 0 / KP 5 | Previous workspace |
| KP 8 / KP 2 | First / last existing workspace |
| Shift+KP 1…9, Shift+KP 0 | Workspace 1–9, 10 |

## Screenshots & bar

| Shortcut | Action |
|----------|--------|
| Super+S | Fullscreen screenshot |
| Super+Shift+S | Focused window screenshot |
| Super+M | Hide / show the bar (bottom edge peeks it) |
| Top-left hot corner | Same as Super+M |
| Top-right hot corner | Workspace 97 |
| Bottom-right hot corner | Previous workspace |

## Reload

| Shortcut | Action |
|----------|--------|
| Super+Shift+C | `hyprctl reload` |
| Super+Shift+R | `hyprctl reload` |

## Swallowed keys

These do nothing, so they never type into apps: Num Lock, KP Enter, Home, Page Up, Page Down. (End closes the window, see above.)

## Keyboard layout (from `input.lua`)

| Shortcut | Action |
|----------|--------|
| Win+Space | Switch `us` ↔ `ara` |

## Omarchy defaults that still work

| Shortcut | Action |
|----------|--------|
| Super+K | Keybindings menu |
| Super+Escape | System menu |
| Super+F | Full screen |
| Super+T | Toggle floating |
| Super+C | Universal copy |
| Super+Tab / Super+Shift+Tab | Next / previous workspace |
| Super+Shift+Alt+1…0 | Move window to workspace silently |
| Super+Alt+S | Move window to the scratchpad (Omarchy default) |
| Super+Shift+Alt+S | Show / hide the scratchpad (i3 `scratchpad show`) |
| Super+Alt / Super+Ctrl + Minus/Equal | Resize a little / a lot (add Shift for vertical) |
| Super+left-drag | Move window |
| Super+Shift+Backspace | Global no-gaps toggle (not smart gaps) |
| Super+Ctrl+N | Night light |
| Super+Shift+M | Music |
| Print | Screenshot picker |

## Omarchy defaults removed here

Super+Return, Super+Shift+Return, Super+W, Super+J, Super+S, Super+Shift+S, Super+V, Super+X, Super+Shift+C, Super+Shift+X, Super+Arrows, Super+Shift+Arrows, Super+Ctrl+Left/Right, Super+L (layout toggle, fights hy3), Super+Space (menu moved to Super+D), Super+Minus/Equal and Super+Shift+Minus/Equal (resize), Super+right-drag (resize), Super+1…0 and Super+Shift+1…0. Full table with the old actions: [Keybindings](Keybindings#omarchy-defaults-this-file-removes).
