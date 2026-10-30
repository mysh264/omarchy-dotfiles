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
  2. Trusts Omarchy's packaging key (like omarchy-update-keyring), installs omarchy-keyring
  3. Not on Omarchy OS: adds safeguards so Omarchy's packages leave your distro alone
     - pacman NoExtract for Omarchy's initramfs (mkinitcpio) and Limine drop-ins
     - saves os-release, nsswitch.conf, faillock.conf, plymouthd.conf, skel/.bashrc
       and the cups files, plus a pacman hook that restores them after every
       omarchy-settings install/upgrade
     - files Omarchy also ships that your distro's packages own (CachyOS:
       /etc/skel/.config/alacritty/alacritty.toml) keep your copy and are shared
  4. Installs omarchy + desktop deps while NOT pulling Limine/Snapper
     (keeps systemd-boot / GRUB / whatever you already use)
  5. Writes OMARCHY_PATH + PATH into ~/.config/environment.d/ (and bash/fish)
  6. Installs Arch packages this rice expects (hyprpm, grim, konsole, …)
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


# --- Safeguards for distros that are not Omarchy OS -------------------------
#
# omarchy-settings (pulled in by the omarchy package) is written for Omarchy
# OS. On Arch / EndeavourOS / CachyOS two parts of it are harmful:
#   1. /etc/mkinitcpio.conf.d/omarchy_hooks.conf replaces the initramfs HOOKS
#      with Omarchy's (plymouth, encrypt, btrfs-overlayfs from limine-snapper-
#      sync, which is skipped above). The next kernel update could build a
#      broken initramfs. NoExtract keeps these boot files off the disk.
#   2. Its install script overwrites os-release, nsswitch.conf, faillock.conf,
#      plymouthd.conf, skel/.bashrc and the cups files on every install and
#      upgrade. They are saved here once and a pacman hook puts them back.
GUARD_SAVE=/etc/omarchy-dotfiles/distro-files
GUARD_PATHS=(
  /etc/os-release
  /etc/nsswitch.conf
  /etc/security/faillock.conf
  /etc/plymouth/plymouthd.conf
  /etc/skel/.bashrc
  /etc/cups/cups-browsed.conf
  /etc/cups/cups-files.conf
)
GUARD_NOEXTRACT="etc/mkinitcpio.conf.d/omarchy_hooks.conf etc/mkinitcpio.conf.d/omarchy_vconsole.conf etc/mkinitcpio.conf.d/thunderbolt_module.conf etc/limine-entry-tool.d/omarchy-*.conf"

distro_guard() {
  echo "==> Safeguards for ${ID:-this distro} (keep its boot setup and system files)"

  # 1. NoExtract: one line in [options], marked so a re-run finds it.
  if ! grep -q '^# omarchy-dotfiles: NoExtract' /etc/pacman.conf; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] add to [options] in /etc/pacman.conf: NoExtract = $GUARD_NOEXTRACT"
    else
      sudo cp -a /etc/pacman.conf "/etc/pacman.conf.omarchy-dotfiles.bak"
      sudo sed -i "/^\[options\]/a # omarchy-dotfiles: NoExtract keeps Omarchy's boot (initramfs) settings off this distro\nNoExtract = $GUARD_NOEXTRACT" /etc/pacman.conf
    fi
    echo "    NoExtract set (backup: /etc/pacman.conf.omarchy-dotfiles.bak)"
  else
    echo "    NoExtract already set"
  fi

  # 2. Save this distro's files once, before omarchy-settings ever runs.
  if pacman -Q omarchy-settings &>/dev/null; then
    echo "    omarchy-settings is already installed; not saving files (they may be Omarchy's now)"
  elif [[ ! -f $GUARD_SAVE/paths ]]; then
    local path
    run sudo mkdir -p "$GUARD_SAVE"
    for path in "${GUARD_PATHS[@]}"; do
      run sudo mkdir -p "$GUARD_SAVE$(dirname "$path")"
      if [[ -e $path || -L $path ]]; then
        run sudo cp -a "$path" "$GUARD_SAVE$path"
      else
        run sudo touch "$GUARD_SAVE$path.absent"
      fi
    done
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "[dry-run] write $GUARD_SAVE/paths"
    else
      printf '%s\n' "${GUARD_PATHS[@]}" | sudo tee "$GUARD_SAVE/paths" >/dev/null
    fi
    echo "    Saved ${#GUARD_PATHS[@]} system files to $GUARD_SAVE"
  else
    echo "    System files already saved in $GUARD_SAVE"
  fi

  # 3. Hook that restores them after every omarchy-settings install/upgrade.
  run sudo install -Dm755 "$ROOT/scripts/distro-guard/restore-distro-files" \
    /usr/local/lib/omarchy-dotfiles/restore-distro-files
  run sudo install -Dm644 "$ROOT/scripts/distro-guard/omarchy-dotfiles-distro-guard.hook" \
    /etc/pacman.d/hooks/omarchy-dotfiles-distro-guard.hook
}

