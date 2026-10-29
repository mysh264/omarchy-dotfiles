# Themes, fonts, wallpaper and app look

Omarchy (by DHH / Omacom) themes the whole desktop at once: Hyprland borders, the shell (bar, menu, notifications, lock), terminals, btop, Neovim, GTK and more. This rice keeps that system and only layers a few overrides on top. Your Lua binds, gaps and rules are never touched by a theme switch.

In i3 you probably kept colors in `~/.config/i3/config` (`client.focused …`), `~/.Xresources` and each app's config, and changed them by hand. In Omarchy one command recolors everything.

## How Omarchy themes work

| Piece | Where |
|-------|-------|
| Stock themes (read-only) | `/usr/share/omarchy/themes/<slug>/` (catppuccin, tokyo-night, gruvbox, nord, …) |
| Your own themes and overlays | `~/.config/omarchy/themes/<slug>/` |
| Your template overrides | `~/.config/omarchy/themed/<file>.tpl` (this rice ships `shell.toml.tpl`) |
| The active theme, generated | `~/.local/state/omarchy/current/theme/` (`alacritty.toml`, `foot.ini`, `kitty.conf`, `hyprland.lua`, `shell.toml`, `btop.theme`, …) |
| Active theme name | `~/.local/state/omarchy/current/theme.name` |

A theme is mostly a `colors.toml` plus backgrounds. When you apply it, Omarchy fills its templates (`/usr/share/omarchy/default/themed/*.tpl`, or yours in `~/.config/omarchy/themed/`) with those colors and writes the results into `~/.local/state/omarchy/current/theme/`. Apps import from there, which is why `alacritty.toml` has a `general.import` line.

### Theme commands

```bash
omarchy theme list                 # available themes
omarchy theme current              # active theme
omarchy theme set catppuccin       # apply ("Catppuccin" works too)
omarchy theme switcher             # picker with previews
omarchy theme refresh              # re-generate the current theme from the templates
omarchy theme install <git-url>    # install a theme from a git repo
omarchy theme dir catppuccin       # where a theme lives (your copy wins)
```

This machine runs **Catppuccin**.

### Change a stock theme the Omarchy way: overlay

Never edit `/usr/share/omarchy/themes/`; updates overwrite it. Instead make a folder with the **same slug** in `~/.config/omarchy/themes/` and put only the files you want to change in it. When the theme is applied, the stock theme is copied first and your files win:

```bash
mkdir -p ~/.config/omarchy/themes/catppuccin
cp /usr/share/omarchy/themes/catppuccin/colors.toml ~/.config/omarchy/themes/catppuccin/
$EDITOR ~/.config/omarchy/themes/catppuccin/colors.toml
omarchy theme set catppuccin
```

For a fully separate variant, copy the whole theme under a new name (`cp -r /usr/share/omarchy/themes/catppuccin ~/.config/omarchy/themes/catppuccin-custom`) and `omarchy theme set catppuccin-custom`.

> Themes installed with `omarchy theme install` are treated more strictly: Omarchy drops files that run code (`*.lua`, terminal configs, `vscode.json`) and regenerates them from `colors.toml`. Themes you write by hand are not restricted.

### Check it worked

```bash
omarchy theme current
cat ~/.local/state/omarchy/current/theme.name
gsettings get org.gnome.desktop.interface color-scheme   # 'prefer-dark' for dark themes
```

---

## Bar glass (see-through bar)

Stock Omarchy draws a solid bar. This rice makes it about half see-through, with blur behind it.

| Piece | Where | Shipped |
|-------|-------|---------|
| Fill alpha | `omarchy/themed/shell.toml.tpl` → `~/.config/omarchy/themed/shell.toml.tpl`, `[bar] background-alpha` | `0.55` (stock `1.0` = solid). This is the **only** line that differs from the stock template. |
| Generated file | `~/.local/state/omarchy/current/theme/shell.toml` | Written from the template on every theme switch |
| Blur behind the bar | `hypr/looknfeel.lua`: `hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = false, no_anim = false, animation = "none" })` | on |
| Compositor blur | `hypr/looknfeel.lua`: `decoration.blur` `enabled = true, size = 8, passes = 2` | on (Omarchy turns it off) |

Keep `"transparent": false` in `shell.json`. `true` makes the bar **fully clear** (no fill at all). The partial glass comes from `background-alpha`.

After editing the template:

```bash
omarchy theme refresh
```

Because the template is a user override, the 0.55 survives every theme switch. One catch: a theme may ship its own `shell.toml`, which replaces the generated one. If you want the alpha to win even then, put it in `~/.config/omarchy/shell.toml` instead (see below). Keys there override the theme's.

---

## Shell font size

**Repo:** `omarchy/shell.toml` → **Live:** `~/.config/omarchy/shell.toml`

```toml
[font]
base-size = 14
```

`base-size` is the root of the shell's type scale (stock: 12). Every bar, menu and notification text size derives from it. This file layers on top of the active theme, so it survives theme switches, and the shell watches it, so text re-flows as soon as you save. No restart needed.

Omarchy's own knob for this is:

```bash
omarchy display text size        # show current shell, GTK and terminal sizes
omarchy display text size 14     # set 9–20 px
omarchy display text size reset
```

