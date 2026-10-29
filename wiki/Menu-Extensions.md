# Menu Extensions

**Repo:** `omarchy/extensions/omarchy-menu.jsonc`  
**Live:** `~/.config/omarchy/extensions/omarchy-menu.jsonc`  
**Stock menu (read-only, good for finding ids):** `/usr/share/omarchy/default/omarchy/omarchy-menu.jsonc`

The Omarchy menu (opened with **Super+D** in this rice) is built from a JSONC file: JSON that allows `//` comments. Omarchy reads its stock file first, then yours on top. Your file can add new rows or change stock ones, and you never touch `/usr/share/omarchy`.

The file shipped here is **only comments**: the field reference and examples, all commented out. It adds nothing to the menu yet. Uncomment or add rows below the comments.

In i3 terms: this is like adding entries to a `rofi` / `dmenu` script you bound to `$mod+d`, but the menu reads them from a file instead of a script.

## How ids work

- Each object key is an entry id.  
- The parent comes from the **dotted** id: `personal.notes` sits under `personal`, and `personal` sits on the root menu.  
- Reuse an existing id to **override** a stock entry. Fields you do not set keep their stock values.

## Fields

| Field | Role |
|-------|------|
| `icon` | Nerd Font glyph in the icon column |
| `label` | Visible title |
| `action` | Shell command to run. Leave it out and the row becomes a submenu. |
| `target` | Open an existing submenu id (a link or alias) |
| `provider` | Fill the submenu at runtime from a provider (a `provider_<name>` function or a command `<name>` that returns JSON rows) |
| `aliases` | Extra names for `omarchy menu summon <name>`; also searchable |
| `description` | Subtitle and extra search text |
| `when` | Shell condition; the row is hidden when it fails |
| `checked` | Shell condition; a ✓ is added when it succeeds |

## Example

```jsonc
{
  "personal": { "icon": "", "label": "Personal" },
  "personal.notes": {
    "icon": "󰎞",
    "label": "Notes",
    "action": "omarchy-launch-editor ~/notes"
  },
  "personal.files": {
    "icon": "",
    "label": "Files",
    "action": "uwsm-app -- nautilus ~/Documents"
  },

  // Override the stock About row (stock action: omarchy-launch-about)
  "about": {
    "icon": "",
    "label": "About",
    "action": "omarchy-launch-or-focus-tui \"zsh -c 'fastfetch; read -k 1'\""
  }
}
```

Only use `provider` when that provider really exists. Static submenus only need dotted ids. To see which ids and providers the stock menu uses:

```bash
grep -n '"provider"' /usr/share/omarchy/default/omarchy/omarchy-menu.jsonc
```

## Apply and check

The shell watches the file, so saving it is enough. Open the menu again (**Super+D**) to see the rows. If they do not appear:

1. Check the file parses. A missing comma or quote makes the whole file fail.  
2. Then `omarchy restart shell`.

Open a submenu directly by id or alias, handy for testing and for your own keybinds:

```bash
omarchy menu summon personal
```

## Related

- **Super+D** opens the menu in this rice (`hypr/bindings.lua`: `o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")`). Stock Omarchy uses **Super+Space**, which this rice uses to switch keyboard layout.  
- `omarchy menu keybindings` shows every keybind in a searchable menu; `hyprctl binds` prints the live list in a terminal.  
