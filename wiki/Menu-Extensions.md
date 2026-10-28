# Menu Extensions

**File:** `omarchy/extensions/omarchy-menu.jsonc` → `~/.config/omarchy/extensions/omarchy-menu.jsonc`

Extends the Quickshell Omarchy menu with **JSONC** (JSON + comments). The shipped file is mostly documentation comments — add your rows below them.

## How IDs work

- Object keys are entry ids  
- Parent is inferred from the **dotted** id: `personal.notes` nests under `personal`; `personal` appears on the root menu  
- Reuse an existing id to **override / extend** a stock entry  

## Fields

| Field | Role |
|-------|------|
| `icon` | Nerd Font glyph in the icon column |
| `label` | Visible title |
| `action` | Shell command (omit → submenu only) |
| `target` | Open an existing submenu id (alias/link) |
| `provider` | Runtime provider returning JSON rows |
| `aliases` | Extra `omarchy menu summon <name>` routes + search |
| `description` | Subtitle / search text |
| `when` | Shell condition; hide when it fails |
| `checked` | Shell condition; show ✓ when true |

## Examples

```jsonc
{
  "personal": { "icon": "", "label": "Personal" },
  "personal.notes": {
    "icon": "󰎞",
    "label": "Notes",
    "action": "omarchy-launch-editor ~/notes"
  },
  "personal.files": {
    "icon": "",
    "label": "Files",
    "action": "uwsm-app -- nautilus ~/Documents"
  },

  // Override stock About
  "about": {
    "icon": "",
    "label": "About",
    "action": "omarchy-launch-or-focus-tui \"zsh -c 'fastfetch; read -k 1'\""
  }
}
```

Only use `provider` when a matching provider function/command exists and returns JSON rows. Static submenus only need dotted ids.

## Apply

Save the file; reopen the menu (Super+D). If entries missing: `omarchy restart shell`.

## Related

- Open menu: **Super+D** (this rice; stock Omarchy often uses Super+Space)  
- List keybindings: `omarchy menu keybindings --print`  
