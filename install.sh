#!/usr/bin/env bash
# Install these Omarchy / Hyprland dotfiles onto an Omarchy system.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="${OMARCHY_DOTFILES_BACKUP:-$HOME/.config/omarchy-dotfiles-backup-$(date +%Y%m%d-%H%M%S)}"
DRY_RUN=0
WITH_HY3=1
WITH_CONKY=0

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Install Mahmoud's Omarchy user configs into ~/.config (Hyprland + shell/bar).

Options:
  --dry-run       Print actions only
  --skip-hy3      Do not install/enable the hy3 Hyprland plugin
  --with-conky    Also clone lean-conky-config into ~/.config/conky
  -h, --help      Show this help

Safe locations only — never writes under /usr/share/omarchy/.
Existing files are copied to a timestamped backup under ~/.config/.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-hy3) WITH_HY3=0; shift ;;
    --with-conky) WITH_CONKY=1; shift ;;
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

if [[ ! -d /usr/share/omarchy ]]; then
  echo "This does not look like an Omarchy install (/usr/share/omarchy missing)." >&2
  echo "Install Omarchy first: https://omarchy.org" >&2
  exit 1
fi

need_cmd hyprctl
need_cmd omarchy

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

echo "==> Suggested packages (install what you use)"
cat <<'EOF'
  sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox \
    viewnior gwenview voxtype-bin
  # Optional per-window keyboard layout daemon:
  #   yay -S hypr-kblayoutd-bin
  #   systemctl --user enable --now hypr-kblayoutd.service
EOF

if [[ "$DRY_RUN" -eq 0 ]]; then
  echo "==> Reload Hyprland + shell"
  hyprctl reload || true
  hyprctl configerrors || true
  omarchy restart shell 2>/dev/null || omarchy-restart-shell 2>/dev/null || true
fi

echo
echo "Done."
echo "  1. Edit ~/.config/hypr/monitors.lua and input.lua for *this* laptop."
echo "  2. Read README.md → “How to edit each feature”."
echo "  3. Deep hy3 / i3 keymap guide: docs/hypr-i3-setup.md"
echo "  Backup of previous configs: $BACKUP_ROOT"
