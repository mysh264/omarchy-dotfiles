import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // Workspaces 1..alwaysShown are always on the bar. Higher ones (up to
  // maxWorkspaces) appear only while they exist, i.e. hold a window or are focused.
  readonly property int alwaysShown: 7
  readonly property int maxWorkspaces: Math.max(root.alwaysShown, root.workspaceNames.length || 12)

  // Names come from workspace_names in ~/.config/hypr/hyprland.lua, so empty
  // workspaces (which Hyprland has not created) show the same label as
  // occupied ones. The file is watched; saving it updates the bar.
  property var workspaceNames: []

  function parseWorkspaceNames(text) {
    var block = /workspace_names\s*=\s*\{([\s\S]*?)\n\}/.exec(text || "")
    if (!block) return []

    var names = []
    var re = /"([^"]*)"/g
    var match
    while ((match = re.exec(block[1])) !== null) names.push(match[1])
    return names
  }

  FileView {
    path: Quickshell.env("HOME") + "/.config/hypr/hyprland.lua"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: root.workspaceNames = root.parseWorkspaceNames(text())
    onLoadFailed: root.workspaceNames = []
  }

  function workspaceIds() {
    var ids = []
    for (var id = 1; id <= root.maxWorkspaces; id++) {
      if (id <= root.alwaysShown || root.workspaceById(id) !== null) ids.push(id)
    }
    return ids
  }

  function workspaceLabel(id, workspace) {
    var name = root.workspaceNames[id - 1]
    if (name) return name.trim()
    if (workspace !== null && workspace.name) return workspace.name.trim()
    return String(id)
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: root.workspaceLabel(modelData, workspace)
        active: focused
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : -1
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
