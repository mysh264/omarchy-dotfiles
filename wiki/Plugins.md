# Plugins (cloned bar, network and workspaces)

Omarchy's own shell plugins (bar, widgets, panels) live in the package under `/usr/share/omarchy/shell/plugins/`. Never edit them there: an update wipes your change. Omarchy's way is to **clone** a plugin into your config and edit the copy. This rice ships three clones:

| Plugin id | Repo path | Kind | Cloned from | What changed |
|-----------|-----------|------|-------------|--------------|
| `mahmoud.bar` | `omarchy/plugins/mahmoud.bar/` | `bar` | `omarchy.bar` | Adds a `setOverlay` IPC call so the hidden bar can "peek" over windows |
| `mahmoud.network` | `omarchy/plugins/mahmoud.network/` | `bar-widget` | `omarchy.network` | Wi-Fi adapter picker when you have more than one radio (for example a USB dongle) |
| `mahmoud.workspaces` | `omarchy/plugins/mahmoud.workspaces/` | `bar-widget` | `omarchy.workspaces` | Named workspaces 1–7 always shown, 8–12 when they exist |

**Live:** `~/.config/omarchy/plugins/<id>/` (`install.sh` copies all three).

## How cloning works

```bash
omarchy plugin clone omarchy.workspaces
```

This copies the built-in plugin to `~/.config/omarchy/plugins/<your-username>.workspaces/`, names it "My Workspaces", records `"omarchy": { "clonedFrom": "omarchy.workspaces" }` in its `manifest.json`, and switches the bar over to the clone. The username prefix is why the ids here start with `mahmoud.`. If you install this rice under another user name, the ids stay `mahmoud.*`; that is fine, they are just names.

Saving any file under `~/.config/omarchy/plugins/` reloads the plugin code. If a change does not show up:

```bash
omarchy-shell shell rescanPlugins
# or, heavier:
omarchy restart shell
```

In i3 terms: it is like copying `/etc/i3status.conf` to `~/.config/i3status/config` before editing it, except Omarchy does the copy and the switch for you.

## Bar engine — `mahmoud.bar`

- Entry: `Bar.qml` (declared in `manifest.json`)  
- Widgets: `widgets/*.qml`, each with a sibling `*.manifest.json`  
- Indicators: `indicators/*.qml` (Dictation, Dnd, NightLight, Reminder, ScreenRecording, StayAwake)  
- Helpers: `BarModel.js`, `widgets/TrayModel.js`, `widgets/KeyboardLayoutModel.js`  

`shell.json` sets `"bar": { "id": "mahmoud.bar" }`, so the shell mounts **this** clone, not the stock bar.

The only change from stock is in `Bar.qml`: a `barOverlay` property and an IPC function, called from `hypr/bindings.lua`:

```bash
omarchy-shell -q omarchy.bar setOverlay yes   # draw the hidden bar over the windows (peek)
omarchy-shell -q omarchy.bar setOverlay no
```

