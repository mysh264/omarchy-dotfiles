# Troubleshooting

## Quick checks

Fastest: `./scripts/doctor.sh` from the repo, run in a Hyprland terminal. It only reads, and prints `[ok]` / `[FAIL]` for the stack, packages, session, hy3, configs and apps. Paste its output when asking for help.

```bash
hyprctl configerrors              # must be empty
hyprctl plugin list               # hy3 loaded?
hyprpm list                       # hy3 enabled?
hyprctl getoption general:layout  # hy3 after login settles
ls ~/.local/state/omarchy/toggles/hypr/   # any Omarchy toggles on?
omarchy restart shell             # bar issues
```

## Symptom table

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Login hangs / black screen on NVIDIA | hy3 loaded too early | Keep hy3 **out** of cold-start `hyprland.lua`; use the shipped autostart `hyprpm reload && hyprctl reload`. Keep the `hl.plugin.hy3 ~= nil and "hy3" or "dwindle"` guards |
| hy3 binds do nothing | Plugin not loaded / wrong workspace layout | `hyprpm enable hy3`; wait for the autostart reload; check layouts below |
| Focus/move dead on some workspaces only | Saved Omarchy layout ≠ hy3 | Inspect `~/.local/state/omarchy/workspace-layouts/`; make sure `hyprland.lua` forces hy3 after `require("default.hypr.toggles")`; keep Super+L unbound |
| Split windows have no gaps / borders gone | Omarchy's global no-gaps toggle is on | `ls ~/.local/state/omarchy/toggles/hypr/` shows `window-no-gaps.lua` → press `Super+Shift+Backspace` again or run `omarchy-hyprland-window-gaps-toggle`. Smart gaps (none with one window) are already built in; don't use this key for them |
| Single window still has gaps | Smart-gaps rules missing | `hyprland.lua` needs `w[tv1]` and `f[1]` workspace rules with `gaps_in = 0, gaps_out = 0` |
| Bar shows numbers instead of names | Stock workspaces widget in use | `shell.json` must use `mahmoud.workspaces`; then `omarchy restart shell` ([Plugins](Plugins)) |
| Bar shows only 1–7 | By design | 8–12 appear while they exist; change `alwaysShown` in `Workspaces.qml` |
| Empty workspaces show old icons, occupied ones new | Old widget with its own name list | Update `mahmoud.workspaces` from this repo; it reads `workspace_names` from `hyprland.lua`. Edit names only there |
| Bar missing / wrong widgets | `shell.json` ids / shell not running | `omarchy restart shell`; confirm ids match the manifests; `omarchy plugin list` |
| Bar won't stay hidden / peek broken | Flag or shell sync | Check `~/.local/state/omarchy/toggles/bar-off`; Super+M; `omarchy-shell` running |
| Dropdown keys / F1 do nothing | TildaZ not installed | `which tildaz`; install with `curl -LsSf https://tildaz.dev/install.sh \| sh` (or `./install.sh` without `--skip-tildaz`) |
| TildaZ installed but never starts at login | No autostart file | `ls ~/.config/hypr/tildaz.lua`; if missing run `tildaz --desktop add`. `hyprland.lua` must end with `pcall(require, "tildaz")`. Start it now with `tildaz` |
| F1 works, but Favorites / KP Delete / mouse forward don't | Binds missing | `hyprctl binds \| grep -B2 -A6 'Dropdown terminal'`; the three binds in `bindings.lua` run `tildaz --toggle` |
| TildaZ hotkey dead while Arabic layout is active | Letter hotkey | Hyprland matches the hotkey by the character typed, which changes with the layout. Use an F-key: `hotkey = "F1"` in `~/.config/tildaz/config_0.toml` |
| TildaZ has no blur / no slide | Layer rule not matching | Show it, then `hyprctl layers \| grep tildaz`: namespace must be `tildaz`. `looknfeel.lua` needs `hl.layer_rule({ match = { namespace = "tildaz" }, blur = true, ignore_alpha = 0.1, animation = "slide top" })`. Window rules never apply: it is a layer, not a window |
| TildaZ wrong size / font | Its own config | Edit `~/.config/tildaz/config_0.toml` (`[window]`, `[font]`), not Hyprland |
| Tabs never appear / always appear | Auto-tab logic | See [Look and Feel](Look-and-Feel): ≤1 tiled window → split, exactly 2 → tabs, 3+ untouched; `tab_first_window = false` |
| Cursor warps when apps open on other workspaces | Auto-tab focus hop | The shipped code turns warps off during the hop; don't remove that save/restore block |
| Screenshots fail | Missing tools / no focused window | Install `grim` `wl-clipboard` `jq`; run `~/.config/hypr/scripts/screenshot-focused` by hand |
| Conky missing | Not installed | `./install.sh --with-conky` or clone lean-conky-config |
| `cp: cannot stat '/usr/bin/conky'` / `conky-wayland: No such file` from `start-lcc.sh` | The config is cloned but the Conky program is not installed (old script) | `sudo pacman -S conky`, then `git -C ~/.config/conky pull` for the script that says this clearly. See [Conky](Conky) |
| Conky aborts at start on Wayland | Its `set_font` assert; the fix did not apply to this build | Run `python3 ~/.config/conky/tools/patch-conky-wayland /usr/bin/conky /tmp/conky-test` and read why; see [Conky](Conky#tips) |
| `configerrors` noise | Lua syntax / bad API call | Fix the printed line; do not ignore it |
| Arch: `omarchy` not found | PATH / environment.d | Run the setup script; re-login; `export PATH="/usr/share/omarchy/bin:$PATH"` |
| Arch/CachyOS: nothing works (no keys, no file manager, no bar) | Missing Omarchy packages or user setup | `./scripts/doctor.sh`, then see [Arch Linux](Arch-Linux#arch-specific-troubleshooting) |
| Arch: pacman wants Limine | Dependency resolution | Use the setup script; it passes `--assume-installed limine` and friends |
| Arch/CachyOS: `omarchy-keyring … is unknown trust` | Key not trusted before the keyring package | Use the current setup script (it trusts key `40DFB630…F0134EE680CAC571` first). Details: [Arch Linux](Arch-Linux#arch-specific-troubleshooting) |
| CachyOS: `conflicting files … owned by cachyos-alacritty-config` | `omarchy-settings` ships the same `/etc/skel` file | Current setup script keeps CachyOS's file and shares it; do not remove the package (`cachyos-kde-settings` needs it). See [Safeguards](Arch-Linux#safeguards-for-arch-endeavouros-and-cachyos) |
| Network widget vanished | Wrong id in `shell.json` | Use `mahmoud.network` or re-enable `omarchy.network` |
| Theme didn't change Alacritty colors | Import path broken | Keep `general.import` of the current theme in `alacritty.toml` |

## Inspect workspace layouts

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

Every workspace you care about should say `hy3` after login settles.

## hy3 rebuild after a Hyprland update

```bash
hyprpm update
hyprpm reload
ls "/var/cache/hyprpm/$USER/hy3/hy3.so"
hyprctl repl 'return hl.plugin.hy3 ~= nil'   # expect true
```

## TildaZ checks

```bash
which tildaz                     # ~/.local/bin/tildaz
pgrep -a tildaz                  # running?
cat ~/.config/hypr/tildaz.lua    # autostart written by tildaz --desktop add
tildaz --toggle                  # show/hide from a terminal
hyprctl layers | grep tildaz     # only listed while shown
```

## Restore from the installer backup

```bash
ls ~/.config/omarchy-dotfiles-backup-*
# copy files back into ~/.config/hypr or ~/.config/omarchy as needed
hyprctl reload
omarchy restart shell
```

## Still stuck?

1. Re-read [Golden Rules](Golden-Rules)
2. In-repo deep dive: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
3. Omarchy upstream: [omacom/omarchy](https://github.com/omacom/omarchy)
4. hy3 upstream: [outfoxxed/hy3](https://github.com/outfoxxed/hy3)
5. TildaZ upstream: [ensky0/tildaz](https://github.com/ensky0/tildaz) · [tildaz.dev](https://tildaz.dev)
