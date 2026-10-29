-- Extra autostart processes.
-- hy3 deadlocks NVIDIA renderer startup on this laptop, so it is not loaded
-- from hyprland.lua. Load it once Hyprland is up, then re-read the config so
-- the hy3 layout and keybindings apply. hyprland.start does not fire on reload.
o.exec_on_start("hyprpm reload && hyprctl reload")

-- Lean Conky Config. start-lcc.sh waits 3 seconds, kills a previous copy
-- started by this script, and installs its font. This runs on login only.
o.exec_on_start((os.getenv("HOME") or "") .. "/.config/conky/start-lcc.sh")

-- TildaZ (dropdown terminal) starts itself from hypr/tildaz.lua, which
-- "tildaz --desktop add" writes and hyprland.lua loads.
