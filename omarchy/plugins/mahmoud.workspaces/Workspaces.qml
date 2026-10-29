import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
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

  // Same names as workspace_names in ~/.config/hypr/hyprland.lua. Used for
  // workspaces Hyprland has not created yet (empty ones have no name to read).
  readonly property var workspaceNames: [
    "1:  ",
    "2:  ",
    "3:  ",
    "4:  ",
    "5:  ",
    "6:  ",
    "7:  ",
    "8:  ",
    "9:  ",
    "10:  ",
    "11:  ",
    "12:  "
  ]

  function workspaceIds() {
    var ids = []
    for (var i = 1; i <= root.workspaceNames.length; i++) ids.push(i)
    return ids
  }

  function workspaceLabel(id, workspace) {
    if (workspace !== null && workspace.name && workspace.name !== String(id)) return workspace.name.trim()
    return (root.workspaceNames[id - 1] || String(id)).trim()
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
