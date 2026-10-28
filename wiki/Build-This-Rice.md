# Build this rice step by step

Ordered rebuild of the **omarchy-dotfiles** desktop: hy3 (i3 containers), keymap, look, autostart, bar. Do the steps **in order**. Each step assumes the previous one works.

**Prereq:** Omarchy OS, *or* Arch with [Arch Linux](Arch-Linux) stack installed. Prefer [Installation](Installation) first if you only want a copy-paste install — this page is for **learning by building**.

After every Lua edit:

```bash
hyprctl reload
hyprctl configerrors    # must print nothing
```

Never edit `/usr/share/omarchy/`.

---

## Step 0 — Install apps your keys will launch

```bash
sudo pacman -S --needed hyprpm konsole kitty dolphin brave firefox \
  viewnior gwenview grim wl-clipboard jq wev
```

---

## Step 1 — Install and enable hy3

```bash
hyprpm add https://github.com/outfoxxed/hy3
hyprpm enable hy3
hyprpm update
hyprpm reload
hyprpm list
hyprctl plugin list
hyprctl repl 'return hl.plugin.hy3 ~= nil'   # expect true
```

Binary path: `/var/cache/hyprpm/$USER/hy3/hy3.so`

**NVIDIA note:** loading hy3 during cold compositor start can deadlock. This rice loads via autostart (`hyprpm reload && hyprctl reload`) instead of forcing `hl.plugin.load` in cold-start `hyprland.lua`. See [Autostart](Autostart).

---

## Step 2 — Turn on hy3 layout + glass tabs

Edit `~/.config/hypr/looknfeel.lua`:

- `general.layout = "hy3"` (when plugin present)  
- `gaps_in` / `gaps_out` / `border_size`  
- `decoration.blur.enabled = true` (Omarchy turns blur off; tabs need it)  
- `plugin.hy3.tabs.*` colors/height/padding  
- Optional: auto tab/split listeners (`window.open` / `close`)  

Full explanation: [Look and Feel](Look-and-Feel).

Verify:

```bash
hyprctl getoption general:layout
hyprctl getoption decoration:blur:enabled
```

---

## Step 3 — Defeat saved layouts that kill hy3

Omarchy’s Super+L can save dwindle/scrolling per workspace under:

```text
~/.local/state/omarchy/workspace-layouts/
```

Those rules win over `general.layout`. In `hyprland.lua` **after** `require("default.hypr.toggles")`, force workspaces 1–12 to hy3. **Unbind Super+L** in `bindings.lua` so new bad files are not written.

Check:

```bash
hyprctl repl 'local s=""
for _, w in ipairs(hl.get_workspaces()) do
  s = s .. w.id .. "=" .. tostring(w.tiled_layout) .. " "
end
return s'
```

Every important id should say `hy3`.

---

## Step 4 — Keybindings (unbind Omarchy, then i3-style)

In `~/.config/hypr/bindings.lua`:

1. `pcall(hl.unbind, key)` for every key Omarchy owns that you will reuse  
2. `o.bind(key, "Label", action)` with hy3 Lua APIs — **not** string `hyprctl dispatch hy3:…`  
3. Put hot corners / bar peek **above** the `if hy3 == nil then return end` so they work on cold start  

| Pattern | API |
|---------|-----|
| Focus | `hy3.move_focus("l"/"d"/"u"/"r")` |
| Move | `hy3.move_window(…)` |
| Split | `hy3.make_group("h"|"v")` |
| Tabs | `hy3.change_group("toggletab")` |
| Kill | `hy3.kill_active()` |

i3 → Hyprland map and keycodes: [Keybindings](Keybindings) · [Keybinding Cheatsheet](Keybinding-Cheatsheet).

Find unknown keys:

```bash
wev    # note keycode; Hyprland code: is often X code
```

Verify a bind loaded:

```bash
hyprctl binds | rg -A2 'Focus left'
```

`modmask: 64` ≈ Super · `65` ≈ Super+Shift · `8` ≈ Alt.

---

## Step 5 — Workspaces, names, app assigns

In `hyprland.lua`:

1. Smart gaps: `w[tv1]`, `f[1]`  
2. `workspace_names` table + rename loop  
3. `assign(class, workspace, focus)` for Brave, Dolphin, mpv, …  
4. Special rules: tiled mpv, Viewnior no cursor steal, dropdown Kitty  

Learn a class:

```bash
hyprctl activewindow | awk '/class:|title:/'
```

Guide: [Hyprland Core](Hyprland-Core).

---

## Step 6 — Autostart

`~/.config/hypr/autostart.lua` (login only):

```lua
o.exec_on_start("hyprpm reload && hyprctl reload")   -- delayed hy3
o.exec_on_start(os.getenv("HOME") .. "/.config/conky/start-lcc.sh")
o.launch_on_start("kitty --class dropdown.terminal")
```

- [Autostart](Autostart) · [Dropdown Terminal](Dropdown-Terminal) · [Conky](Conky)

---

## Step 7 — Monitors & input (per machine)

```bash
hyprctl monitors all
$EDITOR ~/.config/hypr/monitors.lua
$EDITOR ~/.config/hypr/input.lua      # e.g. us,ara + Win+Space
```

[Monitors and Input](Monitors-and-Input)

Optional per-window layout: [Per-window keyboard](Per-Window-Keyboard).

---

## Step 8 — Status bar & Omarchy shell

1. `~/.config/omarchy/shell.json` — position `bottom`, layout, `bar.id = mahmoud.bar`  
2. Clone plugins if needed: `omarchy plugin clone omarchy.bar` / `omarchy.network`  
3. Custom modules: [Hardware Stats](Hardware-Stats), [Wallpaper Widget](Wallpaper-Widget)  
4. Glass: `themed/shell.toml.tpl` → `background-alpha` + blur layer rule  

```bash
omarchy restart shell
```

[Status Bar](Status-Bar) · [Plugins](Plugins) · [Themes and Fonts](Themes-and-Fonts)

---

## Step 9 — Screenshots, night light, portal

- Super+S fullscreen · Super+Shift+S focused script → [Screenshots](Screenshots)  
- `hyprsunset.conf` → [Night Light and Portal](Night-Light-and-Portal)  
- `xdph.conf` screencopy tokens  

---

## Step 10 — Acceptance checks

```bash
hyprctl reload && hyprctl configerrors
hyprctl plugin list
hyprctl getoption general:layout
```

On a workspace with **two** windows:

- Super+Arrows focus · Super+Shift+Arrows move  
- Super+Q kill · Super+H / V / W layout  
- Super+Return opens terminal  

One window → no hy3 title bar; second window → tabs (if auto titlebar enabled).

If a key does nothing:

1. `hyprctl configerrors`  
2. `hyprctl repl 'return hl.plugin.hy3 ~= nil'`  
3. `hyprctl binds` — is your description there?  
4. Workspace layout still hy3?  
5. Did you forget `unbind` so Omarchy still owns the key?  

---

## Fast path: copy finished files

After hy3 works on the new laptop, copy from this repo via `./install.sh`, then **only** retune `monitors.lua` and `input.lua`.

Or copy selectively:

```text
~/.config/hypr/{hyprland,looknfeel,bindings,autostart}.lua
~/.config/omarchy/shell.json   # and plugins/bar as needed
```

Long-form original narrative: [`docs/hypr-i3-setup.md`](https://github.com/mysh264/omarchy-dotfiles/blob/main/docs/hypr-i3-setup.md)
