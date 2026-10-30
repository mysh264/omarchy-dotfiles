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
2. Trusts Omarchy's packaging key the same way Omarchy's own `omarchy-update-keyring` does, then installs `omarchy-keyring`
3. On anything that is not Omarchy OS, adds the [safeguards](#safeguards-for-arch-endeavouros-and-cachyos) below
4. Installs `omarchy` and the desktop deps without Limine / Snapper
5. Installs **Omarchy's full base package list** (`/usr/share/omarchy/install/omarchy-base.packages`, ~145 packages: terminal, Nautilus, fonts, bluetooth, audio, portals, Chromium, …). The `omarchy` package alone is only the shell, scripts and defaults; Omarchy OS installs the rest from its ISO, and without it most keys and menu entries do nothing. Boot packages (`plymouth`, Limine, Snapper, `kernel-modules-hook`) are skipped. pacman runs **without** `--noconfirm` here, so you answer any remaining prompt yourself. Packages on that list that conflict with something already installed are **skipped**, keeping your distro's version (CachyOS: `tealdeer` stays, because `cachyos-fish-config` needs it, and Omarchy's `tldr` is skipped; both give the `tldr` command). When pacman asks which repository to take a package from (`cachyos-extra-v4` or `extra`), press Enter: same package, CachyOS's build
6. Installs the Arch packages this rice expects (`hyprpm` plus `base-devel cmake meson cpio pkgconf git` to build hy3, `grim`, `slurp`, `wl-clipboard`, `jq`, `kitty`, `konsole`, `dolphin`, …), and tries `brave-bin`, `firefox`, `viewnior`, `gwenview` as optional
7. Writes `OMARCHY_PATH` + `PATH` into `~/.config/environment.d/`, `~/.bashrc`, and for fish `~/.config/fish/conf.d/omarchy-dotfiles.fish`
8. Copies Omarchy's default user configs from `/etc/skel` into your home, **missing files only** (`cp -rn`). Omarchy OS does this when it creates the user; an existing user on another distro never got it

Then:

```bash
./install.sh --target arch           # this rice
# log out, pick "Hyprland (uwsm-managed)", then in a Hyprland terminal:
omarchy-provision-first-run --force  # Omarchy's per-user setup: theme, user services, default apps
./scripts/doctor.sh                  # health report if anything is still off
```

`omarchy-provision-first-run` also runs by itself at the first Hyprland login. Run it again with `--force` if that login happened before all packages were in.

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

## Safeguards for Arch, EndeavourOS and CachyOS

The `omarchy` package depends on `omarchy-settings`, which is written for **Omarchy OS**. On another distro, two parts of it would hurt:

| What `omarchy-settings` does | Why it is a problem elsewhere | What the script does |
|---|---|---|
| Installs `/etc/mkinitcpio.conf.d/omarchy_hooks.conf`, which **replaces your initramfs `HOOKS`** with Omarchy's (`plymouth`, `encrypt`, `btrfs-overlayfs`, …) | `btrfs-overlayfs` comes from `limine-snapper-sync`, which is skipped; an ext4 or systemd-hook install needs different hooks. The next kernel update could build a broken initramfs and the machine may not boot | Adds a `NoExtract` line to `[options]` in `/etc/pacman.conf` for Omarchy's mkinitcpio and Limine drop-ins, so pacman never writes them. Backup: `/etc/pacman.conf.omarchy-dotfiles.bak` |
| Its install script **overwrites** `/etc/os-release`, `/etc/nsswitch.conf`, `/etc/security/faillock.conf`, `/etc/plymouth/plymouthd.conf`, `/etc/skel/.bashrc` and the cups files on **every** install and upgrade | Your distro would call itself "Omarchy", and its own settings would be replaced | Saves your copies once to `/etc/omarchy-dotfiles/distro-files/`, and installs a pacman hook (`/etc/pacman.d/hooks/omarchy-dotfiles-distro-guard.hook` → `/usr/local/lib/omarchy-dotfiles/restore-distro-files`) that puts them back after every `omarchy-settings` install or upgrade |
| Ships files your distro's own packages may own. On CachyOS: `/etc/skel/.config/alacritty/alacritty.toml`, owned by `cachyos-alacritty-config` (which `cachyos-kde-settings` requires) | pacman stops the whole install with `conflicting files`; removing the CachyOS package would break its KDE settings | Downloads the Omarchy packages first and finds every clash. Each clashing file is **shared**, nothing is removed: a `NoExtract` line keeps your distro's copy exactly as it is, and `--overwrite` for that one path lets the first install record it. pacman only checks files that are new in an upgrade, so later Omarchy updates do not stop on it again. Files no package owns stop the script with a list |

Still from `omarchy-settings` (left alone, usually harmless): a fontconfig default (`/etc/fonts/conf.d/50-omarchy.conf`), `/etc/profile.d/omarchy.sh`, an SDDM theme (only matters if you log in through SDDM), and defaults under `/etc/skel` for new users.

Check it after the install:

```bash
grep -A1 'omarchy-dotfiles: NoExtract' /etc/pacman.conf
ls /etc/mkinitcpio.conf.d/            # no omarchy_hooks.conf
cat /etc/os-release | head -3         # still your distro
ls /etc/pacman.d/hooks/omarchy-dotfiles-distro-guard.hook
```

If you ever remove `omarchy-settings`, pacman also deletes the shared files; reinstall the distro package that owned them (`sudo pacman -S cachyos-alacritty-config`).

To undo the safeguards (only after removing the Omarchy packages): delete the `omarchy-dotfiles` comment and the `NoExtract` lines under it from `[options]` in `/etc/pacman.conf`, then `sudo rm -r /etc/omarchy-dotfiles /usr/local/lib/omarchy-dotfiles /etc/pacman.d/hooks/omarchy-dotfiles-distro-guard.hook`.

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
| `omarchy-keyring: signature from "Omarchy <pkgs@omarchy.org>" is unknown trust` | The key was not trusted before the keyring package. Run the current script, or by hand: `sudo pacman-key --recv-keys 40DFB630FF42BCFFB047046CF0134EE680CAC571 --keyserver keys.openpgp.org`, `sudo pacman-key --lsign-key 40DFB630FF42BCFFB047046CF0134EE680CAC571`, then `sudo pacman -Sy omarchy-keyring`. Do not use `SigLevel = TrustAll` |
| `conflicting files: omarchy-settings: /etc/skel/.config/alacritty/alacritty.toml exists in filesystem (owned by cachyos-alacritty-config)` | Run the current script: it keeps CachyOS's file and shares it (see [safeguards](#safeguards-for-arch-endeavouros-and-cachyos)). Do not remove `cachyos-alacritty-config`: `cachyos-kde-settings` needs it |
| Nothing works in Hyprland: no shortcuts, no file manager, no bar | Run `./scripts/doctor.sh` inside Hyprland and look at the `[FAIL]` lines. Usual causes: Omarchy base packages missing (re-run the current setup script), `install.sh` not run (no `~/.config/hypr/hyprland.lua`), hy3 not built (most i3 keys are skipped until it loads: `hyprpm list`), first-run setup ran before the packages were in (`omarchy-provision-first-run --force`) |
| `removing tealdeer breaks dependency 'tealdeer' required by cachyos-fish-config` | Old copy of the setup script. `git pull` and run it again: it now skips Omarchy's `tldr` and keeps `tealdeer` |
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
