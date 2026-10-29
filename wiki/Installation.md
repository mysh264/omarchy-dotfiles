# Installation

Two paths: **Omarchy OS** (native) or **baseline Arch** (layer Omarchy's desktop packages on top, keep your own bootloader).

If you would rather build it by hand and learn each piece, see [Build This Rice](Build-This-Rice). Coming from i3? Read [Coming from i3](Coming-from-i3) alongside this page.

## Prerequisites (both paths)

- Git, sudo, a working network, `curl` (for the TildaZ installer)
- Willingness to edit `monitors.lua` / `input.lua` for *this* machine

Clone once:

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
chmod +x install.sh scripts/setup-arch-omarchy-stack.sh
```

---

## Path A: Omarchy OS

### Apps the keys launch

The keymap launches Konsole (Super+Return), Kitty (Super+Shift+Return), Brave / Firefox (Super+J / Super+Shift+J), Dolphin (Super+N), and assigns Viewnior / Gwenview to workspace 6. Install whatever you are missing:

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave-bin firefox \
  viewnior gwenview
```

`brave-bin` comes from the Omarchy repo; there is no package called plain `brave`.

### Install the rice

```bash
./install.sh                    # backup + copy + hy3 + wallpaper slideshow + TildaZ
# ./install.sh --dry-run        # print every action, change nothing
# ./install.sh --with-conky     # also clone Lean Conky (Wayland)
# ./install.sh --skip-hy3       # do not touch the hy3 plugin
# ./install.sh --skip-tildaz    # do not install TildaZ (dropdown terminal)
# ./install.sh --skip-wallpaper # do not install the wallpaper slideshow
```

### Adapt it to this laptop

```bash
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
omarchy restart shell
```

---

## Path B: Arch / EndeavourOS / CachyOS

Stock Arch-family installs do **not** ship Omarchy's shell or its Lua helpers (`o.bind`, `o.window`, …). Run the stack script once, then the rice installer.

```bash
# 1) Layer Omarchy desktop packages (keeps YOUR bootloader, no Limine)
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

Full detail: [Arch Linux](Arch-Linux) · in-repo [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md) · package list [`packages.arch.txt`](https://github.com/mysh264/omarchy-dotfiles/blob/main/packages.arch.txt)

---

## What `install.sh` does

In order:

| Step | Action |
|------|--------|
| Detect target | `auto` → Omarchy OS, or Arch with the Omarchy stack. Stops if `/usr/share/omarchy` is missing |
| Backup | Copies every file it is about to replace to `~/.config/omarchy-dotfiles-backup-YYYYMMDD-HHMMSS/` |
| Hyprland | Copies `hypr/` → `~/.config/hypr/` |
| Omarchy shell | Copies `shell.json`, `shell.toml`, `themed/shell.toml.tpl`, `extensions/`, `defaults/`, `bar/`, and the plugins `mahmoud.bar`, `mahmoud.network`, `mahmoud.workspaces` → `~/.config/omarchy/` |
| Alacritty | Copies `alacritty/alacritty.toml` |
| Arch only | Writes `~/.config/environment.d/99-omarchy-dotfiles.conf` (`OMARCHY_PATH` + `PATH`) |
| hy3 | `hyprpm add https://github.com/outfoxxed/hy3`, `enable`, `update`, `reload` (skip with `--skip-hy3`) |
| Wallpaper slideshow | `wallpaper/wallpaper-slideshow` → `~/.local/bin/`, `wallpaper-slideshow.conf` → `~/.config/` (only if you have none), the service → `~/.config/systemd/user/`, creates `~/.Wallpapers`, enables the service (skip with `--skip-wallpaper`). The bar's wallpaper buttons drive it: [Wallpaper Widget](Wallpaper-Widget) |
| TildaZ | See below (skip with `--skip-tildaz`) |
| Conky | Only with `--with-conky`: clones [lean-conky-config](https://github.com/mysh264/lean-conky-config) into `~/.config/conky` |
| Reload | `hyprctl reload`, `hyprctl configerrors`, `omarchy restart shell` |

**It never writes under `/usr/share/omarchy/`.**

### The TildaZ step

[TildaZ](https://github.com/ensky0/tildaz) (by ensky0) is the Quake-style dropdown terminal. The installer:

1. Copies the repo's `tildaz/config_0.toml` → `~/.config/tildaz/config_0.toml` first, so the very first run already uses **F1**, the font and the size.
2. If `tildaz` is not on `PATH` and not in `~/.local/bin/`, runs the official installer. It is user-local, needs no sudo, and checks the SHA-256:
   ```bash
   curl -LsSf https://tildaz.dev/install.sh | sh
   ```
   It unpacks into `~/.local/share/tildaz/`, links `~/.local/bin/tildaz`, and starts TildaZ once. Read it first if you like: [docs/install.sh](https://github.com/ensky0/tildaz/blob/main/docs/install.sh). A failed download only prints a warning; the rest of the install carries on.
3. Runs `tildaz --desktop add`. That writes `~/.config/hypr/tildaz.lua`, a small autostart file with this machine's TildaZ path. `hyprland.lua` loads it at the end with `pcall(require, "tildaz")`, so a machine without TildaZ is fine. This file is machine-local and **not** in the repo.

`tildaz --desktop remove` undoes step 3.

What `config_0.toml` sets: hotkey `F1`, `/usr/bin/bash`, theme `Tilda`, DejaVu Sans Mono 15, docked top, 95% wide, 50% high, 90% opacity. The blur and slide-in come from a Hyprland layer rule in `hypr/looknfeel.lua`. Extra toggle keys (Favorites key, KP Delete, mouse forward) are in `hypr/bindings.lua`. Details: [Dropdown Terminal](Dropdown-Terminal).

### Flags

```text
--target auto|omarchy|arch   default auto
--dry-run                    print actions only
--skip-hy3                   do not install/enable hy3
--with-conky                 also clone lean-conky-config
--skip-tildaz                do not install TildaZ
--skip-wallpaper             do not install the wallpaper slideshow
-h, --help
```

---

## Optional extras

```bash
# Per-window keyboard language (AUR)
# yay -S hypr-kblayoutd-bin
# systemctl --user enable --now hypr-kblayoutd.service

# Lean Conky without the install flag
git clone https://github.com/mysh264/lean-conky-config.git ~/.config/conky
cp ~/.config/conky/local.conf.wayland.example ~/.config/conky/local.conf
~/.config/conky/start-lcc.sh -n
```

---

## After-install checklist

Log out and back in once: hy3 and TildaZ both start from login autostart.

1. [ ] `hyprpm list` shows hy3 enabled
2. [ ] `hyprctl getoption general:layout` → `hy3` (it is `dwindle` for a moment at cold start, on purpose)
3. [ ] `hyprctl configerrors` prints nothing
4. [ ] Bar visible at the bottom with named workspaces (`omarchy restart shell` if not)
5. [ ] **F1** drops TildaZ down from the top; `ls ~/.config/hypr/tildaz.lua` exists
6. [ ] Monitors and keyboard layouts match this machine (Win+Space switches US / Arabic)
7. [ ] Skim the [Keybinding Cheatsheet](Keybinding-Cheatsheet)

If anything is off: [Troubleshooting](Troubleshooting).
