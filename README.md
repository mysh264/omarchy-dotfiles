# Omarchy Dotfiles: i3-style Hyprland

> My [Omarchy](https://omarchy.org) desktop, tuned to feel like the **i3wm** setup I used for years: i3 containers, splits and tabs via [hy3](https://github.com/outfoxxed/hy3), my old i3 keys, named workspaces with icons, apps that land on their own workspace, and a Quake-style dropdown terminal ([TildaZ](https://github.com/ensky0/tildaz)). It runs on Omarchy and on plain Arch.

[![Omarchy](https://img.shields.io/badge/Omarchy-4.x-black.svg)](https://github.com/omacom/omarchy)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-1793D1.svg)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Lua-blue.svg)](https://wiki.hypr.land/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Clone the whole desktop onto another laptop, or take only the pieces you like. Everything is a user override in `~/.config/`, the Omarchy way. Nothing here touches `/usr/share/omarchy/`.

**Full guide: the [wiki](https://github.com/mysh264/omarchy-dotfiles/wiki).** Coming from i3? Start with [Coming from i3](https://github.com/mysh264/omarchy-dotfiles/wiki/Coming-from-i3).

> **Credit: Omarchy**  
> This repository is **not** Omarchy. It is a personal / shared layer of configs that sit on top of it.  
> **Omarchy** is created by **[David Heinemeier Hansson](https://dhh.dk/)** and the **Omarchy / Omacom** team.  
> Upstream: **[github.com/omacom/omarchy](https://github.com/omacom/omarchy)** · Site: **[omarchy.org](https://omarchy.org)**  
> Always prefer Omarchy’s own docs and `omarchy` CLI for system features. Never edit `/usr/share/omarchy/` — updates overwrite it.

---

## Why

i3 got the important things right: windows live in containers you split and tab from the keyboard, every app has its workspace, and the config is one text file you own. Omarchy gets the rest right: a good-looking Hyprland desktop, a real CLI, and a clean place for your own overrides that survives updates.

This repo joins the two. Omarchy stays in charge of the system. The files here make Hyprland behave like i3.

| In i3 you had… | Here it is… |
|----------------|-------------|
| `~/.config/i3/config` | `~/.config/hypr/*.lua`, loaded after Omarchy's defaults |
| `split h` / `split v` / `layout toggle tabbed split` | hy3 on `Super+H` / `Super+V` / `Super+W` |
| `bindsym` / `bindcode` | `o.bind("SUPER + RETURN", …)` / `o.bind("SUPER + code:24", …)` |
| `assign [class="…"] 2` | `assign("class-regex", 2, focus)` in `hyprland.lua` |
| named workspaces like `"1: >_"` | `workspace_names` in `hyprland.lua`, shown on the bar |
| a Quake terminal script | TildaZ on `F1` |
| `reload` | `hyprctl reload && hyprctl configerrors` |

The full mapping is in [Coming from i3](https://github.com/mysh264/omarchy-dotfiles/wiki/Coming-from-i3) and [Keybindings](https://github.com/mysh264/omarchy-dotfiles/wiki/Keybindings).

---

## What you get

| Area | What it does | Wiki |
|------|--------------|------|
| **Layout** | hy3 splits and tabs. One window has no title bar; a second window turns the container into tabs. hy3 loads after login so an NVIDIA cold start does not deadlock | [Hyprland Core](https://github.com/mysh264/omarchy-dotfiles/wiki/Hyprland-Core) |
| **Keys** | i3 focus / move / split / tab keys, Omarchy menu on `Super+D`, numpad workspace keys, hot corners | [Keybindings](https://github.com/mysh264/omarchy-dotfiles/wiki/Keybindings) · [Cheatsheet](https://github.com/mysh264/omarchy-dotfiles/wiki/Keybinding-Cheatsheet) |
| **Workspaces** | 12 named workspaces with icons. Brave/Firefox, Dolphin, mpv, Viewnior and others open on their own workspace | [Hyprland Core](https://github.com/mysh264/omarchy-dotfiles/wiki/Hyprland-Core) |
| **Dropdown terminal** | [TildaZ](https://github.com/ensky0/tildaz) on `F1` (also the Favorites key, KP Delete, mouse forward). Slides in from the top with blur | [Dropdown Terminal](https://github.com/mysh264/omarchy-dotfiles/wiki/Dropdown-Terminal) |
| **Look** | Glass hy3 tabs with a red active outline, blurred bar, no gaps around a lone window | [Look and Feel](https://github.com/mysh264/omarchy-dotfiles/wiki/Look-and-Feel) |
| **Status bar** | Bottom bar (cloned as `mahmoud.bar`) that peeks from the bottom edge while hidden, named-workspace widget, hardware stats, wallpaper control, cloned network panel | [Status Bar](https://github.com/mysh264/omarchy-dotfiles/wiki/Status-Bar) · [Plugins](https://github.com/mysh264/omarchy-dotfiles/wiki/Plugins) |
| **Screenshots** | `Super+S` full screen, `Super+Shift+S` focused window | [Screenshots](https://github.com/mysh264/omarchy-dotfiles/wiki/Screenshots) |
| **Input** | `us` + `ara` layouts, `Win+Space` toggles, optional per-window layout | [Monitors and Input](https://github.com/mysh264/omarchy-dotfiles/wiki/Monitors-and-Input) · [Per-Window Keyboard](https://github.com/mysh264/omarchy-dotfiles/wiki/Per-Window-Keyboard) |
| **Extras** | Lean Conky desktop panel, night light, Alacritty font size, menu extensions | [Conky](https://github.com/mysh264/omarchy-dotfiles/wiki/Conky) · [Autostart](https://github.com/mysh264/omarchy-dotfiles/wiki/Autostart) · [Menu Extensions](https://github.com/mysh264/omarchy-dotfiles/wiki/Menu-Extensions) |

## Screenshots

A dark Catppuccin desktop: a thin blurred bar along the bottom with icon-named workspaces on the left, hy3 tabs as a slim glass strip above each tab group, and a translucent TildaZ terminal that drops down from the top on `F1`. Pictures will follow.

---

## Quick install

`install.sh` writes only under `~/.config/` and `~/.local/` (TildaZ, the wallpaper script), and creates `~/.Wallpapers`. Every file it replaces is first copied to `~/.config/omarchy-dotfiles-backup-YYYYMMDD-HHMMSS/`. Preview everything with `--dry-run`.

### On Omarchy

```bash
# Apps the keymap launches (adjust to taste)
sudo pacman -S --needed hyprpm konsole kitty dolphin brave-bin firefox viewnior gwenview

git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
./install.sh --dry-run    # see what it would do
./install.sh              # configs + hy3 + wallpaper slideshow + TildaZ
```

Options: `--skip-hy3`, `--skip-tildaz`, `--skip-wallpaper`, `--with-conky`, `--target auto|omarchy|arch`. `./install.sh --help` lists them.

### On Arch, EndeavourOS or CachyOS

These do not ship Omarchy's shell and Lua helpers, so you add them once. The script adds the `[omarchy]` repo and its desktop packages **without** replacing your bootloader.

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
./scripts/setup-arch-omarchy-stack.sh   # once; then log out and back in
./install.sh --target arch
```

Details: [Arch Linux](https://github.com/mysh264/omarchy-dotfiles/wiki/Arch-Linux) · [docs/arch-linux.md](docs/arch-linux.md) · [packages.arch.txt](packages.arch.txt).

### Then make it yours

Screens and keyboards differ per laptop. Do not reuse another machine's `monitors.lua` as is.

```bash
$EDITOR ~/.config/hypr/monitors.lua      # hyprctl monitors all shows your outputs
$EDITOR ~/.config/hypr/input.lua         # layouts, touchpad
hyprctl reload && hyprctl configerrors   # configerrors must print nothing
```

Step by step with checks: [Installation](https://github.com/mysh264/omarchy-dotfiles/wiki/Installation). Build it yourself from stock Omarchy: [Build This Rice](https://github.com/mysh264/omarchy-dotfiles/wiki/Build-This-Rice).

---

## Where things live

| Repo | Installed to | What |
|------|--------------|------|
| `hypr/` | `~/.config/hypr/` | Hyprland Lua: keys, layout, rules, autostart, monitors, input |
| `omarchy/` | `~/.config/omarchy/` | `shell.json` bar layout, cloned plugins, bar scripts, menu extensions |
| `tildaz/` | `~/.config/tildaz/` | TildaZ settings (`F1`, size, font) |
| `alacritty/` | `~/.config/alacritty/` | Alacritty font size |
| `docs/` | — | Long-form [i3 → hy3 guide](docs/hypr-i3-setup.md) and [Arch notes](docs/arch-linux.md) |
| `wiki/` | GitHub wiki | Source of the wiki pages |

Full tree: [Repo Layout](https://github.com/mysh264/omarchy-dotfiles/wiki/Repo-Layout). The rules that keep Omarchy updates painless: [Golden Rules](https://github.com/mysh264/omarchy-dotfiles/wiki/Golden-Rules).

## Learn as you go

New to Hyprland, or to how Omarchy layers its config? These pages explain the moving parts before you change them:

- [Learn Hyprland](https://github.com/mysh264/omarchy-dotfiles/wiki/Learn-Hyprland)
- [Learn Omarchy Hyprland](https://github.com/mysh264/omarchy-dotfiles/wiki/Learn-Omarchy-Hyprland)
- [Coming from i3](https://github.com/mysh264/omarchy-dotfiles/wiki/Coming-from-i3)
- [docs/hypr-i3-setup.md](docs/hypr-i3-setup.md): the long version of how this machine was built, step by step

Keeping two laptops in sync and rebuilding hy3 after upgrades: [Updating](https://github.com/mysh264/omarchy-dotfiles/wiki/Updating). Something broke: [Troubleshooting](https://github.com/mysh264/omarchy-dotfiles/wiki/Troubleshooting).

---

## Credits & license

- **Omarchy** — © David Heinemeier Hansson and contributors · [omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org) · MIT
- **hy3** — [outfoxxed/hy3](https://github.com/outfoxxed/hy3), the i3-style layout plugin that makes this possible
- **TildaZ** — [ensky0/tildaz](https://github.com/ensky0/tildaz) · [tildaz.dev](https://tildaz.dev), the dropdown terminal
- **Lean Conky Config** — [jxai/lean-conky-config](https://github.com/jxai/lean-conky-config) (fork: [mysh264/lean-conky-config](https://github.com/mysh264/lean-conky-config))
- [Hyprland](https://hypr.land/) and the Quickshell ecosystem that powers Omarchy's shell
- **This dotfiles repo** — MIT (see [LICENSE](LICENSE)). Configs are provided as-is for learning and reuse.

If you publish a fork, please keep the Omarchy credit block above so newcomers find the real project first.
