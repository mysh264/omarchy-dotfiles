# Arch Linux (and EndeavourOS / CachyOS)

Use this when the machine is **not** Omarchy OS but you still want the same Hyprland, bar and i3 keymap.

Stock Arch-family installs do **not** include Omarchy's Lua helpers (`o.bind`, `o.window`, `o.exec_on_start`) or its Quickshell bar. Layer the Omarchy **desktop packages** once. You do **not** need to wipe the disk or install the Omarchy ISO.

> Omarchy © DHH & Omacom · [omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org)

## What stays yours

| Piece | Source |
|-------|--------|
| Bootloader (systemd-boot / GRUB / …) | **Yours**: Limine is never installed |
| Kernel, pacman, network | Arch |
| Hyprland helpers, Quickshell shell, `omarchy-*` commands | Omarchy packages from the `[omarchy]` repo |
| Keymap, bar, hy3, TildaZ | This repo (`./install.sh`) |

The `omarchy` package lists Limine and Snapper as dependencies. `setup-arch-omarchy-stack.sh` installs it with `--assume-installed limine`, `limine-mkinitcpio-hook`, `limine-snapper-sync` and `snapper`, so pacman does **not** replace your bootloader.

## Steps

### 1. Normal Arch install

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git
```

### 2. Layer the Omarchy desktop stack

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
./scripts/setup-arch-omarchy-stack.sh
```

The script:

1. Appends `[omarchy]` to `/etc/pacman.conf` (does not overwrite the file)
2. Installs `omarchy-keyring`
3. Installs `omarchy` and the desktop deps without Limine / Snapper
4. Writes `OMARCHY_PATH` + `PATH` into `~/.config/environment.d/`
5. Installs the Arch packages this rice expects (`hyprpm`, `grim`, `slurp`, `wl-clipboard`, `jq`, `kitty`, `konsole`, `dolphin`, …), and tries `brave-bin`, `firefox`, `viewnior`, `gwenview` as optional

**Log out / reboot** so `environment.d` applies.

Flags: `--dry-run`, `--skip-keyring`.

### 3. Apply the rice

```bash
./install.sh --target arch
# ./install.sh --target arch --with-conky
# ./install.sh --target arch --skip-tildaz
```

This also installs TildaZ (user-local, no sudo) and runs `tildaz --desktop add`. See [Installation](Installation).

### 4. Per-laptop

```bash
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
```

Pick **Hyprland (uwsm-managed)** or **Hyprland** from your display manager.

### 5. Check hy3 and TildaZ

After logging in:

```bash
hyprpm list                        # hy3 enabled
hyprctl plugin list                # hy3 loaded
hyprctl getoption general:layout   # hy3
ls ~/.config/hypr/tildaz.lua       # TildaZ autostart present
```

Press **F1** for the dropdown. The layout is `dwindle` for a moment at cold start; autostart loads hy3 and reloads. That is intentional (the NVIDIA rule in [Golden Rules](Golden-Rules)).

## Editing features on Arch

Same files as Omarchy OS; see [Home](Home). After Lua edits: `hyprctl reload && hyprctl configerrors`.

## vs Omarchy OS

| | Omarchy OS | Arch + this repo |
|--|------------|------------------|
| Installer | Omarchy ISO | Arch ISO |
| Updates | `omarchy update` | `sudo pacman -Syu` (with the `[omarchy]` repo) |
| Bootloader | Limine + Snapper | Whatever you chose |
| Desktop look | Stock + this rice | Same rice after install |

Some menu entries that assume Omarchy-only tooling may do less. The focus of this repo is the keymap, hy3 tabs, bar, TildaZ, screenshots and Conky.

## Arch-specific troubleshooting

| Symptom | Fix |
|---------|-----|
| `omarchy: command not found` | `export PATH="/usr/share/omarchy/bin:$PATH"`; re-login so `environment.d` loads |
| Empty / default Hyprland config | Make sure `~/.config/hypr/hyprland.lua` exists and your Hyprland is current (`sudo pacman -Syu`, then `hyprctl version`; this rice is tested on 0.56) |
| pacman wants Limine | Always use the script; it passes the `--assume-installed` flags |
| Bar never appears | `omarchy-shell` must run; check `journalctl --user -b` and the uwsm session |
| NVIDIA login hang | Keep hy3 deferred to autostart; never load it in `hyprland.lua` |
| F1 does nothing | `which tildaz`; if missing, `curl -LsSf https://tildaz.dev/install.sh \| sh` then `tildaz --desktop add` |

More: [Troubleshooting](Troubleshooting).

## Updating on Arch

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh --target arch
sudo pacman -Syu
hyprpm update && hyprpm reload
hyprctl configerrors
```

Also: in-repo [`docs/arch-linux.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/arch-linux.md) · [`packages.arch.txt`](https://github.com/mysh264/omarchy-dotfiles/blob/main/packages.arch.txt)
