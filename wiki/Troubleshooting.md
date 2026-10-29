# Troubleshooting

## Quick checks

```bash
hyprctl configerrors          # must be empty
hyprctl plugin list           # hy3 loaded?
hyprpm list                   # hy3 enabled?
hyprctl getoption general:layout
omarchy restart shell         # bar issues
```

## Symptom table

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Login hangs / black screen on NVIDIA | hy3 loaded too early | Keep hy3 **out** of cold-start `hyprland.lua`; use autostart `hyprpm reload && hyprctl reload` as shipped |
| hy3 binds do nothing | Plugin not loaded / wrong workspace layout | `hyprpm enable hy3`; wait for autostart reload; check layouts below |
| Focus/move dead on some workspaces only | Saved Omarchy layout ≠ hy3 | Inspect `~/.local/state/omarchy/workspace-layouts/`; ensure `hyprland.lua` forces hy3 after toggles; keep Super+L unbound |
| Split windows have no gaps / borders gone | Omarchy's global no-gaps toggle is on | `ls ~/.local/state/omarchy/toggles/hypr/` shows `window-no-gaps.lua` → press `Super+Shift+Backspace` again or run `omarchy-hyprland-window-gaps-toggle` |
| Bar shows numbers instead of names | Stock workspaces widget in use | `shell.json` must use `mahmoud.workspaces`; then `omarchy restart shell` ([Plugins](Plugins)) |
| Bar shows only 1–7 | By design | 8–12 appear while in use; change `alwaysShown` in `Workspaces.qml` |
| Empty workspaces show old icons, occupied ones new | Old widget with its own name list | Update `mahmoud.workspaces` from this repo; it reads `workspace_names` from `hyprland.lua` |
| Bar missing / wrong widgets | shell.json ids / shell not running | `omarchy restart shell`; confirm ids match manifests; `omarchy plugin list` |
| Bar won’t stay hidden / peek broken | Flag or shell sync | Check `~/.local/state/omarchy/toggles/bar-off`; Super+M; `omarchy-shell` running |
| Screenshots fail | Missing tools / no focused window | Install `grim` `wl-clipboard` `jq`; run focused script manually |
| Conky missing | Not installed | `./install.sh --with-conky` or clone lean-conky-config |
| `configerrors` noise | Lua syntax / bad API call | Fix the printed line; do not ignore |
| Arch: `omarchy` not found | PATH / environment.d | Run setup script; re-login; `export PATH="/usr/share/omarchy/bin:$PATH"` |
| Arch: pacman wants Limine | Dep resolution | Use setup script `--assume-installed limine,…` flags |
| Dropdown keys do nothing | TildaZ not installed / not autostarted | Install TildaZ and run `tildaz --desktop add`, or switch the binds back to Kitty ([Dropdown Terminal](Dropdown-Terminal)) |
| Dropdown Kitty wrong size / not special | Class mismatch | Must launch `--class dropdown.terminal`; rule in `hyprland.lua` |
| Tabs never appear / always appear | Auto titlebar logic | See [Look and Feel](Look-and-Feel); `tab_first_window`; window count helpers |
| Cursor warps when apps open on other WS | Titlebar sync hop | Shipped code disables warps during hop — don’t remove that restore block |
| Network widget vanished | Wrong id in shell.json | Use `mahmoud.network` or re-enable `omarchy.network` |
| Theme didn’t change Alacritty colors | Import path broken | Keep `general.import` of current theme in alacritty.toml |

## Inspect workspace layouts

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

Every workspace you care about should say `hy3` after login settles.

## hy3 rebuild after Hyprland update

```bash
hyprpm update
hyprpm reload
ls "/var/cache/hyprpm/$USER/hy3/hy3.so"
hyprctl repl 'return hl.plugin.hy3 ~= nil'   # expect true
```

## Restore from installer backup

```bash
ls ~/.config/omarchy-dotfiles-backup-*
# copy files back into ~/.config/hypr or ~/.config/omarchy as needed
hyprctl reload
omarchy restart shell
```

## Still stuck?

1. Re-read [Golden Rules](Golden-Rules)  
2. In-repo deep dive: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)  
3. Upstream Omarchy docs / issues: [omacom/omarchy](https://github.com/omacom/omarchy)  
4. hy3 upstream: [outfoxxed/hy3](https://github.com/outfoxxed/hy3)  
