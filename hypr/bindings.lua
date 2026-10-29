-- i3 keymap. Conflicting Omarchy binds are removed first.
-- hy3 dispatchers move and focus whole containers, the way i3 does.

local function unbind(key)
  pcall(hl.unbind, key)
end

-- Hot corners. The square is the trigger; the pointer has to leave the
-- larger square before the same corner can fire again, so resting there
-- does not repeat. Coordinates are the monitor under the cursor.
local corner_size = 8
local corner_release = 48
local corners_armed = { tl = true, tr = true, br = true }

local function corner_distance(pos, monitor, name)
  local x = name:find("l", 1, true) and monitor.x or (monitor.x + monitor.width - 1)
  local y = name:find("t", 1, true) and monitor.y or (monitor.y + monitor.height - 1)
  return math.max(math.abs(pos.x - x), math.abs(pos.y - y))
end

-- The bar lives on the bottom edge. Hiding writes the bar-off flag; a peek
-- removes that flag without forgetting that the bar should hide again.
local bar_flag = (os.getenv("HOME") or "") .. "/.local/state/omarchy/toggles/bar-off"
local bar_edge = 4
local bar_hover = 36
local bar_linger_ms = 400
local bar_latched_hidden = false
local bar_peeking = false
local bar_hide_generation = 0
local bar_pointer_on_bar = false

local function bar_flag_exists()
  local file = io.open(bar_flag, "r")
  if file then
    file:close()
    return true
  end
  return false
end

local function set_bar_hidden(hidden)
  local flag = string.format("%q", bar_flag)
  local directory = string.format("%q", (os.getenv("HOME") or "") .. "/.local/state/omarchy/toggles")
  local shell
  if hidden then
    shell = "mkdir -p " .. directory .. " && touch " .. flag
  else
    shell = "rm -f " .. flag
  end
  hl.exec_cmd(shell .. " && omarchy-shell -q omarchy.bar syncHidden")
end

local function set_bar_overlay(overlay)
  hl.exec_cmd("omarchy-shell -q omarchy.bar setOverlay " .. (overlay and "yes" or "no"))
end

local function cancel_bar_hide()
  bar_hide_generation = bar_hide_generation + 1
end

local function schedule_bar_hide()
  bar_hide_generation = bar_hide_generation + 1
  local generation = bar_hide_generation
  hl.timer(function()
    if generation ~= bar_hide_generation or not bar_peeking or not bar_latched_hidden then
      return
    end
    bar_peeking = false
    bar_pointer_on_bar = false
    set_bar_overlay(false)
  end, { timeout = bar_linger_ms, type = "oneshot" })
end

local function toggle_bar()
  bar_latched_hidden = not bar_latched_hidden
  bar_peeking = false
  bar_pointer_on_bar = false
  cancel_bar_hide()
  set_bar_overlay(false)
  set_bar_hidden(bar_latched_hidden)
end

bar_latched_hidden = bar_flag_exists()

-- Super+M was not bound. Super+Shift+M stays Music.
unbind("SUPER + M")
o.bind("SUPER + M", "Hide bar", toggle_bar)

local function run_corner(name)
  if name == "tl" then
    toggle_bar()
  elseif name == "tr" then
    hl.dispatch(hl.dsp.focus({ workspace = "97" }))
  elseif name == "br" then
    hl.dispatch(hl.dsp.focus({ workspace = "previous" }))
  end
end

local function pointer_on_bottom_edge(pos, monitor)
  return pos.y >= monitor.y + monitor.height - bar_edge
end

local function pointer_on_bar(pos, monitor)
  return pos.y >= monitor.y + monitor.height - bar_hover
end

hl.timer(function()
  local pos = hl.get_cursor_pos()
  local monitor = hl.get_monitor_at_cursor()
  if pos == nil or monitor == nil then
    return
  end

  for _, name in ipairs({ "tl", "tr", "br" }) do
    local distance = corner_distance(pos, monitor, name)
    if distance <= corner_size then
      if corners_armed[name] then
        corners_armed[name] = false
        run_corner(name)
      end
    elseif distance >= corner_release then
      corners_armed[name] = true
    end
  end

  if not bar_latched_hidden then
    return
  end

  if not bar_peeking then
    if pointer_on_bottom_edge(pos, monitor) then
      bar_peeking = true
      bar_pointer_on_bar = true
      cancel_bar_hide()
      set_bar_overlay(true)
    end
    return
  end

  if pointer_on_bar(pos, monitor) then
    if not bar_pointer_on_bar then
      bar_pointer_on_bar = true
      cancel_bar_hide()
    end
  elseif bar_pointer_on_bar then
    bar_pointer_on_bar = false
    schedule_bar_hide()
  end
end, { timeout = 50, type = "repeat" })

local hy3 = hl.plugin.hy3
if hy3 == nil then
  -- Cold start has not loaded hy3 yet. autostart.lua loads it after the
  -- compositor is up and reloads this file, which is when these binds apply.
  return
end

