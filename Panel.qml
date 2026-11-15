import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "."

Panel {
  id: root
  moduleName: "josip.font-rendering"
  ipcTarget: "josip.font-rendering"
  manageIpc: false

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  property var status: ({ antialias: true, hinting: true, hintstyle: "hintslight",
                          rgba: "none", lcdfilter: "lcddefault" })
  property string note: ""

  function scriptPath() { return Qt.resolvedUrl("font_ctl.py").toString().replace(/^file:\/\//, "") }

  function apply(values) {
    var s = {}
    for (var k in root.status) s[k] = root.status[k]
    for (var n in values) s[n] = values[n]
    root.status = s
    applyProc.command = ["python3", scriptPath(), "apply", JSON.stringify(values)]
    applyProc.running = true
  }

  Process {
    id: statusProc
    running: true
    command: ["python3", root.scriptPath(), "status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { try { root.status = JSON.parse(text) } catch (e) {} }
    }
  }
  Process {
    id: applyProc
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { root.note = "Saved. Restart apps to apply."; noteTimer.restart() }
    }
  }
  Process {
    id: resetProc
    command: ["python3", root.scriptPath(), "reset"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: { try { root.status = JSON.parse(text) } catch (e) {}
                          root.note = "Reset to defaults"; noteTimer.restart() }
    }
  }
  Timer { id: noteTimer; interval: 3000; onTriggered: root.note = "" }

  IpcHandler {
    enabled: true
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰛖"
    tooltipText: "Font rendering"
    onPressed: function(code) { root.toggle() }
  }

  PopupCard {
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.opened
    contentWidth: Style.space(380)
    contentHeight: Style.space(800)

    ColumnLayout {
      anchors.fill: parent
      spacing: Style.space(12)

      Text {
        text: "Font Rendering"
        textFormat: Text.PlainText
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.title
        font.bold: true
      }

      Preview {
        Layout.fillWidth: true
        status: root.status
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Toggle {
        Layout.fillWidth: true
        label: "Antialiasing"
        description: "Smooth glyph edges"
        checked: root.status.antialias
        onClicked: root.apply({ antialias: !root.status.antialias })
      }

      Toggle {
        Layout.fillWidth: true
        label: "Hinting"
        description: "Snap glyphs to the pixel grid"
        checked: root.status.hinting
        onClicked: root.apply({ hinting: !root.status.hinting })
      }

      Text { text: "Hint style (none = softest)"; color: root.foreground
             font.family: root.fontFamily; font.pixelSize: Style.font.subtitle; font.bold: true }
      ButtonGroup {
        Layout.fillWidth: true
        options: [ { value: "hintnone", label: "None" }, { value: "hintslight", label: "Slight" },
                   { value: "hintmedium", label: "Medium" }, { value: "hintfull", label: "Full" } ]
        value: root.status.hintstyle
        onChanged: function(v) { root.apply({ hintstyle: v }) }
      }
      Text {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        text: ({ hintnone: "None: glyphs keep their true shapes. Softest, slightly blurry horizontals.", hintslight: "Slight: snaps glyphs vertically only. Crisp baselines, shapes stay natural.", hintmedium: "Medium: stronger snapping to the pixel grid. Sharper, more uniform stems.", hintfull: "Full: snaps everything to the grid. Sharpest but can distort letter shapes." })[root.status.hintstyle] || ""
      }

      Text { text: "Subpixel order"; color: root.foreground
             font.family: root.fontFamily; font.pixelSize: Style.font.subtitle; font.bold: true }
      ButtonGroup {
        Layout.fillWidth: true
        options: [ { value: "none", label: "Gray" }, { value: "rgb", label: "RGB" },
                   { value: "bgr", label: "BGR" }, { value: "vrgb", label: "VRGB" },
                   { value: "vbgr", label: "VBGR" } ]
        value: root.status.rgba
        onChanged: function(v) { root.apply({ rgba: v }) }
      }
      Text {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        text: ({ none: "Gray: one shade per pixel. No color fringes; best for OLED or rotated screens.", rgb: "RGB: uses the red, green and blue stripes of a standard LCD for finer horizontal detail.", bgr: "BGR: like RGB for panels with reversed stripe order. Pick this if RGB shows colored halos.", vrgb: "VRGB: stripes stacked vertically (rotated panel).", vbgr: "VBGR: reversed vertical stripes." })[root.status.rgba] || ""
      }

      Text { text: "LCD filter (subpixel only)"; color: root.foreground
             font.family: root.fontFamily; font.pixelSize: Style.font.subtitle; font.bold: true }
      ButtonGroup {
        Layout.fillWidth: true
        options: [ { value: "lcdnone", label: "Off" }, { value: "lcdlight", label: "Light" },
                   { value: "lcddefault", label: "Default" } ]
        value: root.status.lcdfilter
        onChanged: function(v) { root.apply({ lcdfilter: v }) }
      }
      Text {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        text: ({ lcdnone: "Off: raw subpixels. Sharpest, strongest color fringes.", lcdlight: "Light: mild blending. Small fringe reduction.", lcddefault: "Default: balanced blending between neighbouring subpixels.", lcdlegacy: "Legacy filter." })[root.status.lcdfilter] || ""
      }

      Item { Layout.fillHeight: true }

      Text {
        text: root.note
        textFormat: Text.PlainText
        color: root.dim
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        Layout.fillWidth: true
      }
      Button {
        Layout.fillWidth: true
        text: "Reset to defaults"
        onClicked: resetProc.running = true
      }
    }
  }
}
