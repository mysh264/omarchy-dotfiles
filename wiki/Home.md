# Omarchy Dotfiles Wiki

Portable **user** configs for [Omarchy](https://omarchy.org) and baseline [Arch Linux](https://archlinux.org/): **hy3** (i3-style splits & tabs), an i3-ish keymap, a bottom status bar with hardware stats, dual-stack-friendly network widget, dropdown Kitty, Conky autostart, and familiar screenshot binds.

**Repo:** [mysh264/omarchy-dotfiles](https://github.com/mysh264/omarchy-dotfiles)

> **This is not Omarchy.** It is a personal layer on top of Omarchy.  
> Omarchy is by [David Heinemeier Hansson](https://dhh.dk/) and the Omacom team — [github.com/omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org).  
> Prefer Omarchy’s own docs and `omarchy` CLI for system features. **Never edit `/usr/share/omarchy/`** — updates overwrite it.

---

## Learn to configure (start here)

| Path | Page | What you learn |
|------|------|----------------|
| **1. Hyprland basics** | [Learn Hyprland](Learn-Hyprland) | Config model, reload, hyprctl, binds, rules, plugins — step by step |
| **2. Omarchy’s Hyprland** | [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) | Defaults vs `~/.config`, `o.bind` / `o.window`, menu, bar, themes |
| **3. Build this rice** | [Build This Rice](Build-This-Rice) | Ordered rebuild: hy3 → keys → workspaces → bar → checks |

Also: [Golden Rules](Golden-Rules) · [Installation](Installation) · [Repo Layout](Repo-Layout) · [Keybinding Cheatsheet](Keybinding-Cheatsheet)

---

## Edit every part of this rice

### Hyprland (window manager)

| Feature | File → on disk | Wiki |
|---------|----------------|------|
| Entry / workspaces / app rules | `hypr/hyprland.lua` | [Hyprland Core](Hyprland-Core) |
| Keybindings, hot corners, bar peek | `hypr/bindings.lua` | [Keybindings](Keybindings) |
| Gaps, blur, hy3 glass tabs | `hypr/looknfeel.lua` | [Look and Feel](Look-and-Feel) |
| Login processes | `hypr/autostart.lua` | [Autostart](Autostart) |
| Displays | `hypr/monitors.lua` | [Monitors and Input](Monitors-and-Input) |
| Keyboard / touchpad | `hypr/input.lua` | [Monitors and Input](Monitors-and-Input) |
| Dropdown Kitty | rules + binds + autostart | [Dropdown Terminal](Dropdown-Terminal) |
| Focused screenshot | `hypr/scripts/screenshot-focused` | [Screenshots](Screenshots) |
| Night light | `hypr/hyprsunset.conf` | [Night Light and Portal](Night-Light-and-Portal) |
| Screencast portal | `hypr/xdph.conf` | [Night Light and Portal](Night-Light-and-Portal) |
| Per-window keyboard | hypr-kblayoutd | [Per-window Keyboard](Per-Window-Keyboard) |
| Lean Conky | `~/.config/conky` + autostart | [Conky](Conky) |

### Omarchy shell / bar

| Feature | File | Wiki |
|---------|------|------|
| Bar layout, idle lock | `omarchy/shell.json` | [Status Bar](Status-Bar) |
| Shell font / theme tpl / wallpaper service | `shell.toml`, `themed/`, slideshow | [Themes and Fonts](Themes-and-Fonts) |
| Hardware stats | `omarchy/bar/scripts/hw-stats` | [Hardware Stats](Hardware-Stats) |
| Wallpaper on bar | `omarchy/bar/modules/wallpaper.qml` | [Wallpaper Widget](Wallpaper-Widget) |
| Cloned bar / network | `omarchy/plugins/mahmoud.*` | [Plugins](Plugins) |
| Menu extras | `omarchy/extensions/omarchy-menu.jsonc` | [Menu Extensions](Menu-Extensions) |
| Default AI agent | `omarchy/defaults/agent` | [Themes and Fonts](Themes-and-Fonts) |

### Other

| Feature | Wiki |
|---------|------|
| Alacritty | [Terminal (Alacritty)](Terminal-Alacritty) |
| Arch / EndeavourOS / CachyOS | [Arch Linux](Arch-Linux) |
| Installer | [Installation](Installation) |
| Sync laptops | [Updating](Updating) |
| When it breaks | [Troubleshooting](Troubleshooting) |

---

## After every Hyprland Lua edit

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

Bar / `shell.json`:

```bash
omarchy restart shell
```

---

## Deep in-repo docs

- [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md) — full machine narrative  
- [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md)  

## Credits

- **Omarchy** — © DHH & contributors · MIT  
- **hy3** — [outfoxxed/hy3](https://github.com/outfoxxed/hy3)  
- **This rice** — MIT · [LICENSE](https://github.com/mysh264/omarchy-dotfiles/blob/main/LICENSE)
