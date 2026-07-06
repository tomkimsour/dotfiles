import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

Row {
    id: root

    required property var bar
    spacing: 17

    Repeater {
        model: SystemTray.items

        MouseArea {
            id: item

            required property var modelData

            width: 12
            height: Theme.barHeight
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

            IconImage {
                anchors.centerIn: parent
                implicitSize: 12
                source: item.modelData.icon
            }

            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton)
                    item.modelData.activate();
                else if (mouse.button === Qt.MiddleButton)
                    item.modelData.secondaryActivate();
                else if (item.modelData.hasMenu)
                    menuAnchor.open();
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: item.modelData.menu
                anchor.item: item
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }
        }
    }
}
