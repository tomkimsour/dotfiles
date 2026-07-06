import QtQuick
import qs

BarLabel {
    id: root

    property var cc

    text: VpnState.connected ? "󰦝" : "󰦞"
    color: VpnState.connected ? Theme.accent : Theme.muted

    MouseArea {
        anchors.fill: parent
        onClicked: root.cc?.show("vpn")
    }
}
