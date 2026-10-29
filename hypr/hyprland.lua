-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- hy3 is loaded by autostart after the compositor is up. Loading it while
-- the NVIDIA renderer is still being created deadlocks this laptop, so
-- Hyprland never finishes startup and the login times out.

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.looknfeel")
require("hypr.bindings")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Omarchy remembers a per-workspace layout from Super+L. Those saved rules
-- were putting workspaces 1, 2, 3, and 7 back on scrolling or dwindle, so hy3
-- focus, move, and close did nothing there. This runs after that restore.
-- On a cold start hy3 is not loaded yet; naming that layout here deadlocks
-- the NVIDIA renderer. The autostart reload applies hy3 once the plugin is in.
local workspace_layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"
if hl.plugin.hy3 == nil then
  hl.config({ general = { layout = "dwindle" } })
end
for id = 1, 12 do
  hl.workspace_rule({ workspace = tostring(id), layout = workspace_layout })
end

-- Add any other personal Hyprland configuration below.

-- Smart gaps (i3 smart_gaps): no gaps when a workspace has one visible tiled
-- window (w[tv1]; a hy3 tab group counts as one) or a maximized window (f[1]).
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })

local workspace_names = {
  "1:  ",
  "2:  ",
  "3: ",
  "4:  ",
  "5:  ",
  "6:  ",
  "7:  ",
  "8:  ",
  "9:  ",
  "10:  ",
  "11:  ",
  "12:  ",
}

for id, name in ipairs(workspace_names) do
  hl.workspace_rule({ workspace = tostring(id), default_name = name })
  -- Existing workspaces keep their old name until renamed. Empty ones pick up default_name.
  pcall(function()
    hl.dispatch(hl.dsp.workspace.rename({ workspace = tostring(id), name = name }))
  end)
end

-- assign: move the window and stay here. focus: move it and switch to that workspace.
local function assign(class, workspace, focus)
  o.window(class, { workspace = focus and tostring(workspace) or (tostring(workspace) .. " silent") })
end

-- Terminals open on the workspace you are on. They are not assigned.
assign("(Brave-browser|brave-browser)", 2, true)
assign("([Ff]irefox|org\\.mozilla\\.firefox)", 2, true)
assign("(dolphin|org\\.kde\\.dolphin)", 4, false)
assign("(kate|org\\.kde\\.kate)", 3, true)
assign("mpv", 5, false)
assign("(haruna|org\\.kde\\.haruna)", 5, false)
assign("(Viewnior|viewnior)", 6, false)

-- Omarchy tags mpv as a floating window and pins it at 875x600, centered.
-- That tag is applied before this file loads. Drop it and tile the window
-- so mpv opens as a normal tiled window.
o.window("^(mpv)$", { tag = "-floating-window", tile = true, float = false })

-- Viewnior asks to be focused as soon as it maps. Hyprland then warps the
-- pointer to the middle of that window. Opening an image should leave the
-- cursor where it was. Clicking the window still focuses it.
o.window("(Viewnior|viewnior)", { no_initial_focus = true, focus_on_activate = false })
assign("(gwenview|org\\.kde\\.gwenview)", 6, false)
assign("(Stremio|stremio)", 7, true)
assign("(Kodi|kodi)", 7, true)
assign("(Jellyfin Media Player|jellyfinmediaplayer|com\\.github\\.iwalton3\\.jellyfin-media-player|jellyfin-desktop)", 7, false)
assign("(qBittorrent|org\\.qbittorrent\\.qBittorrent)", 8, true)
assign("(org\\.mozilla\\.Thunderbird|[Tt]hunderbird)", 9, true)
assign("(Typora|typora)", 10, true)
assign("(plasma-systemmonitor|org\\.kde\\.plasma-systemmonitor)", 11, true)
assign("(systemsettings|org\\.kde\\.systemsettings|kinfocenter|org\\.kde\\.kinfocenter|Firewall-config|firewall-config|Gnome-disks|org\\.gnome\\.DiskUtility|partitionmanager|org\\.kde\\.partitionmanager|GParted|gparted|com\\.github\\.tchx84\\.Flatseal|Grub-customizer|grub-customizer)", 12, true)

-- TildaZ dropdown terminal. "tildaz --desktop add" writes hypr/tildaz.lua
-- (autostart at login); "tildaz --desktop remove" deletes it. pcall skips it
-- on machines without TildaZ. Toggle keys are in bindings.lua, look in looknfeel.lua.
pcall(require, "tildaz")
