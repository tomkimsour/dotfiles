import QtQuick
import Quickshell
import qs

Item {
    width: parent.width
    height: 26

    Row {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Repeater {
            model: [
                { icon: "󰌾", command: ["hyprlock"] },
                { icon: "󰜉", command: ["systemctl", "reboot"] },
                { icon: "󰐥", command: ["systemctl", "poweroff"] }
            ]

            Rectangle {
                required property var modelData

                width: 30
                height: 26
                radius: 4
                color: buttonMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData.icon
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: buttonMouse.containsMouse ? Theme.accent : Theme.foreground
                }

                MouseArea {
                    id: buttonMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Quickshell.execDetached(parent.modelData.command)
                }
            }
        }
    }
}
