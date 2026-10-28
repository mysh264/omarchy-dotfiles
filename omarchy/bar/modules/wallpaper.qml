import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property var bar
  property var settings

  property bool running: true
  property string wallpaperName: ""
  property string tooltip: "Wallpaper slideshow"

  readonly property color fg: bar ? bar.barForeground : Commons.Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property real barSize: bar ? bar.barSize : 26

  implicitWidth: row.implicitWidth + Style.space(8)
  implicitHeight: barSize

  function refresh() {
    if (!statusProc.running)
      statusProc.running = true
  }

  function runCmd(action) {
    if (bar)
      bar.run("wallpaper-slideshow --" + action)
    statusTimer.restart()
  }

  function applyStatus(raw) {
    try {
      var data = JSON.parse(String(raw || "").trim())
      running = data.running === true
      wallpaperName = data.name || ""
      tooltip = data.tooltip || wallpaperName || "Wallpaper slideshow"
    } catch (e) {
      // keep last known state
    }
  }

  Process {
    id: statusProc
    command: ["wallpaper-slideshow", "--status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.applyStatus(text)
    }
  }

  Timer {
    id: statusTimer
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: Style.space(2)

    WallpaperButton {
      iconText: "󰒮"
      tip: "Previous wallpaper"
      onActivated: root.runCmd("prev")
    }

    WallpaperButton {
      iconText: root.running ? "󰏤" : "󰐊"
      tip: root.running ? "Pause slideshow" : "Resume slideshow"
      emphasized: root.running
      onActivated: root.runCmd("toggle")
    }

    WallpaperButton {
      iconText: "󰒭"
      tip: "Next wallpaper"
      onActivated: root.runCmd("next")
    }
  }

  component WallpaperButton: Item {
    id: btn

    property string iconText: ""
    property string tip: ""
    property bool emphasized: false
    signal activated()

    width: Style.bar.iconSlot
    height: root.barSize

    Text {
      anchors.centerIn: parent
      textFormat: Text.PlainText
      text: btn.iconText
      color: btn.emphasized || mouse.containsMouse
        ? root.fg
        : Qt.darker(root.fg, 1.45)
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      Behavior on color {
        ColorAnimation { duration: 120 }
      }
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onClicked: btn.activated()
      onEntered: {
        var text = btn.tip
        if (root.wallpaperName)
          text += "\n" + root.wallpaperName
        if (root.bar)
          root.bar.showTooltip(root, text)
      }
      onExited: if (root.bar) root.bar.hideTooltip(root)
    }
  }

  MouseArea {
    anchors.fill: parent
    z: -1
    acceptedButtons: Qt.NoButton
    hoverEnabled: true
    onWheel: function(wheel) {
      if (wheel.angleDelta.y > 0)
        root.runCmd("prev")
      else if (wheel.angleDelta.y < 0)
        root.runCmd("next")
    }
    onEntered: if (root.bar) root.bar.showTooltip(root, root.tooltip)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }
}
