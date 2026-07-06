import QtQuick
import qs

Rectangle {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    width: 32
    height: 16
    radius: 8
    color: checked ? Theme.accent : Qt.rgba(1, 1, 1, 0.15)

    Rectangle {
        width: 12
        height: 12
        radius: 6
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: Theme.foreground

        Behavior on x {
            NumberAnimation { duration: 100 }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.toggled(!root.checked)
    }
}
