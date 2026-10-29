# Repo Layout

What is in the repo, and where `install.sh` puts it.

```text
omarchy-dotfiles/
├── hypr/                     → ~/.config/hypr/
│   ├── hyprland.lua          # entry: Omarchy defaults, your modules, hy3 layout per workspace,
│   │                         #   smart gaps, workspace_names, app assigns, pcall(require, "tildaz")
│   ├── bindings.lua          # i3 keymap (hy3), hot corners, bar hide/peek, screenshots, TildaZ toggle keys
│   ├── looknfeel.lua         # gaps/borders, blur, bar + tildaz layer rules, hy3 glass tabs, auto tabs
│   ├── autostart.lua         # hyprpm reload && hyprctl reload (hy3), Conky
│   ├── input.lua             # us,ara + Win+Space, follow_mouse
│   ├── monitors.lua          # displays (edit per laptop)
│   ├── hyprsunset.conf       # night light profiles
│   ├── xdph.conf             # XDG portal / screencast
│   ├── .luarc.json           # Lua LSP hints for Hyprland
│   └── scripts/
│       └── screenshot-focused
├── omarchy/                  → ~/.config/omarchy/
│   ├── shell.json            # bar layout (bar id mahmoud.bar), idle lock timings
│   ├── shell.toml            # shell font size
│   ├── plugins/
│   │   ├── mahmoud.bar/          # cloned bar engine
│   │   ├── mahmoud.network/      # cloned network widget
│   │   └── mahmoud.workspaces/   # cloned workspaces widget: 1–7 always, 8–12 while they exist,
│   │                             #   names read from workspace_names in ~/.config/hypr/hyprland.lua
│   ├── bar/
│   │   ├── scripts/hw-stats      # CPU/GPU/RAM command module
│   │   └── modules/wallpaper.qml
│   ├── themed/
│   │   └── shell.toml.tpl        # theme regeneration override
│   ├── extensions/
│   │   └── omarchy-menu.jsonc
│   └── defaults/
│       └── agent                 # claude
├── tildaz/                   → ~/.config/tildaz/
│   └── config_0.toml         # TildaZ: hotkey F1, 95% × 50%, top, 90% opacity, theme Tilda
├── wallpaper/                → ~/.local/bin, ~/.config, ~/.config/systemd/user
│   ├── wallpaper-slideshow   # script the bar's wallpaper buttons call
│   ├── wallpaper-slideshow.conf      # folder (~/.Wallpapers) + interval (300 s)
│   └── wallpaper-slideshow.service   # systemd user service: --loop
├── alacritty/                → ~/.config/alacritty/
│   └── alacritty.toml
├── scripts/
│   ├── setup-arch-omarchy-stack.sh   # baseline Arch: layer the Omarchy stack
│   └── publish-wiki.sh               # rsync wiki/ to the GitHub wiki repo
├── wiki/                     # these pages (published by scripts/publish-wiki.sh, not installed)
├── docs/
│   ├── arch-linux.md
│   └── hypr-i3-setup.md
├── packages.arch.txt
├── install.sh
├── README.md
└── LICENSE
```

`mahmoud.*` plugins were made with `omarchy plugin clone`, so they survive Omarchy updates. See [Plugins](Plugins).

## Machine-local files (not in the repo)

These are created on each machine. Do not copy them between laptops or commit them.

| Path | Made by | Role |
|------|---------|------|
| `~/.config/hypr/tildaz.lua` | `tildaz --desktop add` | Starts TildaZ at login with this machine's binary path. Loaded by `pcall(require, "tildaz")` at the end of `hyprland.lua`. `tildaz --desktop remove` deletes it |
| `~/.local/state/omarchy/toggles/hypr/window-no-gaps.lua` | `Super+Shift+Backspace` (Omarchy) | Global no-gaps toggle: zeroes gaps **and** borders everywhere. Delete it (or press the key again) to get this rice's gaps back |
| `~/.local/state/omarchy/toggles/hypr/flags.lua` | Omarchy | Placeholder that keeps the toggles directory non-empty. Do not delete it |
| `~/.local/state/omarchy/toggles/bar-off` | Super+M / top-left hot corner | Bar hidden latch |
| `~/.local/state/omarchy/workspace-layouts/*.lua` | Omarchy Super+L (unbound here) | Per-workspace layout saves; can fight hy3 |
| `~/.local/state/omarchy/current/theme/` | `omarchy theme set` | Active theme files (Alacritty imports from here) |
| `~/.cache/omarchy/hw-stats-cpu` | `hw-stats` | CPU % delta state |
| `/var/cache/hyprpm/$USER/hy3/hy3.so` | `hyprpm update` | Built hy3 plugin |
| `~/.local/bin/tildaz`, `~/.local/share/tildaz/` | TildaZ installer | TildaZ binary |
| `~/.config/omarchy-dotfiles-backup-*/` | `install.sh` | Backups of files it replaced |

## Source of truth after install

Edit the copies under `~/.config/…`. When happy, copy changes **back** into the git clone and push. See [Updating](Updating).
