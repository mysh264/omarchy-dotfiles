# Omarchy Dotfiles Wiki

Portable **user** configs for [Omarchy](https://omarchy.org) and baseline [Arch Linux](https://archlinux.org/): **hy3** (i3-style splits & tabs), an i3-ish keymap, a bottom status bar with hardware stats, dual-stack-friendly network widget, dropdown Kitty, Conky autostart, and familiar screenshot binds.

**Repo:** [mysh264/omarchy-dotfiles](https://github.com/mysh264/omarchy-dotfiles)

> **This is not Omarchy.** It is a personal layer on top of Omarchy.  
> Omarchy is by [David Heinemeier Hansson](https://dhh.dk/) and the Omacom team — [github.com/omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org).  
> Prefer Omarchy’s own docs and `omarchy` CLI for system features. **Never edit `/usr/share/omarchy/`** — updates overwrite it.

---

## Start here

| Goal | Page |
|------|------|
| Install on Omarchy or Arch | [Installation](Installation) |
| Rules before you edit anything | [Golden Rules](Golden-Rules) |
| Map of every file in the repo | [Repo Layout](Repo-Layout) |
| Full key list | [Keybinding Cheatsheet](Keybinding-Cheatsheet) |

---

## Edit every part

### Hyprland (window manager)

| Feature | File (in repo → on disk) | Wiki |
|---------|--------------------------|------|
| Entry / workspaces / app rules | `hypr/hyprland.lua` → `~/.config/hypr/hyprland.lua` | [Hyprland Core](Hyprland-Core) |
| Keybindings, hot corners, bar peek | `hypr/bindings.lua` | [Keybindings](Keybindings) |
| Gaps, blur, hy3 glass tabs | `hypr/looknfeel.lua` | [Look and Feel](Look-and-Feel) |
| Login processes (hy3, Conky, dropdown) | `hypr/autostart.lua` | [Autostart](Autostart) |
| Displays | `hypr/monitors.lua` | [Monitors and Input](Monitors-and-Input) |
| Keyboard / touchpad | `hypr/input.lua` | [Monitors and Input](Monitors-and-Input) |
| Focused-window screenshot | `hypr/scripts/screenshot-focused` | [Screenshots](Screenshots) |
| Night light | `hypr/hyprsunset.conf` | [Night Light and Portal](Night-Light-and-Portal) |
| Screencast portal | `hypr/xdph.conf` | [Night Light and Portal](Night-Light-and-Portal) |

### Omarchy shell / bar

| Feature | File | Wiki |
|---------|------|------|
| Bar layout, idle lock | `omarchy/shell.json` | [Status Bar](Status-Bar) |
| Shell font size | `omarchy/shell.toml` | [Themes and Fonts](Themes-and-Fonts) |
| Theme template override | `omarchy/themed/shell.toml.tpl` | [Themes and Fonts](Themes-and-Fonts) |
| Hardware stats widget | `omarchy/bar/scripts/hw-stats` | [Hardware Stats](Hardware-Stats) |
| Wallpaper controls on bar | `omarchy/bar/modules/wallpaper.qml` | [Wallpaper Widget](Wallpaper-Widget) |
| Cloned bar engine | `omarchy/plugins/mahmoud.bar/` | [Plugins](Plugins) |
| Cloned network panel | `omarchy/plugins/mahmoud.network/` | [Plugins](Plugins) |
| Omarchy menu extras | `omarchy/extensions/omarchy-menu.jsonc` | [Menu Extensions](Menu-Extensions) |
| Default AI agent | `omarchy/defaults/agent` | [Themes and Fonts](Themes-and-Fonts) |

### Other

| Feature | File | Wiki |
|---------|------|------|
| Alacritty font / keys | `alacritty/alacritty.toml` | [Terminal (Alacritty)](Terminal-Alacritty) |
| Arch package layer | `scripts/setup-arch-omarchy-stack.sh` | [Arch Linux](Arch-Linux) |
| Installer | `install.sh` | [Installation](Installation) |

---

## After every Hyprland Lua edit

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

Bar / `shell.json` usually hot-reloads; force with:

```bash
omarchy restart shell
```

---

## Also see

- Deep hy3 / i3 rebuild guide (in-repo): [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
- Arch walkthrough (in-repo): [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md)
- [Updating & syncing laptops](Updating)
- [Troubleshooting](Troubleshooting)

## Credits

- **Omarchy** — © DHH & contributors · MIT  
- **hy3** — [outfoxxed/hy3](https://github.com/outfoxxed/hy3)  
- **This rice** — MIT · [LICENSE](https://github.com/mysh264/omarchy-dotfiles/blob/main/LICENSE)
