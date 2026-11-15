import QtQuick
import QtQuick.Layouts
import qs.Commons

// Side-by-side: unsmoothed reference vs the current settings, then live text.
ColumnLayout {
  id: root
  property var status: ({})
  property color foreground: Color.foreground
  property color background: Color.background
  property string fontFamily: Style.font.family
  spacing: Style.space(8)

  readonly property var reference: ({ antialias: false, hinting: false, hintstyle: "hintnone",
                                      rgba: "none", lcdfilter: "lcdnone" })
  readonly property color dim: Qt.darker(foreground, 1.55)

  RowLayout {
    Layout.fillWidth: true
    spacing: Style.space(10)
    Item { Layout.fillWidth: true }
    GlyphView { s: root.reference; title: "No smoothing"
                foreground: root.foreground; background: root.background; fontFamily: root.fontFamily }
    GlyphView { s: root.status; title: "Your settings"
                foreground: root.foreground; background: root.background; fontFamily: root.fontFamily }
    Item { Layout.fillWidth: true }
  }

  Text {
    Layout.fillWidth: true
    Layout.preferredWidth: 0
    horizontalAlignment: Text.AlignHCenter
    wrapMode: Text.WordWrap
    text: "Each square is one screen pixel, magnified. Soft edges are antialiasing; colored edges are subpixel rendering; edges that sit exactly on pixel rows are hinting."
    textFormat: Text.PlainText
    color: root.dim
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
  }

  // Live sample using Qt's hinting hints (approximation of other apps).
  Text {
    Layout.fillWidth: true
    Layout.preferredWidth: 0
    horizontalAlignment: Text.AlignHCenter
    text: "Sphinx of black quartz, judge my vow"
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: 15
    font.hintingPreference: !root.status.hinting || root.status.hintstyle === "hintnone"
      ? Font.PreferNoHinting
      : (root.status.hintstyle === "hintslight" ? Font.PreferVerticalHinting : Font.PreferFullHinting)
    renderType: root.status.rgba !== "none" ? Text.NativeRendering : Text.QtRendering
    elide: Text.ElideRight
  }
}
