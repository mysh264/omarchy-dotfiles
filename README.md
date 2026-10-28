# Omarchy Dotfiles — i3-style Hyprland + custom bar

> Portable **user** configs for [Omarchy](https://omarchy.org): hy3 (i3 containers & tabs), a remapped keymap, bottom status bar with hardware stats, dual-stack-friendly network widget, dropdown Kitty, Conky autostart, and screenshot binds that feel familiar.

[![Omarchy](https://img.shields.io/badge/Omarchy-4.x-black.svg)](https://github.com/omacom/omarchy)
[![Hyprland](https://img.shields.io/badge/Hyprland-Lua-blue.svg)](https://wiki.hypr.land/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Use this to clone the same desktop onto another Omarchy laptop — or steal the pieces you like.

> **Credit — Omarchy**  
> This repository is **not** Omarchy. It is a personal / shared layer of configs that sit on top of it.  
> **Omarchy** is created by **[David Heinemeier Hansson](https://dhh.dk/)** and the **Omarchy / Omacom** team.  
> Upstream: **[github.com/omacom/omarchy](https://github.com/omacom/omarchy)** · Site: **[omarchy.org](https://omarchy.org)**  
> Always prefer Omarchy’s own docs and `omarchy` CLI for system features. Never edit `/usr/share/omarchy/` — updates overwrite it.

Also thanks to:

- [outfoxxed/hy3](https://github.com/outfoxxed/hy3) — i3-style layout plugin for Hyprland  
- [jxai/lean-conky-config](https://github.com/jxai/lean-conky-config) / [mysh264/lean-conky-config](https://github.com/mysh264/lean-conky-config) — optional desktop panel  
- [Hyprland](https://hypr.land/) and the Quickshell ecosystem that powers Omarchy’s shell

---

## What you get

| Area | What changed |
|------|----------------|
| **Layout** | [hy3](https://github.com/outfoxxed/hy3) splits + tabs (i3 feel), delayed load so NVIDIA cold-start does not deadlock |
| **Keys** | i3-ish focus/move/split/tab binds; Omarchy menu on `SUPER+D`; screenshots on `SUPER+S` / `SUPER+SHIFT+S` |
| **Bar** | Bottom bar (`mahmoud.bar`), hardware stats, wallpaper control, cloned network panel |
| **Autostart** | hy3 reload, Lean Conky, dropdown Kitty (`special:dropdown`) |
| **Input** | `us,ara` layouts, `Win+Space` to toggle, `intl` variant |
| **Windows** | Named workspaces + app → workspace assignments (Brave, Dolphin, mpv, …) |

Deep step-by-step for the Hyprland / hy3 half lives in **[docs/hypr-i3-setup.md](docs/hypr-i3-setup.md)**.

---

## Quick install (another Omarchy laptop)

### 0. Prerequisites

1. Fresh **[Omarchy](https://omarchy.org)** install (or an existing one you’re okay customizing).
2. Packages this keymap expects (adjust to taste):

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox \
  viewnior gwenview
# optional: voice dictation, Conky later via --with-conky
```

### 1. Clone & install

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
chmod +x install.sh
./install.sh                 # backs up existing files, copies configs, enables hy3
# ./install.sh --with-conky  # also clones Wayland Lean Conky Config
# ./install.sh --dry-run     # preview only
```

`install.sh` only writes under `~/.config/`. Anything it replaces is copied to  
`~/.config/omarchy-dotfiles-backup-YYYYMMDD-HHMMSS/`.

### 2. Adapt this machine

```bash
$EDITOR ~/.config/hypr/monitors.lua   # your panel / scale / refresh
$EDITOR ~/.config/hypr/input.lua      # keyboard layouts & touchpad
hyprctl reload && hyprctl configerrors
omarchy restart shell
```

Monitors and keyboards differ per laptop — do not blindly reuse another machine’s `monitors.lua`.

### 3. Optional extras

```bash
# Per-window keyboard language (if you use it)
# yay -S hypr-kblayoutd-bin
# systemctl --user enable --now hypr-kblayoutd.service

# Lean Conky (Wayland) — or use ./install.sh --with-conky
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
~/.config/conky/start-lcc.sh -n
```

---

## Repo layout

```text
omarchy-dotfiles/
├── hypr/                 → ~/.config/hypr/
│   ├── hyprland.lua      # loads Omarchy defaults + your modules
│   ├── bindings.lua      # keymap, hot corners, bar peek, screenshots
│   ├── looknfeel.lua     # gaps, blur, hy3 tab glass
│   ├── autostart.lua     # hy3 reload, Conky, dropdown Kitty
│   ├── input.lua         # keyboard / pointer
│   ├── monitors.lua      # displays (edit per laptop)
│   └── scripts/          # focused-window screenshot helper
├── omarchy/              → ~/.config/omarchy/
│   ├── shell.json        # bar layout, idle lock timings
│   ├── shell.toml        # shell font size
│   ├── plugins/          # mahmoud.bar, mahmoud.network (cloned)
│   ├── bar/              # hw-stats script + wallpaper QML module
│   ├── themed/           # shell.toml.tpl override
│   └── extensions/       # omarchy-menu.jsonc
├── alacritty/            → ~/.config/alacritty/ (font size 11)
├── docs/hypr-i3-setup.md # long-form hy3 + keymap guide
├── install.sh
└── LICENSE
```

---

## How to edit each feature

Omarchy rule of thumb: **edit `~/.config/…` only**. After Hyprland Lua edits:

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

Bar / `shell.json` usually hot-reloads on save; force with `omarchy restart shell`.

### Keybindings

**File:** `hypr/bindings.lua` → `~/.config/hypr/bindings.lua`

1. Check what Omarchy already bound: `omarchy menu keybindings --print`
2. Always `hl.unbind("SUPER + …")` (or the helper `unbind`) **before** rebinding a key Omarchy owns
3. Prefer `o.bind("SUPER + X", "Label", …)` so the binding shows up in Omarchy’s cheatsheet

Useful binds in this tree:

| Shortcut | Action |
|----------|--------|
| `SUPER+Return` | Konsole |
| `SUPER+Shift+Return` | Kitty |
| `SUPER+D` | Omarchy menu |
| `SUPER+S` | Fullscreen screenshot |
| `SUPER+Shift+S` | Focused-window screenshot |
| `SUPER+M` | Toggle / peek status bar |
| `SUPER+H / V / W / E` | hy3 split / tab / opposite |
| `SUPER+Arrows` | Focus (hy3) |
| `SUPER+Shift+Arrows` | Move window (hy3) |
| Favorites / KP Delete / mouse back | Dropdown Kitty |

Screenshots: fullscreen uses Omarchy’s capture helper; focused window uses `hypr/scripts/screenshot-focused`.

### Layout, gaps, hy3 tab look

**File:** `hypr/looknfeel.lua`

- `general.gaps_in` / `gaps_out` / `border_size` / `layout`
- `decoration.blur` — needed for frosted hy3 tabs and bar glass
- `plugin.hy3.tabs.*` — height, padding, colors (active red outline)

NVIDIA note: do **not** force-load hy3 inside `hyprland.lua` on cold start on affected GPUs. This setup loads via `autostart.lua` (`hyprpm reload && hyprctl reload`). Details in `docs/hypr-i3-setup.md`.

### Window rules & workspace names

**File:** `hypr/hyprland.lua`

- `workspace_names` — icons/labels for workspaces 1–12  
- `assign("class-regex", workspace, focus?)` — sticky app → workspace rules  
- Special cases: tiled `mpv`, Viewnior without cursor warp, dropdown terminal opacity  

### Autostart

**File:** `hypr/autostart.lua`

```lua
o.exec_on_start("hyprpm reload && hyprctl reload")
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")
o.launch_on_start("kitty --class dropdown.terminal")
```

Remove the Conky line if you do not use it. Dropdown class must stay `dropdown.terminal` to match the window rule in `hyprland.lua`.

### Monitors

**File:** `hypr/monitors.lua`

```bash
hyprctl monitors all
```

Then set `output`, `mode`, `position`, `scale` for each panel. Leave commented examples as a template.

### Keyboard & touchpad

**File:** `hypr/input.lua`

Current defaults: `kb_layout = "us,ara"`, toggle with `Win+Space` (`grp:win_space_toggle`), variant `intl`. Uncomment the touchpad / sensitivity blocks as needed.

### Status bar layout

**File:** `omarchy/shell.json` → `~/.config/omarchy/shell.json`

- `bar.position` — `bottom` / `top` / …  
- `bar.layout.left|center|right` — widget ids in order  
- `bar.id` — `mahmoud.bar` (cloned bar plugin)  
- `idle.lock` / `idle.screensaver` — seconds  

CLI helpers:

```bash
omarchy bar position bottom
omarchy bar move omarchy.clock --section right
omarchy plugin list
```

### Hardware stats widget

**Files:** `omarchy/bar/scripts/hw-stats` + entry in `shell.json`

JSON text for the bar: CPU °C / MHz / %, GPU (NVIDIA via `nvidia-smi`, or “sleep”), load, RAM, swap. Click opens `btop`. Edit the Python script to change formatting; keep `interval` in `shell.json`.

### Wallpaper control on the bar

**File:** `omarchy/bar/modules/wallpaper.qml`  
Wired as `{ "id": "wallpaper", "type": "qml" }` in `shell.json`. Change icons / actions inside the QML module; shell rescans plugins on save.

### Network panel (cloned)

**Dir:** `omarchy/plugins/mahmoud.network/`  
Cloned from Omarchy’s network widget via `omarchy plugin clone`. Safe to edit; package updates will not overwrite it. Re-clone if you want to start from a newer upstream:

```bash
omarchy plugin clone omarchy.network
# then point shell.json at the new id, or keep mahmoud.network
```

### Cloned bar engine

**Dir:** `omarchy/plugins/mahmoud.bar/`  
Same idea — local fork of the first-party bar. Prefer changing `shell.json` for layout; only edit QML when you need widget behavior Omarchy does not expose.

### Shell font / theme template

- `omarchy/shell.toml` — e.g. `[font] base-size = 14`  
- `omarchy/themed/shell.toml.tpl` — template override applied when themes regenerate shell chrome  

Theme commands stay Omarchy’s:

```bash
omarchy theme list
omarchy theme current
omarchy theme set "Catppuccin"
omarchy theme bg next
```

### Terminal font

**File:** `alacritty/alacritty.toml` — font `size = 11` (stock is often `9`). Other terminals (`foot`, `kitty`, `ghostty`) are theme-managed; tweak via Omarchy theme / their own configs if needed.

### Default agent

**File:** `omarchy/defaults/agent` — currently `cursor-agent`. Change to whatever `omarchy-default-agent` accepts on your build, or delete to get Omarchy’s setup invitation again.

### Night light / portal

- `hypr/hyprsunset.conf` — blue light filter; apply with `omarchy restart hyprsunset`  
- `hypr/xdph.conf` — XDG desktop portal / screencast tokens; applies after portal restart / next login  

---

## Updating later

On the laptop that “owns” the rice:

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
# copy fresh configs back into the repo, then:
git add -A && git commit -m "Sync from laptop" && git push
```

On the other laptop:

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh
```

After an Omarchy or Hyprland upgrade, rebuild hy3:

```bash
hyprpm update && hyprpm reload
hyprctl plugin list
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Login hangs / black screen on NVIDIA | Keep hy3 **out** of cold-start `hyprland.lua`; use autostart reload (as shipped) |
| hy3 binds do nothing | `hyprpm list` → enabled? `hyprctl plugin list` → loaded? Reload after enable |
| Bar missing widgets | `omarchy restart shell`; confirm `shell.json` ids match plugin manifests |
| Screenshots fail | `grim`, `wl-clipboard`, and `jq` installed; focused script needs an active window |
| Conky missing | Install [lean-conky-config](https://github.com/mysh264/lean-conky-config) or `./install.sh --with-conky` |
| `configerrors` noise | Fix the printed Lua line; do not ignore it |

---

## Credits & license

- **Omarchy** — © David Heinemeier Hansson and contributors · [omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org) · MIT  
- **hy3** — [outfoxxed/hy3](https://github.com/outfoxxed/hy3)  
- **This dotfiles repo** — MIT (see [LICENSE](LICENSE)). Configs are provided as-is for learning and reuse.

If you publish a fork, please keep the Omarchy credit block above so newcomers find the real project first.
