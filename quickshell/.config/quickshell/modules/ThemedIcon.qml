import QtQuick
import qs

// Icons/ assets are flat-colored (mostly a dark #2E3436 outline meant for a
// light background), which is nearly invisible on this theme's dark bar.
// Recolor to a theme color instead of trusting the source asset's palette.
// (Qt5Compat.GraphicalEffects / QtQuick.Effects aren't bundled with this
// Quickshell build, so this hand-rolls the same alpha-tint via ShaderEffect,
// which is core QtQuick.)
Item {
    id: root

    property alias source: img.source
    property color color: Theme.foreground

    Image {
        id: img
        anchors.fill: parent
        visible: false
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(width, height)
    }

    ShaderEffect {
        anchors.fill: img
        property var source: img
        property color tintColor: root.color
        fragmentShader: Qt.resolvedUrl("shaders/tint.frag.qsb")
    }
}
