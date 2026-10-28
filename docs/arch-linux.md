# Baseline Arch Linux

Use this path when the laptop is **vanilla Arch**, **EndeavourOS**, **CachyOS**, or another Arch-based install that is **not** Omarchy OS, and you still want the same Hyprland + bar + keymap as on Omarchy.

These configs speak Omarchy’s Lua helpers (`o.bind`, `o.window`, …) and launch Omarchy’s Quickshell bar. On those distros you **layer the Omarchy desktop packages** on top — you do **not** have to wipe the disk and install Omarchy OS.

Stock EndeavourOS / CachyOS / Arch do **not** include that stack. One setup script run is required; after that, `./install.sh --target arch` applies this rice.

> **Credit:** Omarchy itself is © David Heinemeier Hansson and the Omarchy / Omacom team.  
> Upstream: [github.com/omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org)

---

## What stays yours vs what comes from Omarchy

| Piece | Source on Arch |
|-------|----------------|
| Bootloader (systemd-boot / GRUB / …) | **Yours** — we never install Limine |
| Kernel, pacman, network | Arch |
| Hyprland, Quickshell, `omarchy-*` tools, Lua helpers | Omarchy packages from `pkgs.omarchy.org` |
| This keymap / bar layout / hy3 tweaks | **This repo** (`./install.sh`) |

The official `omarchy` package lists Limine + Snapper as dependencies. The setup script installs `omarchy` with `--assume-installed limine,…` so pacman does **not** replace your bootloader.

---

## Steps (recommended)

### 1. Normal Arch install

Install Arch the usual way (archinstall or manual). Enable a display manager (SDDM is fine), networking, and a user with sudo.

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git
```

### 2. Layer the Omarchy desktop stack

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
chmod +x scripts/setup-arch-omarchy-stack.sh install.sh
./scripts/setup-arch-omarchy-stack.sh
```

That script:

1. Appends the `[omarchy]` repo to `/etc/pacman.conf` (does not overwrite the whole file)
2. Installs `omarchy-keyring` and the Omarchy desktop packages
3. Skips Limine/Snapper so your existing bootloader stays
4. Writes `OMARCHY_PATH` + `PATH` into `~/.config/environment.d/`
5. Installs Hyprland tooling this rice expects (`hyprpm`, `grim`, …)

Log out and back in (or reboot) so the environment.d file is picked up.

### 3. Apply this rice

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
./install.sh --target arch
# optional:
# ./install.sh --target arch --with-conky
```

### 4. Adapt this laptop

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

You want hy3 enabled and `general:layout` = `hy3` after the autostart reload (NVIDIA: cold start may briefly use dwindle — that is intentional).

---

## Manual package list (if you prefer typing)

Core Arch:

```bash
sudo pacman -S --needed hyprland hyprpm hyprlock hypridle hyprsunset \
  xdg-desktop-portal-hyprland quickshell uwsm sddm \
  grim slurp wl-clipboard jq kitty konsole dolphin \
  pipewire wireplumber gnome-keyring ttf-jetbrains-mono-nerd
```

Omarchy repo (once):

```bash
# Append to /etc/pacman.conf:
# [omarchy]
# SigLevel = Required DatabaseOptional
# Server = https://pkgs.omarchy.org/stable/$arch

sudo pacman -Sy omarchy-keyring
sudo pacman-key --populate omarchy
sudo pacman -S --needed \
  --assume-installed limine \
  --assume-installed limine-mkinitcpio-hook \
  --assume-installed limine-snapper-sync \
  --assume-installed snapper \
  omarchy
```

Environment (user):

```bash
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/99-omarchy-dotfiles.conf <<'EOF'
OMARCHY_PATH=/usr/share/omarchy
PATH=/usr/share/omarchy/bin:${PATH}
EOF
```

Then `./install.sh --target arch`.

---

## How this differs from Omarchy OS

| | Omarchy OS | Arch + this repo |
|--|------------|------------------|
| Installer / branding | Omarchy ISO | Arch ISO |
| Updates | `omarchy update` | `pacman -Syu` (+ Omarchy repo packages) |
| Bootloader | Limine + Snapper story | Whatever you chose |
| Desktop look | Stock Omarchy + this rice | Same rice after install |
| Themes / menu / shell | Full Omarchy | Same packages, fewer “first-run” invitations |

Some Omarchy menu entries that assume Omarchy-only tooling may be quieter or no-ops. The Hyprland keymap, hy3 tabs, bar, screenshots, and Conky path are what this repo focuses on.

---

## Editing features on Arch

Same files as on Omarchy — see the main [README](../README.md#how-to-edit-each-feature):

- Keys → `~/.config/hypr/bindings.lua`
- Gaps / hy3 glass → `~/.config/hypr/looknfeel.lua`
- Bar → `~/.config/omarchy/shell.json`
- Autostart → `~/.config/hypr/autostart.lua`

After Lua edits:

```bash
hyprctl reload
hyprctl configerrors
```

---

## Troubleshooting (Arch-specific)

| Symptom | Fix |
|---------|-----|
| `omarchy: command not found` | `export PATH="/usr/share/omarchy/bin:$PATH"` and re-login so `environment.d` applies |
| Hyprland starts with empty / default conf | Ensure `~/.config/hypr/hyprland.lua` exists (copied by `install.sh`); Hyprland 0.50+ loads `.lua` |
| pacman wants to install Limine | Always pass the `--assume-installed limine,…` flags from the script |
| Bar never appears | `omarchy-shell` must be running; check `journalctl --user -b` / start via uwsm session |
| NVIDIA login hang | Keep hy3 deferred to autostart (as shipped); do not `hl.plugin.load` hy3 in cold-start `hyprland.lua` |
| Screenshots notify nothing | `grim` + `wl-clipboard` installed; notify falls back to `notify-send` if Omarchy notify is missing |

---

## Updating

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh --target arch
sudo pacman -Syu   # includes pkgs.omarchy.org when configured
hyprpm update && hyprpm reload
```