-- Kitty on special:dropdown. Relaunches if the window was closed.
local function toggle_dropdown()
  return function()
    local exists = false
    for _, window in ipairs(hl.get_windows()) do
      if (window.class or "") == "dropdown.terminal" then
        exists = true
        break
      end
    end
    if not exists then
      -- hl.exec_cmd(o.launch("kitty --class dropdown.terminal"))
      hl.exec_cmd(o.launch("tildaz --toggle"))
      hl.timer(function()
        hl.dispatch(hl.dsp.workspace.toggle_special("dropdown"))
      end, { timeout = 200, type = "oneshot" })
      return
    end
    hl.dispatch(hl.dsp.workspace.toggle_special("dropdown"))
  end
end

local function focus_workspace_edge(last)
  return function()
    local best = nil
    for _, workspace in ipairs(hl.get_workspaces()) do
      if not workspace.special and workspace.id and workspace.id > 0 then
        if best == nil or (last and workspace.id > best) or (not last and workspace.id < best) then
          best = workspace.id
        end
      end
    end
    if best then
      hl.dispatch(hl.dsp.focus({ workspace = tostring(best) }))
    end
  end
end

local function kill_class(pattern)
  return function()
    for _, window in ipairs(hl.get_windows()) do
      local class = window.class or ""
      if class:lower():find(pattern, 1, true) then
        hl.dispatch(hl.dsp.window.close({ window = "address:" .. window.address }))
      end
    end
  end
end

-- These Omarchy binds use the same keys as the i3 config.
for _, key in ipairs({
  "SUPER + RETURN",
  "SUPER + SHIFT + RETURN",
  "SUPER + W",
  "SUPER + J",
  "SUPER + S",
  -- Was: Google Maps webapp (rebound to focused-window screenshot below).
  "SUPER + SHIFT + S",
  "SUPER + V",
  "SUPER + X",
  "SUPER + SHIFT + C",
  "SUPER + SHIFT + X",
  "SUPER + LEFT",
  "SUPER + RIGHT",
  "SUPER + UP",
  "SUPER + DOWN",
  "SUPER + SHIFT + LEFT",
  "SUPER + SHIFT + RIGHT",
  "SUPER + SHIFT + UP",
  "SUPER + SHIFT + DOWN",
  "SUPER + CTRL + LEFT",
  "SUPER + CTRL + RIGHT",
  -- Was: toggle this workspace between dwindle, scrolling, and hy3.
  "SUPER + L",
  -- Was: Omarchy menu (rebound to SUPER + D below).
  "SUPER + SPACE",
  "SUPER + code:20", -- minus (-)
  "SUPER + code:21", -- equal (=)
  "SUPER + SHIFT + code:20", -- minus
  "SUPER + SHIFT + code:21", -- equal
  "SUPER + mouse:273", -- right click
}) do
  unbind(key)
end

-- Workspace number row: code:(N + 9) → key N. Workspace 1 = code:10 … 10 = code:19.
for workspace = 1, 10 do
  unbind("SUPER + code:" .. tostring(workspace + 9))
  unbind("SUPER + SHIFT + code:" .. tostring(workspace + 9))
end

-- Omarchy menu. Default is SUPER + SPACE; this machine uses SUPER + D.
o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")

-- Applications.
o.bind("SUPER + RETURN", "Terminal", { launch = "konsole" })
o.bind("SUPER + SHIFT + RETURN", "Terminal (kitty)", { launch = "kitty" })
o.bind("SUPER + code:44", "Brave", { launch = "brave" }) -- J
o.bind("SUPER + SHIFT + code:44", "Firefox", { launch = "firefox" }) -- J
o.bind("SUPER + code:57", "Files", { launch = "dolphin" }) -- N
o.bind("XF86Favorites", "Dropdown terminal", { launch = "tildaz --toggle" })
o.bind("code:91", "Dropdown terminal", { launch = "tildaz --toggle" }) -- KP Delete
-- Side buttons. 275 is back, 276 is forward.
-- Do not pass mouse = true here. That flag is for drag and resize binds.
-- A click command with that flag never runs.
unbind("mouse:275")
unbind("mouse:276")
o.bind("mouse:275", "Previous workspace", hl.dsp.focus({ workspace = "previous" }))
o.bind("mouse:276", "Dropdown terminal", { launch = "tildaz --toggle" })

-- Close.
o.bind("SUPER + code:24", "Kill", hy3.kill_active()) -- Q
o.bind("code:115", "Kill", hy3.kill_active()) -- End
o.bind("SUPER + mouse:273", "Kill", hl.dsp.window.close(), { mouse = true }) -- right click
o.bind("SUPER + code:53", "Kill mpv", kill_class("mpv")) -- X
o.bind("SUPER + SHIFT + code:53", "Kill image viewers", "killall viewnior ; killall gwenview") -- X
o.bind("ALT + code:53", "Kill Dolphin", "killall dolphin") -- X

