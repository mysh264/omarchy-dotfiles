# Wallpaper Widget

**Repo:** `omarchy/bar/modules/wallpaper.qml`  
**Live:** `~/.config/omarchy/bar/modules/wallpaper.qml`  
**Wired in:** `shell.json` as `{ "id": "wallpaper", "type": "qml" }` (a [QML module](Status-Bar#qml-module))

Three small buttons on the bar (previous · pause/play · next) that drive a wallpaper slideshow. Scrolling over the widget also goes back and forward.

## The slideshow behind it

The widget calls `~/.local/bin/wallpaper-slideshow` by its full path, so it works in both the "Hyprland" and "Hyprland (uwsm-managed)" sessions (only the uwsm one puts `~/.local/bin` on the session PATH). It is a small personal script (not part of Omarchy) that ships in this repo and is installed by `install.sh` (skip with `--skip-wallpaper`):

| Repo | Live | What it is |
|------|------|------------|
| `wallpaper/wallpaper-slideshow` | `~/.local/bin/wallpaper-slideshow` | The script. Picks images from a folder and sets them with Omarchy's own background setter, so `omarchy theme bg current` stays in sync |
| `wallpaper/wallpaper-slideshow.conf` | `~/.config/wallpaper-slideshow.conf` | Folder and interval. Copied only if you don't have one yet |
| `wallpaper/wallpaper-slideshow.service` | `~/.config/systemd/user/wallpaper-slideshow.service` | systemd user service that runs `wallpaper-slideshow --loop` for the whole session |

Default settings:

```bash
WALLPAPER_DIR="${HOME}/.Wallpapers"   # scanned recursively: jpg, jpeg, png, gif, bmp, webp
INTERVAL_SEC=300                      # 5 minutes
```

**The slideshow ships no images.** `install.sh` creates an empty `~/.Wallpapers` and says so when it is empty. Fill it one of two ways:

```bash
# your own pictures
cp ~/Pictures/*.jpg ~/.Wallpapers/

# or the owner's pack (~1.2 GB, github.com/mysh264/wallpapers)
./install.sh --with-wallpapers
# by hand: git clone --depth 1 https://github.com/mysh264/wallpapers.git ~/Documents/GitHub/wallpapers
#          ~/Documents/GitHub/wallpapers/install.sh
```

With an empty folder, clicking a bar button shows a notification ("No wallpapers found in ~/.Wallpapers") and the tooltip says the same; the timer stays quiet and just logs it.

After changing the interval:

```bash
systemctl --user restart wallpaper-slideshow.service
```

Commands (`wallpaper-slideshow --help`): `--next`, `--prev`, `--toggle`, `--pause`, `--resume`, `--status` (JSON for the bar), `--loop` (used by the service).

Manual install without `install.sh`:

```bash
install -Dm755 wallpaper/wallpaper-slideshow ~/.local/bin/wallpaper-slideshow
cp -n wallpaper/wallpaper-slideshow.conf ~/.config/
install -Dm644 wallpaper/wallpaper-slideshow.service ~/.config/systemd/user/wallpaper-slideshow.service
mkdir -p ~/.Wallpapers
systemctl --user daemon-reload && systemctl --user enable --now wallpaper-slideshow.service
```

i3 note: the i3 equivalent would be `exec_always feh --randomize --bg-fill ~/.Wallpapers/*` in a loop. Here a systemd user service does the looping and Omarchy's setter does the drawing.

## Interactions

| Control | Runs |
|---------|------|
| 󰒮 | `wallpaper-slideshow --prev` |
| 󰏤 / 󰐊 (pause / play) | `wallpaper-slideshow --toggle` |
| 󰒭 | `wallpaper-slideshow --next` |
| Scroll up / down | `--prev` / `--next` |
| Hover a button | Tooltip: what it does + the current file name |
| Hover the widget | Tooltip from the script (state, name, position, interval) |

Every **2 s** the widget runs `wallpaper-slideshow --status` and reads its JSON. It uses three fields:

```json
{"running": true, "name": "musashi_miyamoto.png", "tooltip": "running\nmusashi_miyamoto.png\n235 / 316 · every 5m\n…"}
```

`running` picks the pause or play icon. The pause button is drawn brighter while the slideshow runs.

## How to edit

1. Edit `~/.config/omarchy/bar/modules/wallpaper.qml` (or the repo copy, then copy it over).  
2. Run `omarchy restart shell` if the bar does not show the change.

### Ideas

| Goal | Change |
|------|--------|
| Different icons | `iconText` on each `WallpaperButton` (Nerd Font glyphs) |
| Poll faster or slower | `interval: 2000` in the `statusTimer` `Timer` (milliseconds) |
| Different backend | Replace `wallpaper-slideshow` in `runCmd()` and in `statusProc.command`. For plain Omarchy, `--next` could become `omarchy theme bg next`. |
| Hide the widget | Remove the `wallpaper` entry from `shell.json` |

## QML module contract

A custom module is an `Item` with `implicitWidth` and `implicitHeight`. The bar fills these properties after loading it (declare the ones you use):

- `bar`: the bar root: theme colors (`bar.barForeground` is what this widget uses), `bar.fontFamily`, `bar.barSize`, `bar.run(cmd)`, `bar.showTooltip(item, text)` / `bar.hideTooltip(item)`  
- `settings`: extra keys from the module's `shell.json` entry  
- `moduleName`: the entry id  

This widget also imports `qs.Commons` for `Style` (spacing, font sizes) and falls back to `Commons.Color.foreground` when `bar` is not set yet. The full list of bar properties is in `omarchy/plugins/mahmoud.bar/README.md` (copied from Omarchy's bar README).

## Check it worked

```bash
systemctl --user status wallpaper-slideshow.service   # active (running)?
wallpaper-slideshow --status | jq .        # the widget needs this to work
hyprctl layers | grep omarchy-background   # Omarchy's wallpaper layer
omarchy theme bg current                   # name of the background now on screen
```

Click next on the bar, then run `omarchy theme bg current` again: the name should change.

## Wallpaper without the widget

Plain Omarchy commands:

```bash
omarchy theme bg next              # next background of the current theme
omarchy theme bg set ~/Pictures/x.png
omarchy theme bg-switcher          # picker with thumbnails
```

Extra backgrounds for a theme go in `~/.config/omarchy/backgrounds/<theme-slug>/`.
