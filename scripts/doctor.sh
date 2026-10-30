#!/usr/bin/env bash
# Health check for this rice on Omarchy OS or on Arch / EndeavourOS / CachyOS.
# Read-only: it changes nothing. Run it from a terminal inside Hyprland if you
# can (some checks need the session), otherwise from a TTY.
#
#   ./scripts/doctor.sh                # print the report
#   ./scripts/doctor.sh > report.txt   # save it to paste into an issue
set -uo pipefail

ok()   { printf '  [ok]   %s\n' "$*"; }
bad()  { printf '  [FAIL] %s\n' "$*"; }
info() { printf '  [..]   %s\n' "$*"; }
section() { printf '\n== %s\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

section "System"
. /etc/os-release 2>/dev/null
info "os-release: ${PRETTY_NAME:-?} (ID=${ID:-?}, ID_LIKE=${ID_LIKE:-})"
info "kernel: $(uname -r)"
info "shell: ${SHELL:-?}"
if [[ ${ID:-} == omarchy ]] && [[ -e /etc/omarchy-dotfiles/distro-files/paths ]]; then
  bad "os-release says Omarchy but distro safeguards exist: the restore hook did not run"
fi

section "Omarchy stack"
if [[ -d /usr/share/omarchy/bin ]]; then ok "/usr/share/omarchy present ($(cat /usr/share/omarchy/version 2>/dev/null || echo '?'))"; else bad "/usr/share/omarchy missing: run scripts/setup-arch-omarchy-stack.sh"; fi
if have omarchy; then ok "omarchy command on PATH"; else bad "omarchy not on PATH (log out and in; environment.d sets it)"; fi
info "OMARCHY_PATH=${OMARCHY_PATH:-<unset>}"
for p in omarchy omarchy-settings omarchy-keyring; do
  if pacman -Q "$p" >/dev/null 2>&1; then ok "$(pacman -Q "$p")"; else bad "package $p not installed"; fi
done
BASE_LIST=/usr/share/omarchy/install/omarchy-base.packages
if [[ -f $BASE_LIST ]]; then
  mapfile -t missing < <(grep -v -e '^#' -e '^$' "$BASE_LIST" \
    | grep -vxF -e plymouth -e kernel-modules-hook | while read -r p; do pacman -Q "$p" >/dev/null 2>&1 || pacman -Qq --provides "$p" >/dev/null 2>&1 || echo "$p"; done)
  if (( ${#missing[@]} )); then
    bad "${#missing[@]} Omarchy base packages missing: ${missing[*]}"
  else
    ok "all Omarchy base packages installed"
  fi
fi

section "Distro safeguards (not needed on Omarchy OS)"
if [[ ${ID:-} != omarchy ]]; then
  if grep -q '^# omarchy-dotfiles: NoExtract' /etc/pacman.conf 2>/dev/null; then ok "NoExtract set in /etc/pacman.conf"; else bad "NoExtract missing: Omarchy's initramfs hooks could land on this distro"; fi
  if [[ -e /etc/mkinitcpio.conf.d/omarchy_hooks.conf ]]; then bad "/etc/mkinitcpio.conf.d/omarchy_hooks.conf exists: remove it before the next kernel update"; else ok "no omarchy_hooks.conf"; fi
  if [[ -e /etc/pacman.d/hooks/omarchy-dotfiles-distro-guard.hook ]]; then ok "restore hook installed"; else bad "restore hook missing"; fi
else
  info "Omarchy OS: skipped"
fi

section "Session"
info "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-<unset>} XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-<unset>}"
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && have hyprctl; then
  ok "running inside Hyprland ($(hyprctl version 2>/dev/null | head -1))"
  errs=$(hyprctl configerrors 2>/dev/null | sed '/^\s*$/d')
  if [[ -z $errs ]]; then ok "hyprctl configerrors: none"; else bad "hyprctl configerrors:"; printf '         %s\n' "$errs" | head -20; fi
  if hyprctl plugin list 2>/dev/null | grep -qi hy3; then ok "hy3 loaded"; else bad "hy3 not loaded: most i3 keys are skipped (bindings.lua returns early). Check: hyprpm list"; fi
  info "layout: $(hyprctl getoption general:layout 2>/dev/null | head -1)"
  info "binds loaded: $(hyprctl binds 2>/dev/null | grep -c '^bind')"
else
  bad "not inside Hyprland: session checks skipped (run this from a Hyprland terminal)"
fi
if pgrep -f omarchy-shell >/dev/null || pgrep -x quickshell >/dev/null || pgrep -x qs >/dev/null; then ok "Omarchy shell (bar) running"; else bad "Omarchy shell not running: try omarchy-launch-shell"; fi

section "Config files"
for f in hyprland.lua bindings.lua looknfeel.lua autostart.lua input.lua monitors.lua; do
  if [[ -f ~/.config/hypr/$f ]]; then ok "~/.config/hypr/$f"; else bad "~/.config/hypr/$f missing: run ./install.sh"; fi
done
for f in ~/.config/hypr/hyprland.conf; do
  [[ -f $f ]] && info "$f exists too (Hyprland's old config; harmless if hyprland.lua loads)"
done
[[ -f ~/.config/omarchy/shell.json ]] && ok "~/.config/omarchy/shell.json" || bad "~/.config/omarchy/shell.json missing"
if [[ -s ~/.local/state/omarchy/current/theme.name ]]; then ok "theme: $(cat ~/.local/state/omarchy/current/theme.name)"; else bad "no Omarchy theme set: run omarchy-provision-first-run --force inside Hyprland"; fi
if [[ -f ~/.local/state/omarchy/first-run.log ]]; then
  info "first-run log (last lines):"; tail -5 ~/.local/state/omarchy/first-run.log | sed 's/^/         /'
else
  info "first-run never ran (it runs at the first Hyprland login)"
fi

section "Apps the keys launch"
for c in konsole kitty dolphin nautilus foot brave firefox tildaz grim slurp wl-copy jq hyprpm; do
  if have "$c" || [[ -x ~/.local/bin/$c ]]; then ok "$c"; else bad "$c not found"; fi
done
if have hyprpm; then info "hyprpm list:"; hyprpm list 2>&1 | sed 's/^/         /' | head -10; fi

section "Recent user-session errors"
journalctl --user -b -p err --no-pager -n 15 2>/dev/null | sed 's/^/  /' || info "journalctl not available"

printf '\nDone. Paste this whole report when asking for help.\n'
