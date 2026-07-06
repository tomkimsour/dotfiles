import QtQuick
import qs

BarLabel {
    id: root

    property var centerPanel

    text: NotificationService.dnd ? "󰂛" : (NotificationService.count > 0 ? "󰂚" : "󰂜")
    color: NotificationService.dnd ? Theme.accent : Theme.foreground

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.centerPanel?.toggle();
            else
                NotificationService.dnd = !NotificationService.dnd;
        }
    }
}