It writes the same `[font] base-size` line, **and** changes GTK text scaling **and** rewrites the font size in your terminal configs (Alacritty, Kitty, Ghostty, foot) to match (px × 9/12, rounded: 14 px → 11 pt, which happens to equal this rice's Alacritty size). If you only want the shell text bigger and your terminal sizes left alone, edit `shell.toml` by hand instead.

## Fonts

```bash
omarchy font list
omarchy font current             # JetBrainsMono Nerd Font here
omarchy font set "JetBrainsMono Nerd Font"
```

`omarchy font set` changes the system monospace font, including the `family` lines in `~/.config/alacritty/alacritty.toml` and Kitty's `font_family`. It does **not** change the hy3 tab font, which is set separately in `hypr/looknfeel.lua` (`text_font = "JetBrainsMono Nerd Font"`, see [Look and Feel](Look-and-Feel)).

Terminal fonts: see [Terminal (Alacritty)](Terminal-Alacritty).

---

## GTK and Qt apps

`omarchy theme set` also sets GTK's dark/light mode (`org.gnome.desktop.interface color-scheme` and `gtk-theme`, `Adwaita-dark` for dark themes). Check:

```bash
gsettings get org.gnome.desktop.interface color-scheme
gsettings get org.gnome.desktop.interface gtk-theme
```

Force dark without changing the Omarchy theme:

```bash
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
```

Qt apps (Dolphin, Konsole) follow GTK because Omarchy sets `QT_QPA_PLATFORMTHEME=gtk3` (`/usr/share/omarchy/default/hypr/envs.lua`). Reopen apps to pick up changes.

### Viewnior and other X11 GTK apps

Viewnior on Wayland can be flaky. Force X11 with a **user** desktop file:

```bash
cp /usr/share/applications/viewnior.desktop ~/.local/share/applications/viewnior.desktop
# change the Exec line to:
# Exec=env GDK_BACKEND=x11 GTK_THEME=Adwaita:dark /usr/bin/viewnior %F
update-desktop-database ~/.local/share/applications
```

X11 GTK reads `~/.config/gtk-3.0/settings.ini` (create it if missing):

```ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=1
gtk-icon-theme-name=Yaru-purple
```

Viewnior's image canvas is separate from the GTK theme. Close Viewnior first, then set:

```ini
# ~/.config/viewnior/viewnior.conf
dark-background=true
```

Or use **View → Dark background** in the app.

---

## Wallpaper slideshow

Omarchy's own way to change the background:

```bash
omarchy theme bg next                    # next background of the current theme
omarchy theme bg set <path-to-image>
omarchy theme bg-switcher
```

Extra backgrounds for a theme go in `~/.config/omarchy/backgrounds/<theme-slug>/`.

This rice adds a **wallpaper slideshow** on top of that (repo folder `wallpaper/`, installed by `install.sh`; details in [Wallpaper Widget](Wallpaper-Widget)):

| Path | Role |
|------|------|
| `~/.local/bin/wallpaper-slideshow` | Script: `--next`, `--prev`, `--toggle`, `--pause`, `--resume`, `--status` (JSON), `--loop` |
| `~/.config/wallpaper-slideshow.conf` | `WALLPAPER_DIR` (default `~/.Wallpapers`, searched recursively) and `INTERVAL_SEC` (default 300) |
| `~/.config/systemd/user/wallpaper-slideshow.service` | Runs `wallpaper-slideshow --loop` with the graphical session |

It walks the image folder in sorted order and sets each one with `omarchy theme bg set`. Pause/resume simply stops/starts the service.

```bash
$EDITOR ~/.config/wallpaper-slideshow.conf
systemctl --user restart wallpaper-slideshow.service
systemctl --user status wallpaper-slideshow.service
wallpaper-slideshow --status | jq .
```

**Bar buttons:** [Wallpaper Widget](Wallpaper-Widget) (prev / pause / next, plus scroll).

---

## Default AI agent

**Repo:** `omarchy/defaults/agent` → **Live:** `~/.config/omarchy/defaults/agent`  
**Shipped:** `claude` (Claude Code)

One word in a file. Omarchy's `omarchy agent` command, the menu, and the right-click on the bar's `omarchy.agents` widget launch this agent. Change it the Omarchy way:

```bash
omarchy default agent            # print the current one
omarchy default agent codex      # set it (and install it if missing, then launch it)
```

Accepted names: `pi`, `omp`, `opencode`, `claude`, `codex`, `grok`, `gemini`, `openclaw`, `hermes`, `copilot`, `crush`, `cursor-agent`, `muse`. Delete the file and Omarchy picks no agent; `omarchy agent` then tells you to choose one.

## Pitfalls

- **Edited a file in `~/.local/state/omarchy/current/theme/` and it came back.** That folder is regenerated on every theme switch. Edit the template or an overlay instead.
- **Edited `/usr/share/omarchy/themes/…`.** Lost on the next update. Use an overlay.
- **Bar went solid after switching theme.** The new theme ships its own `shell.toml`. Put `[bar] background-alpha = 0.55` in `~/.config/omarchy/shell.toml`.
- **Terminal font size jumped.** `omarchy display text size` rewrote it. Set it back in the terminal config.
