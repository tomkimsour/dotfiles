import QtQuick
import qs

BarLabel {
    id: root

    property var cc

    text: "󰍜"
    color: cc?.visible ? Theme.accent : Theme.foreground
    width: 28
    horizontalAlignment: Text.AlignHCenter

    MouseArea {
        anchors.fill: parent
        onClicked: root.cc?.toggle()
    }
}
