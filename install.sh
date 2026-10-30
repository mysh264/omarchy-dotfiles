#!/usr/bin/env bash
# Install these i3-style Hyprland / Omarchy shell user configs into ~/.config,
# plus hy3 (hyprpm) and the TildaZ dropdown terminal (user-local, no sudo).
# Works on Omarchy OS and on baseline Arch after the Omarchy stack is layered on
# (scripts/setup-arch-omarchy-stack.sh). Never writes under /usr/share/omarchy/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${OMARCHY_DOTFILES_BACKUP:-$HOME/.config/omarchy-dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
DRY_RUN=0
WITH_HY3=1
WITH_CONKY=0
WITH_TILDAZ=1
WITH_WALLPAPER=1
TARGET="auto" # auto | omarchy | arch

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install Mahmoud's i3-style desktop configs into ~/.config:
Hyprland (hypr/), Omarchy shell/bar (omarchy/), Alacritty, and TildaZ.
Also enables the hy3 plugin and installs TildaZ unless you skip them.

Targets:
  --target auto      Detect Omarchy OS vs baseline Arch (default)
  --target omarchy   Assume a full Omarchy install
  --target arch      Baseline Arch that already has the Omarchy stack
                     (run scripts/setup-arch-omarchy-stack.sh first)

Options:
  --dry-run          Print actions only, change nothing
  --skip-hy3         Do not add/enable/build the hy3 plugin with hyprpm
  --skip-tildaz      Do not install TildaZ (dropdown terminal) or copy its config
  --skip-wallpaper   Do not install the wallpaper slideshow the bar widget controls
  --with-conky       Also clone lean-conky-config into ~/.config/conky
  -h, --help         Show this help

Safe locations only — never writes under /usr/share/omarchy/.
Existing files are copied to a timestamped backup under ~/.config/
(override with OMARCHY_DOTFILES_BACKUP=/some/dir).
Docs: https://github.com/mysh264/omarchy-dotfiles/wiki
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-hy3) WITH_HY3=0; shift ;;
    --with-conky) WITH_CONKY=1; shift ;;
    --skip-tildaz) WITH_TILDAZ=0; shift ;;
    --skip-wallpaper) WITH_WALLPAPER=0; shift ;;
    --target)
      TARGET="${2:-}"
      shift 2
      case "$TARGET" in auto|omarchy|arch) ;; *)
        echo "Invalid --target: $TARGET (use auto|omarchy|arch)" >&2
        exit 1
      esac
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run]'; printf ' %q' "$@"; printf '\n'
  else
    "$@"
  fi
}

backup_then_copy() {
  local src="$1" dest="$2"
  if [[ -e "$dest" || -L "$dest" ]]; then
    local rel="${dest#"$HOME"/}"
    local bak="$BACKUP_ROOT/$rel"
    run mkdir -p "$(dirname "$bak")"
    run cp -a "$dest" "$bak"
  fi
  run mkdir -p "$(dirname "$dest")"
  if [[ -d "$src" ]]; then
    run mkdir -p "$dest"
    run cp -a "$src"/. "$dest"/
  else
    run cp -a "$src" "$dest"
  fi
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing command: $1" >&2
    exit 1
  }
}

