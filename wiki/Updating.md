# Updating & Syncing

## Sync the rice between laptops

### On the laptop that "owns" the config

Copy the live files you changed back into the git clone, then commit:

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git add -A
git status
git commit -m "Sync from laptop"
git push
```

Typical paths to copy back:

| Live | Repo |
|------|------|
| `~/.config/hypr/*.lua`, `scripts/`, `*.conf` | `hypr/` |
| `~/.config/omarchy/shell.json`, `shell.toml`, `bar/`, `plugins/mahmoud.*`, `extensions/`, `themed/`, `defaults/` | `omarchy/` |
| `~/.config/tildaz/config_0.toml` | `tildaz/config_0.toml` |
| `~/.local/bin/wallpaper-slideshow`, `~/.config/wallpaper-slideshow.conf`, `~/.config/systemd/user/wallpaper-slideshow.service` | `wallpaper/` |
| `~/.config/alacritty/alacritty.toml` | `alacritty/` |

**Do not copy back** machine-local files: `~/.config/hypr/tildaz.lua` (written by `tildaz --desktop add` with this machine's path) and anything under `~/.local/state/omarchy/`. See [Repo Layout](Repo-Layout). Never commit secrets. Treat `monitors.lua` as per-host; note the host in the commit message if you change it.

Quick diff before copying:

```bash
diff -ru hypr ~/.config/hypr | less
diff -u tildaz/config_0.toml ~/.config/tildaz/config_0.toml
```

### On the other laptop

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh          # or: ./install.sh --target arch
# re-check monitors.lua / input.lua
```

The installer backs up replaced files under `~/.config/omarchy-dotfiles-backup-…` and skips the TildaZ download if TildaZ is already installed.

## After Omarchy or Hyprland upgrades

```bash
omarchy update        # Omarchy OS (Arch: sudo pacman -Syu)
hyprpm update && hyprpm reload
hyprctl plugin list
hyprctl reload && hyprctl configerrors
omarchy restart shell
```

hy3 **must** be rebuilt for the running Hyprland version. If hy3 binds die after an upgrade, `hyprpm update` is the first fix. An Omarchy update never touches your `~/.config/` files, but it can change the defaults they sit on top of, so run `configerrors` after every update.

## Refresh cloned plugins from upstream

Your `mahmoud.*` plugins are frozen copies. To pick up upstream changes, compare them with the stock source under `/usr/share/omarchy/shell/plugins/` (read only) and merge by hand. Re-running `omarchy plugin clone omarchy.workspaces` makes a fresh `$USER.workspaces` and switches the bar to it, so back up your copy first.

```bash
omarchy plugin list
omarchy restart shell
```

See [Plugins](Plugins).

## Update TildaZ

Re-run the official installer. It fetches the latest release into `~/.local/share/tildaz/` (your config lives separately in `~/.config/tildaz/`). If unsure, back up `config_0.toml` first; the repo has a copy anyway:

```bash
curl -LsSf https://tildaz.dev/install.sh | sh
tildaz --version
```

## Publishing this wiki

The wiki is the `wiki/` folder of the repo. `scripts/publish-wiki.sh` rsyncs it to the GitHub wiki repo (`https://github.com/mysh264/omarchy-dotfiles/wiki`). Links between pages use the page name with no `.md`, for example `[Status Bar](Status-Bar)`.

Long-form rebuild guide stays in-repo: `docs/hypr-i3-setup.md`.
