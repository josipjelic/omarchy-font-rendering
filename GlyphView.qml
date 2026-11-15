import QtQuick
import QtQuick.Layouts
import qs.Commons

// Magnified pixel rendering of the letters "e l v" for a settings object.
ColumnLayout {
  id: root
  property var s: ({})
  property string title: ""
  property color foreground: Color.foreground
  property color background: Color.background
  property string fontFamily: Style.font.family
  spacing: Style.space(4)

  readonly property int cols: 24
  readonly property int rows: 13
  readonly property real cell: 6

  onSChanged: canvas.requestPaint()
  onForegroundChanged: canvas.requestPaint()
  onBackgroundChanged: canvas.requestPaint()

  Text {
    Layout.alignment: Qt.AlignHCenter
    text: root.title
    textFormat: Text.PlainText
    color: root.foreground
    font.family: root.fontFamily
    font.pixelSize: Style.font.caption
    font.bold: true
  }

  Rectangle {
    Layout.alignment: Qt.AlignHCenter
    width: root.cols * root.cell + 2
    height: root.rows * root.cell + 2
    color: "transparent"
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.25)

    Canvas {
      id: canvas
      x: 1; y: 1
      width: root.cols * root.cell
      height: root.rows * root.cell
      onPaint: {
        var ctx = getContext("2d")
        var s = root.s, c = root.cell
        var bg = root.background, fg = root.foreground
        ctx.clearRect(0, 0, width, height)

        var hint = s.hinting ? s.hintstyle : "hintnone"
        var snapV = hint !== "hintnone"                    // slight and up: vertical snap
        var snapH = hint === "hintmedium" || hint === "hintfull"   // stronger: also thin strokes
        var snapX = hint === "hintfull"                    // full: horizontal snap too
        var rd = function(v, on) { return on ? Math.round(v) : v }

        // "e": ellipse ring + crossbar. Raw geometry has fractional edges.
        var ecx = 5.6, ecy = 6.6, erx = 4.2, ery = 3.7
        var top = rd(ecy - ery, snapV), bot = rd(ecy + ery, snapV)
        ecy = (top + bot) / 2; ery = (bot - top) / 2
        var th = snapH ? 1 : 1.25
        var barY = rd(ecy - 0.4, snapV), barH = th
        // "l": vertical stem
        var lx = rd(12.35, snapX), lw = snapX ? 1 : 1.2
        var lt = rd(1.3, snapV), lb = rd(10.7, snapV)
        // "v": two diagonals
        var vx0 = 15.6, vx1 = 18.8, vx2 = 22.0, vt = rd(3, snapV), vb = rd(10.7, snapV)

        function seg(px, py, ax, ay, bx, by) {
          var dx = bx - ax, dy = by - ay
          var t = Math.max(0, Math.min(1, ((px - ax) * dx + (py - ay) * dy) / (dx * dx + dy * dy)))
          return Math.hypot(px - (ax + t * dx), py - (ay + t * dy))
        }
        function inside(px, py) {
          // ring
          var nx = (px - ecx) / erx, ny = (py - ecy) / ery
          var d = Math.sqrt(nx * nx + ny * ny)
          var tw = th / (erx + ery)
          if (Math.abs(d - 1) <= tw) return true
          if (d < 1 && px >= ecx - erx && px <= ecx + erx && py >= barY && py <= barY + barH) return true
          // stem
          if (px >= lx && px <= lx + lw && py >= lt && py <= lb) return true
          // v
          if (seg(px, py, vx0, vt, vx1, vb) <= th / 2 + 0.1) return true
          if (seg(px, py, vx2, vt, vx1, vb) <= th / 2 + 0.1) return true
          return false
        }
        function cover(x0, x1, y0, y1) {
          var n = 6, hit = 0
          for (var i = 0; i < n; i++) for (var j = 0; j < n; j++)
            if (inside(x0 + (x1 - x0) * (i + .5) / n, y0 + (y1 - y0) * (j + .5) / n)) hit++
          return hit / (n * n)
        }
        function mix(b, f, a) { return Math.round(255 * (b * (1 - a) + f * a)) }

        var aa = s.antialias, order = s.rgba
        for (var cy = 0; cy < root.rows; cy++) for (var cx = 0; cx < root.cols; cx++) {
          var r, g, b
          if (!aa) {
            var on = cover(cx, cx + 1, cy, cy + 1) >= 0.5 ? 1 : 0
            r = mix(bg.r, fg.r, on); g = mix(bg.g, fg.g, on); b = mix(bg.b, fg.b, on)
          } else if (order === "none") {
            var a = cover(cx, cx + 1, cy, cy + 1)
            r = mix(bg.r, fg.r, a); g = mix(bg.g, fg.g, a); b = mix(bg.b, fg.b, a)
          } else {
            var v = order === "vrgb" || order === "vbgr"
            var rev = order === "bgr" || order === "vbgr"
            var cv = []
            for (var k = 0; k < 3; k++)
              cv.push(v ? cover(cx, cx + 1, cy + k / 3, cy + (k + 1) / 3)
                        : cover(cx + k / 3, cx + (k + 1) / 3, cy, cy + 1))
            if (rev) cv.reverse()
            if (s.lcdfilter !== "lcdnone") {
              var w = s.lcdfilter === "lcdlight" ? 0.15 : 0.28
              cv = [cv[0] * (1 - w) + cv[1] * w, cv[1] * (1 - 2 * w) + (cv[0] + cv[2]) * w, cv[2] * (1 - w) + cv[1] * w]
            }
            r = mix(bg.r, fg.r, cv[0]); g = mix(bg.g, fg.g, cv[1]); b = mix(bg.b, fg.b, cv[2])
          }
          ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")"
          ctx.fillRect(cx * c, cy * c, c, c)
        }
      }
    }
  }
}