# omarchy-settings ships files this distro's own config packages may own (on
# CachyOS: cachyos-alacritty-config, required by cachyos-kde-settings, owns
# /etc/skel/.config/alacritty/alacritty.toml). pacman stops the whole
# transaction on such a conflict. Removing the distro's package could break its
# desktop, so instead the file is shared:
#   - NoExtract keeps the distro's copy on disk, untouched;
#   - --overwrite for that one path lets the first install record it.
# pacman only conflict-checks files that are new in an upgrade, so later
# omarchy-settings upgrades do not stop on it again.
OVERWRITE_ARGS=()
resolve_file_conflicts() {
  echo "==> Check Omarchy packages for file conflicts with ${ID:-this distro}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] download omarchy + omarchy-settings and compare their files with installed packages"
    return 0
  fi
  local assume=(--assume-installed limine --assume-installed limine-mkinitcpio-hook
    --assume-installed limine-snapper-sync --assume-installed snapper)
  sudo pacman -Sw --noconfirm "${assume[@]}" omarchy omarchy-settings >/dev/null

  local url pkgfile pkgname file owner
  local -A shared=() unowned=()
  for url in $(pacman -Sp "${assume[@]}" omarchy omarchy-settings); do
    pkgfile="/var/cache/pacman/pkg/${url##*/}"
    [[ -f $pkgfile ]] || continue
    pkgname=$(bsdtar -xOf "$pkgfile" .PKGINFO | sed -n 's/^pkgname = //p')
    while IFS= read -r file; do
      [[ $file == .* || $file == */ ]] && continue
      [[ -e /$file || -L /$file ]] || continue
      owner=$(pacman -Qoq "/$file" 2>/dev/null || true)
      case $owner in
        omarchy|omarchy-settings|"$pkgname") ;;
        "") unowned["/$file"]=1 ;;
        *) shared["$file"]=$owner ;;
      esac
    done < <(bsdtar -tf "$pkgfile")
  done

  if (( ${#unowned[@]} )); then
    echo "    These files exist but no package owns them; Omarchy would conflict:" >&2
    printf '      %s\n' "${!unowned[@]}" >&2
    echo "    Move them aside (e.g. sudo mv FILE FILE.bak) and run this script again." >&2
    exit 1
  fi
  (( ${#shared[@]} )) || { echo "    No conflicts"; return 0; }

  for file in "${!shared[@]}"; do
    echo "    /$file is owned by ${shared[$file]}: keeping that copy (NoExtract), sharing ownership"
    if ! grep -qxF "NoExtract = $file" /etc/pacman.conf; then
      sudo sed -i "/^# omarchy-dotfiles: NoExtract/a NoExtract = $file" /etc/pacman.conf
    fi
    OVERWRITE_ARGS+=(--overwrite "/$file")
  done
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

  # Same steps as Omarchy's own omarchy-update-keyring: trust the packaging key
  # first. Installing omarchy-keyring before that fails with
  # 'signature from "Omarchy <pkgs@omarchy.org>" is unknown trust'.
  OMARCHY_KEY=40DFB630FF42BCFFB047046CF0134EE680CAC571
  echo "==> Trust the Omarchy packaging key + install omarchy-keyring"
  if [[ "$SKIP_KEYRING" -eq 0 ]]; then
    if ! sudo pacman-key --list-keys "$OMARCHY_KEY" &>/dev/null; then
      run sudo pacman-key --recv-keys "$OMARCHY_KEY" --keyserver keys.openpgp.org
    fi
    run sudo pacman-key --lsign-key "$OMARCHY_KEY"
  fi
  run sudo pacman -Sy --needed --noconfirm omarchy-keyring

  if [[ "${ID:-}" != "omarchy" ]]; then
    distro_guard
  fi

  echo "==> Install Omarchy desktop stack (skip Limine/Snapper bootloader deps)"
  # The omarchy package depends on limine + snapper. On a normal Arch laptop
  # you already have a bootloader, so tell pacman they are present instead.
  # The JetBrains Mono Nerd font comes in as omarchy's dependency
  # ttf-jetbrains-mono-nerd-basic. Do not also request ttf-jetbrains-mono-nerd:
  # the two conflict and the transaction fails.
  STACK_PKGS=(omarchy hyprland quickshell uwsm sddm
    xdg-desktop-portal-hyprland wireplumber pipewire gnome-keyring gum jq)
  resolve_file_conflicts
  run sudo pacman -S --needed --noconfirm \
    --assume-installed limine \
    --assume-installed limine-mkinitcpio-hook \
    --assume-installed limine-snapper-sync \
    --assume-installed snapper \
    "${OVERWRITE_ARGS[@]}" \
    "${STACK_PKGS[@]}"
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

# fish (CachyOS's default shell) does not read ~/.bashrc or /etc/profile.d.
if command -v fish >/dev/null 2>&1; then
  FISH_FILE="$HOME/.config/fish/conf.d/omarchy-dotfiles.fish"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] write $FISH_FILE"
  else
    mkdir -p "$(dirname "$FISH_FILE")"
    cat >"$FISH_FILE" <<'EOF'
# omarchy-dotfiles: Omarchy commands on PATH
if test -d /usr/share/omarchy/bin
    set -gx OMARCHY_PATH /usr/share/omarchy
    fish_add_path -g /usr/share/omarchy/bin
end
EOF
  fi
fi

echo "==> Session tip"
cat <<'EOF'
  Log out and pick “Hyprland (uwsm-managed)” (or Hyprland) in SDDM/GDM.
  Then run:  ./install.sh --target arch
  Full walkthrough: docs/arch-linux.md
EOF

echo "Done."
