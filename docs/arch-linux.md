# Baseline Arch Linux

Use this path when the laptop runs **vanilla Arch**, **EndeavourOS**, **CachyOS**, or another Arch-based install that is **not** Omarchy OS, and you still want the same i3-style Hyprland, bar and keymap.

These configs use Omarchy's Lua helpers (`o.bind`, `o.window`, `o.exec_on_start`, …) and Omarchy's Quickshell bar. A stock Arch-family install has neither. You **layer the Omarchy desktop packages** on top once. You do **not** have to wipe the disk and install Omarchy OS.

After that one setup run, `./install.sh --target arch` applies this rice, the same as on Omarchy.

> **Credit:** Omarchy itself is © David Heinemeier Hansson and the Omarchy / Omacom team.  
> Upstream: [github.com/omacom/omarchy](https://github.com/omacom/omarchy) · [omarchy.org](https://omarchy.org)

The wiki version of this page: [Arch Linux](https://github.com/mysh264/omarchy-dotfiles/wiki/Arch-Linux).

---

## What stays yours vs what comes from Omarchy

| Piece | Source on Arch |
|-------|----------------|
| Bootloader (systemd-boot / GRUB / …) | **Yours**. Limine is never installed |
| Kernel, pacman, network | Arch |
| Hyprland, Quickshell, `omarchy-*` tools, Lua helpers | Omarchy packages from `pkgs.omarchy.org` |
| Keymap, bar layout, hy3, TildaZ dropdown | **This repo** (`./install.sh`) |

The `omarchy` package lists `limine`, `limine-mkinitcpio-hook`, `limine-snapper-sync` and `snapper` as dependencies. The setup script installs it with `--assume-installed` for each of those, so pacman treats them as present and does **not** touch your bootloader.

---

## Steps (recommended)

### 1. Normal Arch install

Install Arch the usual way (archinstall or manual). Set up networking and a user with sudo. A display manager is optional; the script installs SDDM.

```bash
sudo pacman -Syu
sudo pacman -S --needed base-devel git
```

### 2. Layer the Omarchy desktop stack

```bash
git clone https://github.com/mysh264/omarchy-dotfiles.git ~/Documents/GitHub/omarchy-dotfiles
cd ~/Documents/GitHub/omarchy-dotfiles
./scripts/setup-arch-omarchy-stack.sh --dry-run   # see what it would do
./scripts/setup-arch-omarchy-stack.sh
```

That script:

1. Appends the `[omarchy]` repo to `/etc/pacman.conf` (only if it is missing; the rest of the file is left alone)
2. Installs `omarchy-keyring` and runs `pacman-key --populate omarchy`
3. Installs `omarchy` and its desktop packages, with Limine/Snapper assumed installed
4. Writes `OMARCHY_PATH` + `PATH` into `~/.config/environment.d/99-omarchy-dotfiles.conf`, and the same into `~/.bashrc`
5. Installs the tools this rice expects (`hyprpm`, `grim`, `slurp`, `wl-clipboard`, `konsole`, `kitty`, `dolphin`, …) and tries the optional apps (`brave-bin`, `firefox`, `viewnior`, `gwenview`)

If `/usr/share/omarchy/bin/omarchy-shell` already exists, steps 1–3 are skipped.

Log out and back in (or reboot) so the `environment.d` file is picked up.

### 3. Apply this rice

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
./install.sh --target arch --dry-run
./install.sh --target arch
# optional:
# ./install.sh --target arch --with-conky
```

This copies `hypr/`, `omarchy/`, `alacritty/` and `tildaz/` into `~/.config/`, builds and enables hy3 with `hyprpm`, and installs [TildaZ](https://github.com/ensky0/tildaz) (the dropdown terminal) user-local with its official installer. `--skip-hy3` and `--skip-tildaz` leave those out.

### 4. Adapt this laptop

```bash
hyprctl monitors all
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua
hyprctl reload && hyprctl configerrors
```

`configerrors` should print nothing. Pick **Hyprland (uwsm-managed)** in your display manager and log in.

### 5. Check it worked

```bash
hyprpm list                       # hy3: enabled
hyprctl plugin list               # hy3 loaded
hyprctl getoption general:layout  # hy3
hyprctl layers | grep tildaz      # after pressing F1 once
```

`general:layout` reads `hy3` once the autostart reload has run. Right at login it can briefly be `dwindle`. That is on purpose: hy3 is loaded after the compositor is up, because loading it at cold start deadlocks NVIDIA. See [Hyprland Core](https://github.com/mysh264/omarchy-dotfiles/wiki/Hyprland-Core).

---

## Manual package list (if you prefer typing)

The full list with notes is in [`packages.arch.txt`](../packages.arch.txt).

Omarchy repo first (once):

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

Then the tools this rice uses:

```bash
sudo pacman -S --needed hyprland hyprpm hyprlock hypridle hyprsunset \
  xdg-desktop-portal-hyprland quickshell uwsm sddm \
  grim slurp wl-clipboard jq kitty konsole dolphin \
  pipewire wireplumber gnome-keyring
```

Do not add `ttf-jetbrains-mono-nerd`. `omarchy` already pulls in `ttf-jetbrains-mono-nerd-basic`, and the two packages conflict.

Environment (user):

```bash
mkdir -p ~/.config/environment.d
cat > ~/.config/environment.d/99-omarchy-dotfiles.conf <<'EOF'
OMARCHY_PATH=/usr/share/omarchy
PATH=/usr/share/omarchy/bin:${PATH}
EOF
```

Then log out and in, and run `./install.sh --target arch`.

---

## How this differs from Omarchy OS

| | Omarchy OS | Arch + this repo |
|--|------------|------------------|
| Installer / branding | Omarchy ISO | Arch ISO |
| Updates | `omarchy update` | `pacman -Syu` (includes the `[omarchy]` repo) |
| Bootloader | Limine + Snapper | Whatever you chose |
| Desktop look | Stock Omarchy + this rice | Same rice after install |
| Themes / menu / shell | Full Omarchy | Same packages, fewer first-run invitations |

Some Omarchy menu entries assume Omarchy-only tooling and may do nothing. The keymap, hy3 tabs, bar, dropdown terminal, screenshots and Conky are what this repo focuses on, and they work the same on both.

---

## Editing features on Arch

Same files as on Omarchy. Every feature has its own wiki page: [wiki Home](https://github.com/mysh264/omarchy-dotfiles/wiki).

- Keys → `~/.config/hypr/bindings.lua` ([Keybindings](https://github.com/mysh264/omarchy-dotfiles/wiki/Keybindings))
- Gaps, blur, hy3 tabs → `~/.config/hypr/looknfeel.lua` ([Look and Feel](https://github.com/mysh264/omarchy-dotfiles/wiki/Look-and-Feel))
- Bar → `~/.config/omarchy/shell.json` ([Status Bar](https://github.com/mysh264/omarchy-dotfiles/wiki/Status-Bar))
- Autostart → `~/.config/hypr/autostart.lua` ([Autostart](https://github.com/mysh264/omarchy-dotfiles/wiki/Autostart))
- Dropdown terminal → `~/.config/tildaz/config_0.toml` ([Dropdown Terminal](https://github.com/mysh264/omarchy-dotfiles/wiki/Dropdown-Terminal))

After Lua edits:

```bash
hyprctl reload
hyprctl configerrors
```

---

## Troubleshooting (Arch-specific)

| Symptom | Fix |
|---------|-----|
| `omarchy: command not found` | `export PATH="/usr/share/omarchy/bin:$PATH"` for now, and log out and in so `environment.d` applies |
| Hyprland starts with an empty / default config | Check `~/.config/hypr/hyprland.lua` exists (`install.sh` copies it) and that your Hyprland reads Lua configs (`hyprctl version`; Omarchy 4.x ships one that does) |
| pacman wants to install Limine | Always pass the four `--assume-installed` flags shown above |
| pacman reports a conflict with `ttf-jetbrains-mono-nerd-basic` | Remove `ttf-jetbrains-mono-nerd` from your command; `omarchy` brings the font |
| Bar never appears | `omarchy-shell` must be running. Check `journalctl --user -b` and log in through the uwsm session |
| NVIDIA login hang | Keep hy3 loaded from autostart (as shipped). Do not `hl.plugin.load` hy3 in `hyprland.lua` |
| `F1` does nothing | `tildaz` must be installed (`~/.local/bin/tildaz`) and `~/.config/hypr/tildaz.lua` must exist. Run `tildaz --desktop add`, then log out and in |
| Screenshots do nothing | Install `grim`, `slurp`, `wl-clipboard` and `jq` (the focused-window script reads `hyprctl activewindow -j` with `jq`) |

More: [Troubleshooting](https://github.com/mysh264/omarchy-dotfiles/wiki/Troubleshooting).

---

## Updating

```bash
cd ~/Documents/GitHub/omarchy-dotfiles
git pull
./install.sh --target arch
sudo pacman -Syu              # includes pkgs.omarchy.org once configured
hyprpm update && hyprpm reload   # rebuild hy3 for the new Hyprland
```