-- Focus and move. Arrow keys replace Omarchy's dwindle focus and swap.
o.bind("SUPER + LEFT", "Focus left", hy3.move_focus("l"))
o.bind("SUPER + DOWN", "Focus down", hy3.move_focus("d"))
o.bind("SUPER + UP", "Focus up", hy3.move_focus("u"))
o.bind("SUPER + RIGHT", "Focus right", hy3.move_focus("r"))
o.bind("SUPER + SHIFT + LEFT", "Move left", hy3.move_window("l"))
o.bind("SUPER + SHIFT + DOWN", "Move down", hy3.move_window("d"))
o.bind("SUPER + SHIFT + UP", "Move up", hy3.move_window("u"))
o.bind("SUPER + SHIFT + RIGHT", "Move right", hy3.move_window("r"))

o.bind("code:87", "Focus left", hy3.move_focus("l")) -- KP End / KP_1
o.bind("code:89", "Focus right", hy3.move_focus("r")) -- KP Next / KP_3
o.bind("code:79", "Move left", hy3.move_window("l")) -- KP Home / KP_7
o.bind("code:81", "Move right", hy3.move_window("r")) -- KP Prior / KP_9

-- Screenshots. Super+S was Omarchy scratchpad (unbound above).
o.bind("SUPER + S", "Screenshot fullscreen", "omarchy-capture-screenshot fullscreen")
o.bind("SUPER + SHIFT + S", "Screenshot focused window", (os.getenv("HOME") or "") .. "/.config/hypr/scripts/screenshot-focused")

-- Layout.
o.bind("SUPER + code:43", "Split horizontal", hy3.make_group("h")) -- H
o.bind("SUPER + code:55", "Split vertical", hy3.make_group("v")) -- V
o.bind("SUPER + code:25", "Toggle tabbed and split", hy3.change_group("toggletab")) -- W
o.bind("SUPER + code:26", "Toggle split direction", hy3.change_group("opposite")) -- E
o.bind("SUPER + code:52", "Float", hl.dsp.window.float({ action = "toggle" })) -- Z
o.bind("SUPER + code:38", "Focus parent", hy3.change_focus("raise")) -- A

-- Workspaces.
o.bind("SUPER + code:49", "Previous workspace", hl.dsp.focus({ workspace = "previous" })) -- grave (`)
o.bind("ALT + SPACE", "Workspace 10", hl.dsp.focus({ workspace = "10" }))
o.bind("SUPER + CTRL + LEFT", "Move to previous workspace", hy3.move_to_workspace("e-1", { follow = true }))
o.bind("SUPER + CTRL + RIGHT", "Move to next workspace", hy3.move_to_workspace("e+1", { follow = true }))

-- Number row: workspace N uses code:(N + 9). e.g. Super+1 → code:10, Super+2 → code:11.
for workspace = 1, 12 do
  local key = "code:" .. tostring(workspace + 9)
  o.bind("SUPER + " .. key, "Workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move to workspace " .. workspace, hy3.move_to_workspace(tostring(workspace), { follow = true }))
end

-- Numpad. These swallow the key in every app, matching the i3 bindcode lines.
o.bind("code:85", "Next workspace", hl.dsp.focus({ workspace = "e+1" })) -- KP Right / KP_6
o.bind("code:83", "Previous workspace", hl.dsp.focus({ workspace = "e-1" })) -- KP Left / KP_4
o.bind("code:90", "Previous workspace", hl.dsp.focus({ workspace = "previous" })) -- KP Insert / KP_0
o.bind("code:84", "Previous workspace", hl.dsp.focus({ workspace = "previous" })) -- KP Begin / KP_5
o.bind("code:80", "First workspace", focus_workspace_edge(false)) -- KP Up / KP_8
o.bind("code:88", "Last workspace", focus_workspace_edge(true)) -- KP Down / KP_2

-- Shift + numpad → workspace. Codes: KP_1..KP_9, KP_0 (87–90, 83–85, 79–81).
local shift_workspaces = {
  [87] = 1, -- KP End / KP_1
  [88] = 2, -- KP Down / KP_2
  [89] = 3, -- KP Next / KP_3
  [83] = 4, -- KP Left / KP_4
  [84] = 5, -- KP Begin / KP_5
  [85] = 6, -- KP Right / KP_6
  [79] = 7, -- KP Home / KP_7
  [80] = 8, -- KP Up / KP_8
  [81] = 9, -- KP Prior / KP_9
  [90] = 10, -- KP Insert / KP_0
}

for code, workspace in pairs(shift_workspaces) do
  o.bind("SHIFT + code:" .. code, "Workspace " .. workspace, hl.dsp.focus({ workspace = tostring(workspace) }))
end

-- Eat leftover numpad / nav keys so they do not type into apps.
-- 77 Num_Lock, 104 KP_Enter, 110 Home, 112 PageUp, 117 PageDown
for _, code in ipairs({ 77, 104, 110, 112, 117 }) do
  o.bind("code:" .. code, "Nop", hl.dsp.no_op())
end

-- Reload. Hyprland has no i3-style in-place restart, so both keys reload the config.
o.bind("SUPER + SHIFT + code:54", "Reload Hyprland", "hyprctl reload") -- C
o.bind("SUPER + SHIFT + code:27", "Reload Hyprland", "hyprctl reload") -- R
