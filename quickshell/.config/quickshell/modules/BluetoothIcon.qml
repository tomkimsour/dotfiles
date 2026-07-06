import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs

BarLabel {
    id: root

    property var cc

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property int connections: Bluetooth.devices.values.filter(d => d.connected).length
    readonly property bool on: adapter?.enabled ?? false

    visible: adapter !== null
    text: on ? ("󰂱" + (connections > 0 ? " " + connections : "")) : "󰂲"
    color: connections > 0 ? Theme.foreground : (on ? Theme.foreground : Theme.muted)

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.cc?.show("bluetooth");
            else
                Quickshell.execDetached(["gnome-control-center", "bluetooth"]);
        }
    }
}
