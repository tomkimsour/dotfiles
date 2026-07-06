import QtQuick
import Quickshell

BarLabel {
    text: "󱗼"
    font.pixelSize: 14

    MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(["rofi", "-show", "drun", "-theme", Quickshell.env("HOME") + "/.config/rofi/launchers/type-2/style-2.rasi"])
    }
}
