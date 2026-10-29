# Omarchy Dotfiles Wiki

My [Omarchy](https://omarchy.org) desktop, tuned to feel like the **i3wm** setup I used for years. This wiki explains every piece so you can do the same to your own Hyprland: what it does, where it lives, how to change it, and how to check it worked.

**Repo:** [mysh264/omarchy-dotfiles](https://github.com/mysh264/omarchy-dotfiles)

> **This is not Omarchy.** It is a personal layer on top of Omarchy.
> Omarchy is by [David Heinemeier Hansson](https://dhh.dk/) and the Omacom team: [github.com/omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org).
> Everything here lives in `~/.config/` and loads **after** Omarchy's defaults. **Never edit `/usr/share/omarchy/`**: updates overwrite it.

---

## Who this is for

- **You love i3 and are moving to Omarchy / Hyprland.** You want containers, splits and tabs, your old keys, named workspaces with icons, apps that open on "their" workspace, and a Quake-style dropdown terminal.
- **You want to tweak Hyprland the Omarchy way.** Small override files in `~/.config/hypr/`, the `omarchy` CLI, `omarchy plugin clone` for bar widgets, and no hand-edits to package files.

## What this rice does

| Piece | How | In i3 it was |
|-------|-----|--------------|
| Containers, splits, tabs | [hy3](https://github.com/outfoxxed/hy3) plugin by outfoxxed | i3's own tree layout |
| i3-style keys | `hypr/bindings.lua`: Super+Arrows, Super+H/V/W/E, Super+Q, Super+1…12 | `bindsym` / `bindcode` |
| Auto tabs | 1 window = plain split, 2nd window = tabs, 3+ = left as you set them | `workspace_layout tabbed` (roughly) |
| Named workspaces with icons | `workspace_names` in `hypr/hyprland.lua` | `set $ws1 "1: "` |
| App → workspace | `assign(...)` in `hypr/hyprland.lua` | `assign [class="..."] $ws2` |
| No gaps with one window | `w[tv1]` / `f[1]` workspace rules | `smart_gaps on` |
| Dropdown terminal | [TildaZ](https://github.com/ensky0/tildaz) on **F1** | a Quake terminal in the scratchpad |
| Bottom bar | Omarchy shell: cloned bar, named-workspaces widget, hardware stats | i3bar + i3status |
| Screenshots, night light, Conky | small scripts and conf files | the usual `exec` lines |

---

## Where to start

| You want to… | Read |
|--------------|------|
| **Translate your i3 config** | **[Coming from i3](Coming-from-i3)**: i3 concepts → this setup, one by one |
| Install it as-is | [Installation](Installation) |
| Understand Hyprland first | [Learn Hyprland](Learn-Hyprland) |
| Understand Omarchy's layer on top | [Learn Omarchy Hyprland](Learn-Omarchy-Hyprland) |
| Rebuild it yourself, step by step | [Build This Rice](Build-This-Rice) |
| Avoid the common traps | [Golden Rules](Golden-Rules) |

---

## Map of pages

### Hyprland (window manager)

| Feature | Repo file → `~/.config/…` | Wiki |
|---------|---------------------------|------|
| Entry, workspaces, names, app assigns, smart gaps | `hypr/hyprland.lua` | [Hyprland Core](Hyprland-Core) |
| Keybindings, hot corners, bar peek | `hypr/bindings.lua` | [Keybindings](Keybindings) · [Cheatsheet](Keybinding-Cheatsheet) |
| Gaps, borders, blur, hy3 glass tabs, auto tabs | `hypr/looknfeel.lua` | [Look and Feel](Look-and-Feel) |
| Login processes (hy3 reload, Conky) | `hypr/autostart.lua` | [Autostart](Autostart) |
| Displays | `hypr/monitors.lua` | [Monitors and Input](Monitors-and-Input) |
| Keyboard (US + Arabic, Win+Space) / touchpad | `hypr/input.lua` | [Monitors and Input](Monitors-and-Input) |
| Dropdown terminal (TildaZ) | `tildaz/config_0.toml` + binds + layer rule | [Dropdown Terminal](Dropdown-Terminal) |
| Focused-window screenshot | `hypr/scripts/screenshot-focused` | [Screenshots](Screenshots) |
| Night light | `hypr/hyprsunset.conf` | [Night Light and Portal](Night-Light-and-Portal) |
| Screencast portal | `hypr/xdph.conf` | [Night Light and Portal](Night-Light-and-Portal) |
| Per-window keyboard layout | hypr-kblayoutd (optional) | [Per-window Keyboard](Per-Window-Keyboard) |
| Lean Conky | `~/.config/conky` + autostart | [Conky](Conky) |

### Omarchy shell / bar

| Feature | Repo file | Wiki |
|---------|-----------|------|
| Bar layout, idle lock | `omarchy/shell.json` | [Status Bar](Status-Bar) |
| Named workspaces on the bar | `omarchy/plugins/mahmoud.workspaces/` | [Plugins](Plugins) · [Status Bar](Status-Bar) |
| Cloned bar / network widget | `omarchy/plugins/mahmoud.bar/`, `mahmoud.network/` | [Plugins](Plugins) |
| Hardware stats | `omarchy/bar/scripts/hw-stats` | [Hardware Stats](Hardware-Stats) |
| Wallpaper on the bar | `omarchy/bar/modules/wallpaper.qml` | [Wallpaper Widget](Wallpaper-Widget) |
| Shell font / theme template | `omarchy/shell.toml`, `omarchy/themed/` | [Themes and Fonts](Themes-and-Fonts) |
| Menu extras | `omarchy/extensions/omarchy-menu.jsonc` | [Menu Extensions](Menu-Extensions) |
| Default AI agent | `omarchy/defaults/agent` | [Themes and Fonts](Themes-and-Fonts) |

### Other

| Topic | Wiki |
|-------|------|
| Alacritty | [Terminal (Alacritty)](Terminal-Alacritty) |
| Arch / EndeavourOS / CachyOS | [Arch Linux](Arch-Linux) |
| What is in the repo | [Repo Layout](Repo-Layout) |
| Sync laptops, after upgrades | [Updating](Updating) |
| When it breaks | [Troubleshooting](Troubleshooting) |

---

## After every edit

Hyprland Lua (`~/.config/hypr/*.lua`):

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

Bar, `shell.json`, plugins:

```bash
omarchy restart shell
```

---

## Deep in-repo docs

- [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md): the long-form machine narrative
- [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md)

## Credits

- **Omarchy**: DHH, Omacom and contributors · MIT · [omacom/omarchy](https://github.com/omacom/omarchy)
- **hy3**: outfoxxed · [outfoxxed/hy3](https://github.com/outfoxxed/hy3)
- **TildaZ**: ensky0 · [ensky0/tildaz](https://github.com/ensky0/tildaz) · [tildaz.dev](https://tildaz.dev)
- **This rice**: MIT · [LICENSE](https://github.com/mysh264/omarchy-dotfiles/blob/main/LICENSE)