While peeking, the bar does not reserve screen space, so windows do not jump. See [Status Bar](Status-Bar#hide-and-peek).

> `mahmoud.bar/widgets/Workspaces.qml` is an **unused stock copy** that came with the clone. Its manifest still says `omarchy.workspaces`. The bar uses `mahmoud.workspaces` (below) instead, because `shell.json` names that id. Edit the plugin below, not this file.

### When to edit QML and when to edit `shell.json`

| Change | Prefer |
|--------|--------|
| Order / which widgets | `shell.json` or `omarchy bar move` |
| Position / transparency | `omarchy bar position …` / `omarchy bar transparent …` |
| Indicator set | `omarchy.indicators` options in `shell.json` |
| Behavior Omarchy does not expose | Edit QML in the clone |

**Caution:** `Bar.qml` is large engine code (about 2,100 lines). Keep changes small and keep them in git.

### Taking in upstream changes

Omarchy updates change the stock bar, not your clone. `omarchy plugin clone` refuses to overwrite an existing folder, so to start from a fresh copy:

```bash
mv ~/.config/omarchy/plugins/mahmoud.bar ~/mahmoud.bar.old
omarchy plugin clone omarchy.bar          # makes a new <user>.bar and switches to it
diff -r ~/mahmoud.bar.old ~/.config/omarchy/plugins/mahmoud.bar   # re-apply your edits
```

To see what upstream changed against your copy without re-cloning:

```bash
diff -r /usr/share/omarchy/shell/plugins/bar ~/.config/omarchy/plugins/mahmoud.bar
```

The same works for the two widgets (`/usr/share/omarchy/shell/plugins/panels/network`, `/usr/share/omarchy/shell/plugins/bar/widgets/Workspaces.qml`).

## Network panel — `mahmoud.network`

- `Panel.qml` + `Model.js` + `manifest.json` (id `mahmoud.network`)  
- Placed in the right section of `shell.json` instead of `omarchy.network`  

The stock panel follows only the connected Wi-Fi radio, which hides a second adapter. This clone lists every Wi-Fi device and shows an **adapter row** when there is more than one, so you can scan and connect with a USB dongle while the built-in card stays connected. The bar icon still follows the connected radio. Keyboard focus in the panel gains an `adapter` section between DNS and the network list.

## Workspaces — `mahmoud.workspaces`

- `Workspaces.qml` + `manifest.json`  
- Placed in the left section of `shell.json` instead of `omarchy.workspaces`  

The stock widget always shows 1–5, adds only workspaces that exist (up to 10), and shows bare numbers. The focused one becomes a dot. This clone:

- always shows workspaces **1–7**  
- shows **8–12** only while they exist (they hold a window or you are on them)  
- labels each one with its name from `workspace_names` in `hypr/hyprland.lua` (for example `1: >_`)  
- highlights the current workspace and dims empty ones  

This is the i3 feeling: `set $ws1 "1: >_"` in `~/.config/i3/config` gave you named workspaces on i3bar. Here the names live in `hyprland.lua` and the widget shows them.

How it was made:

```bash
omarchy plugin clone omarchy.workspaces   # copies it and switches shell.json to mahmoud.workspaces
# edit ~/.config/omarchy/plugins/mahmoud.workspaces/Workspaces.qml
omarchy restart shell                     # only if the hot reload does not pick it up
```

### Names come from `hyprland.lua`

The widget reads `~/.config/hypr/hyprland.lua` and takes the strings in the `workspace_names = { … }` table. It watches the file, so saving it updates the bar. To rename a workspace or change its icon, edit **only** that table.

Why: Hyprland does not create empty workspaces, so you cannot ask Hyprland for their names. An earlier version kept a second copy of the names in the QML. After the icons for 2, 3 and 4 were changed in `hyprland.lua`, empty workspaces still showed the old icons from that copy, while occupied ones showed the new ones from Hyprland. Reading the file removes the second copy.

Keep the table in this shape so the widget can find it: `local workspace_names = {`, one `"N: icon"` string per line, and the closing `}` alone at the start of a line. If the table cannot be read, the bar falls back to Hyprland's live name, then to the number.

### Change how many are shown

At the top of `Workspaces.qml`:

```qml
readonly property int alwaysShown: 7
```

- `alwaysShown`: workspaces `1..alwaysShown` are always on the bar. Use `12` to always show all of them, `5` for fewer.  
- The highest workspace shown is the number of entries in `workspace_names` (12). Add entries there to go higher.

To go back to the stock widget, change the id in `shell.json` to `omarchy.workspaces`.

## Check it worked

```bash
omarchy plugin list | grep -E "mahmoud|omarchy\.(bar|network|workspaces) "
# expect: mahmoud.* enabled, omarchy.bar / omarchy.network / omarchy.workspaces disabled
jq '.bar.id, [.bar.layout[][] | .id | select(startswith("mahmoud"))]' ~/.config/omarchy/shell.json
omarchy plugin validate ~/.config/omarchy/plugins/mahmoud.workspaces   # silent = valid
```

## General plugin commands

```bash
omarchy plugin list                     # every plugin and its state
omarchy plugin enable <id> [placement]  # put a widget on the bar (e.g. --section right)
omarchy plugin disable <id>             # take it off
omarchy plugin clone <source-id>        # make your own editable copy
omarchy plugin add <git-url>            # install a third-party plugin
omarchy plugin validate <folder>        # check a manifest
omarchy-shell shell rescanPlugins       # re-read plugin folders
```

Your own widget: create `~/.config/omarchy/plugins/<id>/` with a `manifest.json` that declares `"kinds": ["bar-widget"]` and a `barWidget` entry point (copy `mahmoud.workspaces/manifest.json` as a start), then `omarchy plugin enable <id>`. For a simple text widget, a [command module](Status-Bar#custom-modules) is less work.
