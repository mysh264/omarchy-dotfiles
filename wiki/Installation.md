# Installation

Two paths: **Omarchy OS** (native) or **baseline Arch** (layer Omarchy desktop packages, keep your bootloader).

## Prerequisites (both)

- Git, sudo, working network  
- Willingness to edit `monitors.lua` / `input.lua` for *this* machine  

Clone once:

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
chmod +x install.sh scripts/setup-arch-omarchy-stack.sh
```

---

## Path A — Omarchy OS

### Suggested packages

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox \
  viewnior gwenview
```

### Install rice

```bash
./install.sh                 # backup + copy + enable hy3
# ./install.sh --with-conky  # also clone Lean Conky (Wayland)
# ./install.sh --dry-run     # preview only
# ./install.sh --skip-hy3    # skip hy3 plugin
```

### Adapt this laptop

```bash
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
omarchy restart shell
```

---

## Path B — Arch / EndeavourOS / CachyOS

Stock Arch-family installs do **not** ship Omarchy’s shell/Lua helpers. Run the stack script once, then the rice installer.

```bash
# 1) Layer Omarchy desktop packages (keeps YOUR bootloader — no Limine)
./scripts/setup-arch-omarchy-stack.sh
# log out / reboot so ~/.config/environment.d is loaded

# 2) Apply this rice
./install.sh --target arch
# ./install.sh --target arch --with-conky

# 3) Per-laptop tweaks
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
```

Full detail: [Arch Linux](Arch-Linux) · in-repo [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md)

Package checklist: [`packages.arch.txt`](https://github.com/mysh264/omarchy-dotfiles/blob/main/packages.arch.txt)

---

## What `install.sh` does

| Step | Action |
|------|--------|
| Detect target | `auto` → Omarchy OS vs Arch with Omarchy stack |
| Backup | Copies existing targets under `~/.config/omarchy-dotfiles-backup-…` |
| Hyprland | Copies `hypr/` → `~/.config/hypr/` |
| Omarchy | Copies shell.json, shell.toml, themed tpl, extensions, defaults, bar/, plugins |
| Alacritty | Copies font config if present |
| Arch only | Writes `~/.config/environment.d/99-omarchy-dotfiles.conf` |
| hy3 | `hyprpm add/enable/update/reload` (unless `--skip-hy3`) |
| Conky | Optional clone of [lean-conky-config](https://github.com/mysh264/lean-conky-config) |
| Reload | `hyprctl reload` + `omarchy restart shell` |

**Never writes under `/usr/share/omarchy/`.**

### Flags

```text
--target auto|omarchy|arch
--dry-run
--skip-hy3
--with-conky
-h, --help
```

---

## Optional extras

```bash
# Per-window keyboard language (AUR)
# yay -S hypr-kblayoutd-bin
# systemctl --user enable --now hypr-kblayoutd.service

# Lean Conky without install flag
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
~/.config/conky/start-lcc.sh -n
```

---

## After install checklist

1. [ ] `hyprpm list` shows hy3 enabled  
2. [ ] After login + autostart reload: `hyprctl getoption general:layout` → hy3  
3. [ ] `hyprctl configerrors` empty  
4. [ ] Bar visible (`omarchy restart shell` if not)  
5. [ ] Monitors / keyboard layouts match this machine  
6. [ ] Skim [Keybinding Cheatsheet](Keybinding-Cheatsheet)
