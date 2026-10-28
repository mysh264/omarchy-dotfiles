# Updating & Syncing

## Sync rice between laptops

### On the laptop that “owns” the config

```bash
# Copy live ~/.config files you changed back into the git clone, then:
cd ~/Documents/GitHub/omarchy-dotfiles
git add -A
git status
git commit -m "Sync from laptop"
git push
```

Typical paths to copy back:

- `~/.config/hypr/*.lua` (+ scripts/conf)  
- `~/.config/omarchy/shell.json`, `shell.toml`, `bar/`, `plugins/mahmoud.*`, `extensions/`, `themed/`, `defaults/`  
- `~/.config/alacritty/alacritty.toml`  

**Do not commit** machine-private secrets. Prefer keeping `monitors.lua` as a template or per-host notes in the commit message.

### On the other laptop

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh          # or --target arch
# re-check monitors.lua / input.lua
```

Installer backs up replaced files under `~/.config/omarchy-dotfiles-backup-…`.

## After Omarchy or Hyprland upgrades

```bash
hyprpm update && hyprpm reload
hyprctl plugin list
hyprctl configerrors
omarchy restart shell
```

hy3 **must** be rebuilt for the running Hyprland commit. If binds die after an upgrade, `hyprpm update` is the first fix.

## Refresh cloned plugins from upstream

```bash
omarchy plugin clone omarchy.bar
omarchy plugin clone omarchy.network
# merge or retarget shell.json ids — see Plugins
omarchy restart shell
```

## Pull wiki / docs

This wiki lives at `https://github.com/mysh264/omarchy-dotfiles/wiki`.  
Long-form rebuild guide remains in-repo: `docs/hypr-i3-setup.md`.
