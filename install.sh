#!/usr/bin/env bash
# Install these Hyprland / Omarchy-shell user configs.
# Works on Omarchy OS and on baseline Arch after the Omarchy stack is layered on.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${OMARCHY_DOTFILES_BACKUP:-$HOME/.config/omarchy-dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
DRY_RUN=0
WITH_HY3=1
WITH_CONKY=0
TARGET="auto" # auto | omarchy | arch

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install Mahmoud's desktop configs into ~/.config (Hyprland + Omarchy shell/bar).

Targets:
  --target auto      Detect Omarchy OS vs baseline Arch (default)
  --target omarchy   Assume a full Omarchy install
  --target arch      Baseline Arch that already has the Omarchy stack
                     (run scripts/setup-arch-omarchy-stack.sh first)

Options:
  --dry-run          Print actions only
  --skip-hy3         Do not install/enable the hy3 Hyprland plugin
  --with-conky       Also clone lean-conky-config into ~/.config/conky
  -h, --help         Show this help

Safe locations only — never writes under /usr/share/omarchy/.
Existing files are copied to a timestamped backup under ~/.config/.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-hy3) WITH_HY3=0; shift ;;
    --with-conky) WITH_CONKY=1; shift ;;
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

if [[ "$WITH_CONKY" -eq 1 ]]; then
  echo "==> Lean Conky Config"
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
  # Optional: yay -S hypr-kblayoutd-bin voxtype-bin
EOF
else
  cat <<'EOF'
  sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox \
    viewnior gwenview
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
echo "  1. Edit ~/.config/hypr/monitors.lua and input.lua for *this* machine."
echo "  2. README.md → “How to edit each feature”."
if [[ "$TARGET" == "arch" ]]; then
  echo "  3. Arch notes: docs/arch-linux.md"
fi
echo "  4. Deep hy3 / i3 keymap guide: docs/hypr-i3-setup.md"
echo "  Backup of previous configs: $BACKUP_ROOT"
