#!/usr/bin/env bash
# Layer the Omarchy desktop stack onto baseline Arch Linux (also EndeavourOS,
# CachyOS and other Arch-based installs) without replacing your bootloader:
# Limine/Snapper are passed as --assume-installed, so pacman never installs them.
# Afterwards run ./install.sh --target arch to apply the configs.
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
  4. Writes OMARCHY_PATH + PATH into ~/.config/environment.d/ (and ~/.bashrc)
  5. Installs Arch packages this rice expects (hyprpm, grim, konsole, …)
     plus optional apps (brave-bin, firefox, viewnior, gwenview)

Options:
  --dry-run         Print actions only
  --skip-keyring    Do not re-run pacman-key for omarchy
  -h, --help        Show help

Requires sudo. Read docs/arch-linux.md first.
TildaZ (dropdown terminal) and hy3 are installed by ./install.sh, not here.
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

# Arch, EndeavourOS (ID=endeavouros), CachyOS (ID=cachyos), etc.
case "${ID:-}" in
  arch|endeavouros|cachyos|manjaro|garuda) ;; 
  *)
    if [[ "${ID_LIKE:-}" != *"arch"* ]]; then
      echo "This helper is for Arch-based systems (got ID=${ID:-unknown})." >&2
      echo "Supported examples: Arch, EndeavourOS, CachyOS." >&2
      exit 1
    fi
    ;;
esac
echo "==> Detected Arch-family OS: ID=${ID:-unknown} ID_LIKE=${ID_LIKE:-}"

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
  # The omarchy package depends on limine + snapper. On a normal Arch laptop
  # you already have a bootloader, so tell pacman they are present instead.
  # The JetBrains Mono Nerd font comes in as omarchy's dependency
  # ttf-jetbrains-mono-nerd-basic. Do not also request ttf-jetbrains-mono-nerd:
  # the two conflict and the transaction fails.
  run sudo pacman -Sy --needed --noconfirm \
    --assume-installed limine \
    --assume-installed limine-mkinitcpio-hook \
    --assume-installed limine-snapper-sync \
    --assume-installed snapper \
    omarchy hyprland quickshell uwsm sddm \
    xdg-desktop-portal-hyprland wireplumber pipewire \
    gnome-keyring gum jq
fi

echo "==> Core Arch packages for this rice"
ARCH_PKGS=(
  hyprpm hyprland hyprlock hypridle hyprsunset
  xdg-desktop-portal-hyprland
  grim slurp wl-clipboard jq
  kitty konsole dolphin
  pipewire wireplumber
  uwsm
)
# Optional apps the keymap launches. brave-bin comes from the [omarchy] repo.
# One missing package makes pacman skip the whole list, so failure only warns.
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
