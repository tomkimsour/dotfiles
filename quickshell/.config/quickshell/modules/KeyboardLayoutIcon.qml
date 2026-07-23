import QtQuick
import qs

BarLabel {
    id: root

    property var cc

    text: KeyboardLayoutState.activeCode

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                KeyboardLayoutState.next();
            else
                root.cc?.show("keyboard");
        }
    }
}
