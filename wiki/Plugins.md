# Plugins (cloned bar, network & workspaces)

Omarchy first-party plugins live in the package tree. This rice **clones** three of them into your config so you can edit safely — package updates will not overwrite your copies.

| Plugin id | Path | Kind | Cloned from |
|-----------|------|------|-------------|
| `mahmoud.bar` | `omarchy/plugins/mahmoud.bar/` | `bar` | `omarchy.bar` |
| `mahmoud.network` | `omarchy/plugins/mahmoud.network/` | `bar-widget` | `omarchy.network` |
| `mahmoud.workspaces` | `omarchy/plugins/mahmoud.workspaces/` | `bar-widget` | `omarchy.workspaces` |

Live under `~/.config/omarchy/plugins/…`.

## Why clone?

Editing `/usr/share/omarchy/...` is wiped on upgrade. `omarchy plugin clone` (already done in this repo) copies the plugin into `~/.config/omarchy/plugins/<new-id>/` with a manifest that records `omarchy.clonedFrom`.

## Bar engine — `mahmoud.bar`

- Entry: `Bar.qml` (declared in `manifest.json`)  
- Widgets: `widgets/*.qml` + sibling `*.manifest.json`  
- Indicators: `indicators/*.qml` (Dnd, NightLight, Reminder, ScreenRecording, StayAwake, Dictation, …)  
- Logic helpers: `BarModel.js`, tray/keyboard models, etc.  

`shell.json` sets `"id": "mahmoud.bar"` so the shell mounts **your** clone, not the stock bar.

### When to edit QML vs shell.json

| Change | Prefer |
|--------|--------|
| Order / which widgets | `shell.json` or `omarchy bar move` |
| Position / transparency | `shell.json` / `omarchy bar …` |
| Widget behavior Omarchy doesn’t expose | Edit QML under `mahmoud.bar/widgets/` |
| Indicator set | `omarchy.indicators` settings in `shell.json` |

**Caution:** `Bar.qml` is large engine code. Prefer small widget edits; keep a git copy.

### Refresh after upstream Omarchy changes

```bash
omarchy plugin clone omarchy.bar
# Then either switch shell.json bar.id to the new clone id,
# or manually merge upstream into mahmoud.bar
omarchy restart shell
```

## Network panel — `mahmoud.network`

- `Panel.qml` + `Model.js`  
- Manifest `id`: `mahmoud.network`  
- Placed in `shell.json` right layout (instead of `omarchy.network`)  

Safe to tweak Wi-Fi list UI / dual-stack presentation. Re-clone from `omarchy.network` if you want a fresh upstream base.

```bash
omarchy plugin clone omarchy.network
omarchy plugin list
omarchy restart shell
```

## Workspaces — `mahmoud.workspaces`

- `Workspaces.qml` + `manifest.json`  
- Placed in `shell.json` left layout (instead of `omarchy.workspaces`)  

The stock widget always shows 1–5, adds only workspaces that exist (up to 10), and shows bare numbers. The current one becomes a dot. This clone:

- always shows workspaces **1–7**  
- shows **8–12** only while they exist (they hold a window or you are on them)  
- labels each one with its name from `workspace_names` in `hypr/hyprland.lua` (e.g. `1: >_`)  
- highlights the current workspace and dims empty ones  

How it was made:

```bash
omarchy plugin clone omarchy.workspaces   # copies it and switches shell.json to mahmoud.workspaces
# edit ~/.config/omarchy/plugins/mahmoud.workspaces/Workspaces.qml
omarchy restart shell                     # if the hot reload does not pick it up
```

### Names come from `hyprland.lua`

The widget reads `~/.config/hypr/hyprland.lua` and takes the strings in the `workspace_names = { … }` table. It watches the file, so saving it updates the bar. To rename a workspace or change its icon, edit **only** that table.

Why: Hyprland does not create empty workspaces, so their names cannot be asked from Hyprland. An earlier version kept a second copy of the names in the QML. After icons for 2, 3 and 4 were changed in `hyprland.lua`, empty workspaces still showed the old icons from that copy, while occupied ones showed the new ones from Hyprland. Reading the file removes the second copy.

Keep the table in this shape so the widget can find it: `local workspace_names = {`, one `"N: icon"` string per line, and the closing `}` alone at the start of a line. If the table cannot be read, the bar falls back to Hyprland's live name, then to the number.

### Change how many are shown

At the top of `Workspaces.qml`:

```qml
readonly property int alwaysShown: 7
```

- `alwaysShown` — workspaces `1..alwaysShown` are always on the bar. Use `12` to always show all of them, `5` for fewer.  
- The highest workspace shown is the number of entries in `workspace_names` (12). Add entries there to go higher.

To go back to the stock widget, set the id in `shell.json` to `omarchy.workspaces`.

## General plugin commands

```bash
omarchy plugin list
omarchy plugin enable <id>
omarchy plugin disable <id>
omarchy-shell shell rescanPlugins   # if available on your build
```

Third-party widgets: create `~/.config/omarchy/plugins/<id>/` with `manifest.json` declaring `kinds: ["bar-widget"]` and a `barWidget` entry point, then place the id in `shell.json`.
