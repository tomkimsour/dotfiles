import QtQuick
import qs

Item {
    id: root

    property var cc

    width: 56
    height: Theme.barHeight

    Rectangle {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: parent.width - 8
        height: 3
        radius: 1.5
        color: cc?.visible ? Theme.accent : Theme.foreground
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.cc?.toggle()
    }
}
