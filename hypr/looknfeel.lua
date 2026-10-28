-- i3-style look on top of hy3. See https://github.com/outfoxxed/hy3
-- Naming the hy3 layout before the plugin is loaded deadlocks NVIDIA
-- renderer startup on this laptop. Autostart loads the plugin, then reloads.
local layout = hl.plugin.hy3 ~= nil and "hy3" or "dwindle"

hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 3,
    border_size = 0,
    layout = layout,
  },
})

-- Omarchy turns blur off. hy3 tab glass and the translucent Omarchy bar need it.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
    },
  },
})

-- Frosted glass behind the Omarchy status bar (namespace omarchy-bar).
hl.layer_rule({
  match = { namespace = "omarchy-bar" },
  blur = true,
  ignore_alpha = true,
  no_anim = true,
  animation = "none",
})

hl.config({
  binds = {
    -- Pressing the key for the workspace you are already on goes back.
    workspace_back_and_forth = true,
  },
})

-- Tab titles are the i3 title bar: flush to the window, blurred glass.
-- A workspace with one window stays a plain split, so it has no title bar.
-- A second window turns that container into tabs.
-- padding=0 avoids the "box inside a box" gap under the bar. Blur needs
-- translucent fills (hy3 docs).
if hl.plugin.hy3 ~= nil then
  hl.config({
    plugin = {
      hy3 = {
        tab_first_window = false,
        group_inset = 0,
        tabs = {
          height = 22,
          padding = 0,
          render_text = true,
          text_center = true,
          text_font = "JetBrainsMono Nerd Font",
          text_height = 8,
          text_padding = 3,
          border_width = 1,
          radius = 0,
          blur = true,
          opacity = 1.0,
          colors = {
            -- Glass strip; active tab keeps a strong red border, same text as others.
            active = "rgba(ff202030)",
            active_border = "rgba(ff2020ff)",
            active_text = "rgba(ffffffaa)",
            active_alt_monitor = "rgba(cdd6f418)",
            active_alt_monitor_border = "rgba(ff2020aa)",
            active_alt_monitor_text = "rgba(ffffffaa)",
            focused = "rgba(cdd6f418)",
            focused_border = "rgba(bac2de66)",
            focused_text = "rgba(ffffffaa)",
            inactive = "rgba(cdd6f410)",
            inactive_border = "rgba(00000000)",
            inactive_text = "rgba(ffffffaa)",
            urgent = "rgba(f38ba840)",
            urgent_border = "rgba(f38ba8ee)",
            urgent_text = "rgba(f38ba8ff)",
            locked = "rgba(f9e2af40)",
            locked_border = "rgba(f9e2afee)",
            locked_text = "rgba(f9e2afff)",
          },
        },
        autotile = {
          enable = false,
        },
      },
    },
  })

  local function active_workspace_id()
    for _, workspace in ipairs(hl.get_workspaces()) do
      if workspace.active then
        return workspace.id
      end
    end
  end

  local function tiled_windows(workspace_id, except_address)
    local count = 0

    for _, window in ipairs(hl.get_windows()) do
      if window.workspace and window.workspace.id == workspace_id and not window.floating and window.address ~= except_address then
        count = count + 1
      end
    end

    return count
  end

  local function apply_titlebar(workspace_id, except_address)
    if workspace_id == nil then
      return
    end

    local previous = active_workspace_id()
    -- hy3:changegroup only changes the focused workspace, so a window that
    -- opens on another workspace needs a focus hop. That hop warps the pointer
    -- to the middle of the window over there, then to the middle of this one.
    local switched = previous ~= nil and previous ~= workspace_id
    local saved_no_warps = hl.get_config("cursor.no_warps")
    local saved_warp_workspace = hl.get_config("cursor.warp_on_change_workspace")

    if switched then
      hl.config({
        cursor = {
          no_warps = true,
          warp_on_change_workspace = 0,
        },
      })
    end

    local ok, err = pcall(function()
      if switched then
        hl.dispatch(hl.dsp.focus({ workspace = tostring(workspace_id) }))
      end

      if tiled_windows(workspace_id, except_address) <= 1 then
        hl.dispatch(hl.plugin.hy3.change_group("h"))
      else
        hl.dispatch(hl.plugin.hy3.change_group("tab"))
      end

      if switched and active_workspace_id() ~= previous then
        hl.dispatch(hl.dsp.focus({ workspace = tostring(previous) }))
      end
    end)

    if switched then
      hl.config({
        cursor = {
          no_warps = saved_no_warps,
          warp_on_change_workspace = saved_warp_workspace,
        },
      })
    end

    if not ok then
      error(err)
    end
  end

  local function sync_titlebar(window, except_address)
    if window == nil or window.floating or window.workspace == nil or window.workspace.special then
      return
    end

    apply_titlebar(window.workspace.id, except_address)
  end

  hl.on("window.open", function(window)
    sync_titlebar(window)
  end)

  hl.on("window.close", function(window)
    sync_titlebar(window, window and window.address)
  end)

  hl.on("window.move_to_workspace", function(window, workspace)
    sync_titlebar(window)

    if workspace and not workspace.special then
      apply_titlebar(workspace.id)
    end
  end)

  for _, workspace in ipairs(hl.get_workspaces()) do
    if not workspace.special and tiled_windows(workspace.id) <= 1 then
      apply_titlebar(workspace.id)
    end
  end
end
