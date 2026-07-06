import QtQuick
import qs

Rectangle {
    id: root

    property var entry
    property bool solid: false // opaque card w/ border, for popup toasts

    radius: 4
    color: solid ? Theme.background : Qt.rgba(1, 1, 1, 0.05)
    border.color: solid ? Theme.muted : "transparent"
    border.width: solid ? 1 : 0
    implicitHeight: col.implicitHeight + 14

    Column {
        id: col
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 7
        }
        spacing: 2

        Item {
            width: parent.width
            height: 14

            Text {
                anchors.left: parent.left
                text: root.entry.n.appName || "notification"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                color: Theme.muted
                elide: Text.ElideRight
                width: parent.width - 40
            }

            Text {
                anchors.right: parent.right
                text: Qt.formatTime(new Date(root.entry.at), "HH:mm")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                color: Theme.muted
            }
        }

        Text {
            width: parent.width
            text: root.entry.n.summary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
            color: Theme.foreground
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            visible: text !== ""
            text: root.entry.n.body
            textFormat: Text.StyledText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            color: Theme.muted
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.entry.n.dismiss()
    }
}
