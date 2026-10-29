# Repo Layout

```text
omarchy-dotfiles/
├── hypr/                 → ~/.config/hypr/
│   ├── hyprland.lua      # loads Omarchy defaults + your modules
│   ├── bindings.lua      # keymap, hot corners, bar peek, screenshots
│   ├── looknfeel.lua     # gaps, blur, hy3 tab glass + auto titlebars
│   ├── autostart.lua     # hy3 reload, Conky, dropdown Kitty
│   ├── input.lua         # keyboard / pointer
│   ├── monitors.lua      # displays (edit per laptop)
│   ├── hyprsunset.conf   # night light profiles
│   ├── xdph.conf         # XDG portal / screencast
│   ├── .luarc.json       # Lua LSP hints for Hyprland
│   └── scripts/
│       └── screenshot-focused
├── omarchy/              → ~/.config/omarchy/
│   ├── shell.json        # bar layout, idle lock timings
│   ├── shell.toml        # shell font size
│   ├── plugins/
│   │   ├── mahmoud.bar/      # cloned bar engine (id: mahmoud.bar)
│   │   ├── mahmoud.network/  # cloned network widget
│   │   └── mahmoud.workspaces/  # all 12 workspaces with their names
│   ├── bar/
│   │   ├── scripts/hw-stats  # CPU/GPU/RAM command module
│   │   └── modules/wallpaper.qml
│   ├── themed/
│   │   └── shell.toml.tpl    # theme regeneration override
│   ├── extensions/
│   │   └── omarchy-menu.jsonc
│   └── defaults/
│       └── agent             # e.g. cursor-agent
├── alacritty/            → ~/.config/alacritty/
│   └── alacritty.toml
├── scripts/
│   └── setup-arch-omarchy-stack.sh
├── docs/
│   ├── arch-linux.md
│   └── hypr-i3-setup.md
├── packages.arch.txt
├── install.sh
├── README.md
└── LICENSE
```

## Runtime paths you will also touch

| Path | Role |
|------|------|
| `~/.local/state/omarchy/toggles/bar-off` | Bar hidden latch (Super+M / hot corner) |
| `~/.local/state/omarchy/workspace-layouts/*.lua` | Omarchy per-workspace layout saves (can fight hy3) |
| `~/.local/state/omarchy/current/theme/` | Active theme files (Alacritty imports from here) |
| `~/.cache/omarchy/hw-stats-cpu` | CPU % delta state for hw-stats |
| `/var/cache/hyprpm/$USER/hy3/hy3.so` | Built hy3 plugin |

## Source of truth after install

Edit the copies under `~/.config/…`. When happy, copy changes **back** into the git clone and push — see [Updating](Updating).
