import QtQuick
import qs

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property string status: ""
    property bool highlight: false
    signal clicked()

    width: parent.width
    height: 24
    radius: 4
    color: mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

    Text {
        id: iconText
        anchors {
            left: parent.left
            leftMargin: 6
            verticalCenter: parent.verticalCenter
        }
        width: 20
        text: root.icon
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.highlight ? Theme.accent : Theme.foreground
    }

    Text {
        anchors {
            left: iconText.right
            right: statusText.left
            rightMargin: 6
            verticalCenter: parent.verticalCenter
        }
        text: root.label
        elide: Text.ElideRight
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.highlight ? Theme.accent : Theme.foreground
    }

    Text {
        id: statusText
        anchors {
            right: parent.right
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        text: root.status
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        color: Theme.muted
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
