# Themes, fonts, wallpaper, app look

## Shell font size

**File:** `~/.config/omarchy/shell.toml`

```toml
[font]
base-size = 14
```

Then `omarchy restart shell` if needed.

---

## Omarchy theme CLI

```bash
omarchy theme list
omarchy theme current
omarchy theme set "Catppuccin"
omarchy theme refresh
omarchy theme bg next
```

`theme set` / `refresh` regenerates bar, terminal theme files under `~/.local/state/omarchy/current/theme/`, and many GTK-facing settings. Your Lua binds/gaps/rules stay yours.

Check GTK:

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
```

Force dark without changing Omarchy theme name:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

Qt apps (Dolphin, Konsole) follow when `QT_QPA_PLATFORMTHEME=gtk3` (Omarchy default). Reopen apps to pick up changes.

---

## Bar glass (translucent fill)

| Piece | Where | Shipped idea |
|-------|--------|----------------|
| Fill alpha | `~/.config/omarchy/themed/shell.toml.tpl` → `[bar] background-alpha` | `0.55` (see-through; `1.0` = solid) |
| Live file | `~/.local/state/omarchy/current/theme/shell.toml` | Regenerated from the template |
| Layer blur | `looknfeel.lua` `hl.layer_rule` on `omarchy-bar` | `blur = true` |
| Compositor blur | `looknfeel.lua` | `decoration.blur.enabled = true` |

Keep `"transparent": false` in `shell.json`. That flag makes the bar **fully clear** (no fill). Partial glass uses `background-alpha`.

After editing the template:

```bash
omarchy theme refresh
# or: omarchy theme set <name>
```

---

## Theme template (`shell.toml.tpl`)

**File:** `~/.config/omarchy/themed/shell.toml.tpl`

Full chrome template (bar, menu, notifications, lock input, …). Prefer CLI themes first; edit the tpl when you need persistent overrides across theme switches (e.g. bar alpha, font scale).

---

## Wallpaper slideshow

Images under `~/.Wallpapers` (subfolders OK). A user service rotates them with `omarchy theme bg set`.

| Path | Role |
|------|------|
| `~/.local/bin/wallpaper-slideshow` | Script (`--next`, `--prev`, `--toggle`, `--loop`, `--status`) |
| `~/.config/wallpaper-slideshow.conf` | `WALLPAPER_DIR`, `INTERVAL_SEC` |
| `~/.config/systemd/user/wallpaper-slideshow.service` | Starts with graphical session |

```bash
# Interval examples: 60, 300 (5 min), 600, 1800
$EDITOR ~/.config/wallpaper-slideshow.conf
systemctl --user restart wallpaper-slideshow.service

wallpaper-slideshow --next
wallpaper-slideshow --prev
wallpaper-slideshow --toggle
systemctl --user status wallpaper-slideshow.service
```

**Bar buttons:** [Wallpaper Widget](Wallpaper-Widget) — prev / pause / next + scroll.

---

## Default AI agent

**File:** `~/.config/omarchy/defaults/agent`  
Shipped: `claude`  
Change to what `omarchy-default-agent` accepts, or delete for Omarchy’s setup invitation.

---

## Terminal fonts

- **Alacritty:** [Terminal (Alacritty)](Terminal-Alacritty) — JetBrainsMono Nerd Font size 11; colors from theme import  
- **Kitty / others:** theme-managed or their own `~/.config/`  

## hy3 tab font

`plugin.hy3.tabs.text_font` in [Look and Feel](Look-and-Feel) (shipped: JetBrainsMono Nerd Font).

---

## Viewnior / X11 GTK apps

Viewnior on Wayland can be flaky. Force X11 via a **user** desktop file:

```bash
cp /usr/share/applications/viewnior.desktop ~/.local/share/applications/viewnior.desktop
# Exec=env GDK_BACKEND=x11 GTK_THEME=Adwaita:dark /usr/bin/viewnior %F
update-desktop-database ~/.local/share/applications
```

X11 GTK reads `~/.config/gtk-3.0/settings.ini` (create if missing):

```ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=Yaru-purple
```

Viewnior image canvas (separate from GTK theme) — close Viewnior first, then:

```ini
# ~/.config/viewnior/viewnior.conf
dark-background=true
```

Or **View → Dark background** in the app.
