import QtQuick
import qs

Item {
    id: root

    property string title: ""
    property bool showToggle: false
    property bool checked: false
    signal toggled(bool checked)

    width: parent.width
    height: 20

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Font.DemiBold
        color: Theme.foreground
    }

    Toggle {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        visible: root.showToggle
        checked: root.checked
        onToggled: checked => root.toggled(checked)
    }
}
