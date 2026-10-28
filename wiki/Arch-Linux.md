# Arch Linux (and EndeavourOS / CachyOS)

Use this when the machine is **not** Omarchy OS, but you still want the same Hyprland + bar + keymap.

Stock Arch-family installs do **not** include Omarchy’s Lua helpers or Quickshell bar. Layer the Omarchy **desktop packages** once — you do **not** need to wipe the disk or install the Omarchy ISO.

> Omarchy © DHH & Omacom · [omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org)

## What stays yours

| Piece | Source |
|-------|--------|
| Bootloader (systemd-boot / GRUB / …) | **Yours** — Limine is never installed |
| Kernel, pacman, network | Arch |
| Hyprland helpers, Quickshell, `omarchy-*` | Omarchy packages from `pkgs.omarchy.org` |
| Keymap / bar / hy3 tweaks | This repo (`./install.sh`) |

The `omarchy` package lists Limine + Snapper as deps. `setup-arch-omarchy-stack.sh` installs with `--assume-installed limine,…` so pacman does **not** replace your bootloader.

## Steps

### 1. Normal Arch install

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git
```

### 2. Layer Omarchy desktop stack

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
./scripts/setup-arch-omarchy-stack.sh
```

The script:

1. Appends `[omarchy]` to `/etc/pacman.conf` (does not overwrite the whole file)  
2. Installs `omarchy-keyring` + desktop packages  
3. Skips Limine/Snapper  
4. Writes `OMARCHY_PATH` + `PATH` into `~/.config/environment.d/`  
5. Installs Hyprland tooling this rice expects (`hyprpm`, `grim`, …)  

**Log out / reboot** so `environment.d` applies.

Flags: `--dry-run`, `--skip-keyring`.

### 3. Apply rice

```bash
./install.sh --target arch
# ./install.sh --target arch --with-conky
```

### 4. Per-laptop

```bash
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
```

Pick **Hyprland (uwsm-managed)** or **Hyprland** from your display manager.

### 5. hy3 check

```bash
hyprpm list
hyprctl plugin list
hyprctl getoption general:layout
```

Want hy3 enabled and `general:layout` = `hy3` after autostart reload (NVIDIA may briefly use dwindle on cold start — intentional).

## Editing features on Arch

Same files as Omarchy — see [Home](Home). After Lua edits: `hyprctl reload && hyprctl configerrors`.

## vs Omarchy OS

| | Omarchy OS | Arch + this repo |
|--|------------|------------------|
| Installer | Omarchy ISO | Arch ISO |
| Updates | `omarchy update` | `pacman -Syu` (+ Omarchy repo) |
| Bootloader | Limine + Snapper story | Whatever you chose |
| Desktop look | Stock + this rice | Same rice after install |

Some menu entries that assume Omarchy-only tooling may be quieter. Focus of this repo: keymap, hy3 tabs, bar, screenshots, Conky path.

## Arch-specific troubleshooting

| Symptom | Fix |
|---------|-----|
| `omarchy: command not found` | `export PATH="/usr/share/omarchy/bin:$PATH"`; re-login for `environment.d` |
| Empty / default Hyprland conf | Ensure `~/.config/hypr/hyprland.lua` exists; Hyprland 0.50+ loads `.lua` |
| pacman wants Limine | Always use the script’s `--assume-installed limine,…` flags |
| Bar never appears | `omarchy-shell` must run; check `journalctl --user -b` / uwsm session |
| NVIDIA login hang | Keep hy3 deferred to autostart; do not cold-load in `hyprland.lua` |

## Updating on Arch

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh --target arch
sudo pacman -Syu
hyprpm update && hyprpm reload
```

Also: in-repo [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md) · [`packages.arch.txt`](https://github.com/mysh264/omarchy-dotfiles/blob/main/packages.arch.txt)