detect_target() {
  if [[ -d /usr/share/omarchy && -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    if grep -qi omarchy <<<"${NAME:-}${ID:-}${ID_LIKE:-}"; then
      echo omarchy
      return
    fi
    # Omarchy packages on plain Arch still look like this
    if [[ -x /usr/share/omarchy/bin/omarchy-shell ]]; then
      echo arch
      return
    fi
  fi
  if [[ -d /usr/share/omarchy ]]; then
    echo omarchy
    return
  fi
  echo missing
}

if [[ "$TARGET" == "auto" ]]; then
  TARGET="$(detect_target)"
fi

if [[ "$TARGET" == "missing" ]]; then
  cat >&2 <<'EOF'
No Omarchy stack found (/usr/share/omarchy missing).

  • On Omarchy OS: you already have it — something is wrong with PATH/install.
  • On baseline Arch Linux:
      ./scripts/setup-arch-omarchy-stack.sh
      ./install.sh --target arch

See docs/arch-linux.md
EOF
  exit 1
fi

export OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
export PATH="$OMARCHY_PATH/bin:$PATH"

need_cmd hyprctl
if ! command -v omarchy >/dev/null 2>&1 && ! command -v omarchy-shell >/dev/null 2>&1; then
  echo "Omarchy binaries not on PATH. Export OMARCHY_PATH=/usr/share/omarchy and" >&2
  echo "PATH=\"\$OMARCHY_PATH/bin:\$PATH\", or re-run scripts/setup-arch-omarchy-stack.sh" >&2
  exit 1
fi

echo "==> Target: $TARGET"
echo "==> Backup directory: $BACKUP_ROOT"

echo "==> Hyprland (~/.config/hypr)"
# Copies over the repo files only. Machine-local files such as tildaz.lua stay.
backup_then_copy "$ROOT/hypr" "$HOME/.config/hypr"
run chmod +x "$HOME/.config/hypr/scripts/screenshot-focused"

echo "==> Omarchy shell / bar (~/.config/omarchy)"
backup_then_copy "$ROOT/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"
backup_then_copy "$ROOT/omarchy/shell.toml" "$HOME/.config/omarchy/shell.toml"
backup_then_copy "$ROOT/omarchy/themed/shell.toml.tpl" "$HOME/.config/omarchy/themed/shell.toml.tpl"
backup_then_copy "$ROOT/omarchy/extensions" "$HOME/.config/omarchy/extensions"
backup_then_copy "$ROOT/omarchy/defaults" "$HOME/.config/omarchy/defaults"
backup_then_copy "$ROOT/omarchy/bar" "$HOME/.config/omarchy/bar"
run chmod +x "$HOME/.config/omarchy/bar/scripts/hw-stats"
backup_then_copy "$ROOT/omarchy/plugins/mahmoud.bar" "$HOME/.config/omarchy/plugins/mahmoud.bar"
backup_then_copy "$ROOT/omarchy/plugins/mahmoud.network" "$HOME/.config/omarchy/plugins/mahmoud.network"
backup_then_copy "$ROOT/omarchy/plugins/mahmoud.workspaces" "$HOME/.config/omarchy/plugins/mahmoud.workspaces"

if [[ -f "$ROOT/alacritty/alacritty.toml" ]]; then
  echo "==> Alacritty font size"
  backup_then_copy "$ROOT/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
fi

if [[ "$TARGET" == "arch" ]]; then
  echo "==> Arch session helpers"
  ENV_DIR="$HOME/.config/environment.d"
  ENV_FILE="$ENV_DIR/99-omarchy-dotfiles.conf"
  run mkdir -p "$ENV_DIR"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] ensure $ENV_FILE"
  else
    cat >"$ENV_FILE" <<'EOF'
OMARCHY_PATH=/usr/share/omarchy
PATH=/usr/share/omarchy/bin:${PATH}
EOF
  fi
fi

if [[ "$WITH_HY3" -eq 1 ]]; then
  echo "==> hy3 plugin"
  if ! command -v hyprpm >/dev/null 2>&1; then
    echo "hyprpm not found. Install with: sudo pacman -S hyprpm" >&2
    echo "(or re-run with --skip-hy3). Configs are already copied." >&2
    exit 1
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] hyprpm add/enable/update/reload hy3"
  else
    if ! hyprpm list 2>/dev/null | grep -q 'Repository hy3'; then
      hyprpm add https://github.com/outfoxxed/hy3 || true
    fi
    hyprpm enable hy3 || true
    hyprpm update || true
    hyprpm reload || true
  fi
fi

if [[ "$WITH_WALLPAPER" -eq 1 ]]; then
  echo "==> Wallpaper slideshow (drives the bar's wallpaper widget)"
  # Cycles images in ~/.Wallpapers through Omarchy's background setter.
  backup_then_copy "$ROOT/wallpaper/wallpaper-slideshow" "$HOME/.local/bin/wallpaper-slideshow"
  run chmod +x "$HOME/.local/bin/wallpaper-slideshow"
  if [[ ! -e "$HOME/.config/wallpaper-slideshow.conf" ]]; then
    # Keep an existing folder/interval choice; only seed it the first time.
    run cp "$ROOT/wallpaper/wallpaper-slideshow.conf" "$HOME/.config/wallpaper-slideshow.conf"
  fi
  backup_then_copy "$ROOT/wallpaper/wallpaper-slideshow.service" "$HOME/.config/systemd/user/wallpaper-slideshow.service"
  run mkdir -p "$HOME/.Wallpapers"
  run systemctl --user daemon-reload
  run systemctl --user enable --now wallpaper-slideshow.service || true
