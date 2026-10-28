# Learn Omarchy Hyprland step by step

Omarchy runs **Hyprland with Lua helpers** (`hl.*`, `o.*`), a Quickshell bar, themes, and a menu. This page teaches that layer so you can configure Omarchy’s Hyprland yourself — not only this rice.

Upstream: [omarchy.org](https://omarchy.org) · [github.com/omacom/omarchy](https://github.com/omacom/omarchy)

If you are new to Hyprland concepts (reload, monitors, binds), start with [Learn Hyprland](Learn-Hyprland).

---

## 1. Two trees: package defaults vs your config

| Path | Role |
|------|------|
| `/usr/share/omarchy/` | **Package** — Omarchy ships this. Updates **overwrite** it. **Read only.** |
| `~/.config/hypr/` | **Yours** — overrides and personal files. Edit here. |
| `~/.config/omarchy/` | **Yours** — bar (`shell.json`), plugins, menu extensions, themes tpl |

```text
/usr/share/omarchy/default/hypr/
├── bootstrap.lua      # path / env setup
├── omarchy.lua        # pulls in Omarchy defaults
├── bindings/          # stock keybindings (utilities.lua = menu, capture, …)
├── apps/
├── looknfeel.lua
├── toggles/           # per-workspace layout saves, etc.
└── …

~/.config/hypr/
├── hyprland.lua       # entry: load Omarchy, then your modules
├── monitors.lua
├── input.lua
├── looknfeel.lua
├── bindings.lua
└── autostart.lua
```

**Golden rule:** discover stock behavior under `/usr/share/omarchy/…`, then **unbind + rebind** in `~/.config/hypr/bindings.lua`. Never patch the package tree.

---

## 2. How your `hyprland.lua` loads (Omarchy order)

Typical Omarchy user entry (this rice):

```lua
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")
require("default.hypr.omarchy")   -- all Omarchy defaults

require("hypr.monitors")          -- your files (after defaults)
require("hypr.input")
require("hypr.looknfeel")
require("hypr.bindings")
require("hypr.autostart")

require("default.hypr.toggles")   -- restores saved per-workspace layouts
-- then your workspace rules / assign() / window rules…
```

Later rules override earlier ones. That is why this rice **forces hy3** on workspaces **after** `toggles`.

Optional flags (in `hyprland.lua` comments):

- `omarchy_default_bindings = false` — drop all Omarchy binds  
- `omarchy_preinstalled_bindings = false` — drop only preinstalled-app binds  

---

## 3. Omarchy helpers you will use every day

| Helper | Purpose | Example |
|--------|---------|---------|
| `o.bind(key, label, action)` | Bind + show in Omarchy cheatsheet | `o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")` |
| `o.window(class, opts)` | Window rule | `o.window("mpv", { workspace = "5 silent" })` |
| `o.exec_on_start(cmd)` | Shell once at login | Conky, `hyprpm reload` |
| `o.launch_on_start(cmd)` | App at login (uwsm-friendly) | Dropdown Kitty |
| `{ launch = "app" }` | Launch via Omarchy/uwsm | `{ launch = "konsole" }` |
| `hl.config({…})` | Hyprland settings | gaps, blur, input |
| `hl.dispatch(…)` | One-shot compositor action | focus workspace |
| `hl.unbind(key)` | Remove existing bind | Before rebinding Omarchy keys |
| `hl.plugin.hy3` | hy3 API when plugin loaded | `hy3.move_focus("l")` |

List cheatsheet labels:

```bash
omarchy menu keybindings --print
```

---

## 4. Exercise: move the Omarchy menu key

Stock Omarchy binds the menu on **Super+Space** (in packaged `bindings/utilities.lua`). This rice moves it to **Super+D**.

**Do it yourself:**

1. Confirm stock (read-only):

```bash
rg -n "Omarchy menu" /usr/share/omarchy/default/hypr/bindings/ || true
omarchy menu keybindings --print | rg -i menu
```

2. In `~/.config/hypr/bindings.lua`:

```lua
pcall(hl.unbind, "SUPER + SPACE")   -- or your unbind() helper
o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")
```

3. Reload and verify:

```bash
hyprctl reload
hyprctl configerrors
hyprctl binds | rg -A2 'Omarchy menu'
```

You should see Super+D, not Super+Space, for the menu.

---

## 5. Exercise: change gaps the Omarchy way

Edit `~/.config/hypr/looknfeel.lua` (loads **after** Omarchy looknfeel):

```lua
hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 3,
    border_size = 0,
    layout = "hy3",  -- only if hy3 is loaded
  },
})
```

```bash
hyprctl reload && hyprctl configerrors
hyprctl getoption general:gaps_in
```

---

## 6. Exercise: assign an app to a workspace

1. Focus the app → `hyprctl activewindow` → note `class:`  
2. In `hyprland.lua`:

```lua
local function assign(class, workspace, focus)
  o.window(class, {
    workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent"),
  })
end

assign("(dolphin|org%.kde%.dolphin)", 4, false)  -- open on 4, stay here
```

3. Reload; open Dolphin from another workspace — it should land on 4 without stealing focus if `focus = false`.

Full list in this rice: [Hyprland Core](Hyprland-Core).

---

## 7. Omarchy shell / bar (Quickshell)

Hyprland is only half of the desktop. The **bar and menu** are Omarchy shell:

| File | Job |
|------|-----|
| `~/.config/omarchy/shell.json` | Bar position, widget order, idle lock |
| `~/.config/omarchy/shell.toml` | Font base size |
| `~/.config/omarchy/themed/shell.toml.tpl` | Theme template (bar glass alpha, …) |
| `~/.config/omarchy/plugins/` | Cloned / third-party plugins |
| `~/.config/omarchy/extensions/omarchy-menu.jsonc` | Extra menu rows |

```bash
omarchy bar position bottom
omarchy bar move omarchy.clock --section right
omarchy plugin list
omarchy restart shell
omarchy theme list
omarchy theme set "Catppuccin"
omarchy theme refresh
```

Deep pages: [Status Bar](Status-Bar), [Themes and Fonts](Themes-and-Fonts), [Plugins](Plugins), [Menu Extensions](Menu-Extensions).

---

## 8. Themes vs Hyprland colors

`omarchy theme set …` regenerates:

- Bar / shell colors  
- Terminal theme files under `~/.local/state/omarchy/current/theme/`  
- Many GTK-facing settings  

Your Lua still owns **gaps, hy3 tabs, binds, window rules**. Theme does not replace `bindings.lua`.

Bar glass (translucent fill) = `background-alpha` in `themed/shell.toml.tpl` + blur in `looknfeel.lua`. See [Themes and Fonts](Themes-and-Fonts).

---

## 9. Environment on Arch (non-Omarchy OS)

If you layered Omarchy packages on Arch:

```bash
# ~/.config/environment.d/99-omarchy-dotfiles.conf
OMARCHY_PATH=/usr/share/omarchy
PATH=/usr/share/omarchy/bin:${PATH}
```

Re-login after creating it. Details: [Arch Linux](Arch-Linux).

---

## 10. Omarchy CLI cheat sheet

```bash
omarchy                          # help / menu surface
omarchy restart shell
omarchy restart hyprsunset
omarchy theme list|current|set|refresh|bg next
omarchy bar position|move|transparent|set
omarchy plugin list|enable|disable|clone
omarchy menu toggle
omarchy menu keybindings --print
omarchy-capture-screenshot fullscreen
```

---

## 11. What to learn next

| Goal | Page |
|------|------|
| Rebuild this rice in order | [Build This Rice](Build-This-Rice) |
| Every key in this keymap | [Keybinding Cheatsheet](Keybinding-Cheatsheet) |
| hy3 glass + auto tabs | [Look and Feel](Look-and-Feel) |
| Bar widgets | [Status Bar](Status-Bar) |
| When something breaks | [Troubleshooting](Troubleshooting) |

In-repo deep dive (same machine story, long form):  
[`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
