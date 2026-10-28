#!/usr/bin/env bash
# Layer the Omarchy desktop stack onto baseline Arch Linux without replacing
# your bootloader (Limine/Snapper are assumed-installed, not actually installed).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
SKIP_KEYRING=0

usage() {
  cat <<'EOF'
Usage: ./scripts/setup-arch-omarchy-stack.sh [options]

On baseline Arch Linux this:
  1. Appends the [omarchy] pacman repo (if missing)
  2. Installs omarchy-keyring
  3. Installs omarchy + desktop deps while NOT pulling Limine/Snapper
     (keeps systemd-boot / GRUB / whatever you already use)
  4. Writes OMARCHY_PATH + PATH into ~/.config/environment.d/
  5. Installs Arch packages this rice expects (hyprpm, grim, …)

Options:
  --dry-run         Print actions only
  --skip-keyring    Do not re-run pacman-key for omarchy
  -h, --help        Show help

Requires sudo. Prefer reading docs/arch-linux.md first.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --skip-keyring) SKIP_KEYRING=1; shift ;;
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

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

if [[ "${ID:-}" != "arch" && "${ID_LIKE:-}" != *"arch"* ]]; then
  echo "This helper is for Arch Linux (got ID=${ID:-unknown})." >&2
  exit 1
fi

if [[ -d /usr/share/omarchy/bin && -x /usr/share/omarchy/bin/omarchy-shell ]]; then
  echo "==> Omarchy stack already present under /usr/share/omarchy"
else
  echo "==> Adding [omarchy] repository (pkgs.omarchy.org)"
  if ! grep -q '^\[omarchy\]' /etc/pacman.conf; then
    run sudo tee -a /etc/pacman.conf >/dev/null <<'EOF'

# Added by omarchy-dotfiles for baseline Arch installs
[omarchy]
SigLevel = Required DatabaseOptional
Server = https://pkgs.omarchy.org/stable/$arch
EOF
  else
    echo "    [omarchy] already in /etc/pacman.conf"
  fi

  echo "==> Sync + install omarchy-keyring"
  run sudo pacman -Sy --needed --noconfirm omarchy-keyring
  if [[ "$SKIP_KEYRING" -eq 0 && "$DRY_RUN" -eq 0 ]]; then
    sudo pacman-key --populate omarchy || true
  fi

  echo "==> Install Omarchy desktop stack (skip Limine/Snapper bootloader deps)"
  # The omarchy package Declares Depends on limine + snapper. On a normal Arch
  # laptop you already have a bootloader — do not replace it.
  run sudo pacman -Sy --needed --noconfirm \
    --assume-installed limine \
    --assume-installed limine-mkinitcpio-hook \
    --assume-installed limine-snapper-sync \
    --assume-installed snapper \
    omarchy hyprland quickshell uwsm sddm \
    xdg-desktop-portal-hyprland wireplumber pipewire \
    gnome-keyring gum jq ttf-jetbrains-mono-nerd
fi

echo "==> Core Arch packages for this rice"
ARCH_PKGS=(
  hyprpm hyprland hyprlock hypridle hyprsunset
  xdg-desktop-portal-hyprland
  grim slurp wl-clipboard jq
  kitty konsole dolphin
  pipewire wireplumber
  ttf-jetbrains-mono-nerd
  uwsm
)
# brave/firefox/viewnior are optional; try without failing the whole script
OPTIONAL_PKGS=(brave-bin firefox viewnior gwenview)

run sudo pacman -S --needed --noconfirm "${ARCH_PKGS[@]}"
if [[ "$DRY_RUN" -eq 0 ]]; then
  sudo pacman -S --needed --noconfirm "${OPTIONAL_PKGS[@]}" 2>/dev/null || \
    echo "    (optional GUI packages skipped — install later if you want them)"
fi

echo "==> User environment (OMARCHY_PATH + PATH)"
ENV_DIR="$HOME/.config/environment.d"
ENV_FILE="$ENV_DIR/99-omarchy-dotfiles.conf"
run mkdir -p "$ENV_DIR"
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[dry-run] write $ENV_FILE"
else
  cat >"$ENV_FILE" <<'EOF'
OMARCHY_PATH=/usr/share/omarchy
PATH=/usr/share/omarchy/bin:${PATH}
EOF
fi

# Login shells / interactive bash
BASHRC_SNIPPET='[ -d /usr/share/omarchy/bin ] && export OMARCHY_PATH=/usr/share/omarchy && export PATH="/usr/share/omarchy/bin:$PATH"'
if [[ -f "$HOME/.bashrc" ]] && ! grep -q 'OMARCHY_PATH=/usr/share/omarchy' "$HOME/.bashrc"; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] append OMARCHY_PATH to ~/.bashrc"
  else
    printf '\n# omarchy-dotfiles\n%s\n' "$BASHRC_SNIPPET" >>"$HOME/.bashrc"
  fi
fi

echo "==> Session tip"
cat <<'EOF'
  Log out and pick “Hyprland (uwsm-managed)” (or Hyprland) in SDDM/GDM.
  Then run:  ./install.sh --target arch
  Full walkthrough: docs/arch-linux.md
EOF

echo "Done."