fi

if [[ "$WITH_TILDAZ" -eq 1 ]]; then
  echo "==> TildaZ dropdown terminal"
  # Config first, so the first run already uses F1, the font and the size.
  backup_then_copy "$ROOT/tildaz/config_0.toml" "$HOME/.config/tildaz/config_0.toml"
  if ! command -v tildaz >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/tildaz" ]]; then
    # Official installer: user-local, no sudo, checks the SHA-256.
    # Read it first if you like: https://github.com/ensky0/tildaz/blob/main/docs/install.sh
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] curl -LsSf https://tildaz.dev/install.sh | sh"
    else
      curl -LsSf https://tildaz.dev/install.sh | sh || echo "    TildaZ install failed — see https://tildaz.dev" >&2
    fi
  fi
  # Writes ~/.config/hypr/tildaz.lua (autostart at login), which hyprland.lua
  # loads with pcall(require, "tildaz"). "tildaz --desktop remove" undoes it.
  TILDAZ_BIN="$(command -v tildaz || echo "$HOME/.local/bin/tildaz")"
  if [[ -x "$TILDAZ_BIN" || "$DRY_RUN" -eq 1 ]]; then
    run "$TILDAZ_BIN" --desktop add || true
  else
    echo "    tildaz not found — run 'tildaz --desktop add' after installing it" >&2
  fi
fi

if [[ "$WITH_CONKY" -eq 1 ]]; then
  echo "==> Lean Conky Config"
  # The config only drives Conky; the program itself comes from your distro.
  # Without it start-lcc.sh stops with "Conky is not installed".
  if ! command -v conky >/dev/null 2>&1; then
    run sudo pacman -S --needed --noconfirm conky
  fi
  if [[ -e "$HOME/.config/conky" ]]; then
    echo "    ~/.config/conky already exists — skipping clone"
  else
    run git clone https://github.com/mysh264/lean-conky-config.git "$HOME/.config/conky"
    if [[ -f "$HOME/.config/conky/local.conf.wayland.example" ]]; then
      run cp "$HOME/.config/conky/local.conf.wayland.example" "$HOME/.config/conky/local.conf"
    fi
  fi
fi

echo "==> Suggested packages"
if [[ "$TARGET" == "arch" ]]; then
  cat <<'EOF'
  # Already mostly handled by scripts/setup-arch-omarchy-stack.sh
  # Optional: omarchy pkg aur add hypr-kblayoutd-bin   (uses yay)
  # Optional: sudo pacman -S voxtype-bin               (from the [omarchy] repo)
EOF
else
  cat <<'EOF'
  sudo pacman -S --needed hyprpm konsole kitty dolphin brave-bin firefox \
    viewnior gwenview
  # Optional: omarchy pkg aur add hypr-kblayoutd-bin   (per-window keyboard layout)
  # TildaZ (dropdown) is installed above unless you passed --skip-tildaz
EOF
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo "==> Reload Hyprland + shell"
  hyprctl reload || true
  hyprctl configerrors || true
  if command -v omarchy >/dev/null 2>&1; then
    omarchy restart shell 2>/dev/null || true
  elif command -v omarchy-shell >/dev/null 2>&1; then
    # Best-effort on Arch if the omarchy meta CLI is thin
    pkill -x omarchy-shell 2>/dev/null || true
    omarchy-shell >/dev/null 2>&1 &
  fi
fi

echo
echo "Done (target=$TARGET)."
echo "  1. Edit ~/.config/hypr/monitors.lua and input.lua for *this* machine,"
echo "     then: hyprctl reload && hyprctl configerrors"
echo "  2. Log out and back in once so hy3 and TildaZ start the way they do at login."
echo "  3. Wiki (every feature, how to change it): https://github.com/mysh264/omarchy-dotfiles/wiki"
echo "  4. Long i3 → hy3 guide: docs/hypr-i3-setup.md"
if [[ "$TARGET" == "arch" ]]; then
  echo "  5. Arch notes: docs/arch-linux.md"
fi
echo "  Backup of previous configs: $BACKUP_ROOT"
