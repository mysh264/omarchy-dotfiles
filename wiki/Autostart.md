# Autostart (`autostart.lua`)

**Repo:** `hypr/autostart.lua`  
**Live:** `~/.config/hypr/autostart.lua`

Runs **once at login** (not on every `hyprctl reload`). Keep this file short.

## Shipped lines

```lua
-- 1) Load hy3 after compositor is up, then re-read config
o.exec_on_start("hyprpm reload && hyprctl reload")

-- 2) Lean Conky (Wayland) — no-op if script missing
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")

-- 3) Dropdown Kitty for special:dropdown
o.launch_on_start("kitty --class dropdown.terminal")
```

## 1. Delayed hy3 load

**Why:** Loading hy3 during cold start can deadlock NVIDIA renderer startup → black screen / login timeout.

**What happens:** First config pass may use dwindle and skip hy3 binds. After `hyprpm reload && hyprctl reload`, looknfeel + bindings re-run with hy3 present.

Do not move this into an early `hl.plugin.load` in `hyprland.lua` unless you have verified your GPU.

## 2. Conky

Expects [lean-conky-config](https://github.com/mysh264/lean-conky-config) at `~/.config/conky/` (or `./install.sh --with-conky`).

- Remove the line if you do not use Conky  
- `start-lcc.sh` waits briefly, kills a previous copy, installs fonts  

## 3. Dropdown terminal

Class **must** remain `dropdown.terminal` to match the window rule in [Hyprland Core](Hyprland-Core). Size/opacity live in that rule, not here.

## Adding your own startups

```lua
o.exec_on_start("my-daemon --flag")           -- shell command once at login
o.launch_on_start("uwsm-app -- my-gui-app")   -- preferred for GUI apps on Omarchy
```

Example — enable night light daemon (see [Night Light and Portal](Night-Light-and-Portal)):

```lua
o.launch_on_start("hyprsunset")
```

## Debugging

```bash
# Did hy3 come up after login?
hyprctl plugin list
hyprctl getoption general:layout

# Conky process?
pgrep -a conky

# Dropdown window present?
hyprctl clients | grep -i dropdown
```
