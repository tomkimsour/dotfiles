import QtQuick
import qs

Item {
    id: root

    property string icon: ""
    property int percent: 0
    property bool active: true // false dims the fill (e.g. muted)
    readonly property bool pressed: sliderMouse.pressed
    signal moved(int percent)
    signal iconClicked()

    width: parent.width
    height: 24

    Text {
        id: iconText
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: 20
        text: root.icon
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: root.active ? Theme.foreground : Theme.muted

        MouseArea {
            anchors.fill: parent
            onClicked: root.iconClicked()
        }
    }

    Text {
        id: pctText
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        width: 36
        horizontalAlignment: Text.AlignRight
        text: root.percent + "%"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        color: Theme.muted
    }

    Item {
        id: slider
        anchors {
            left: iconText.right
            leftMargin: 6
            right: pctText.left
            rightMargin: 8
            verticalCenter: parent.verticalCenter
        }
        height: parent.height

        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.15)
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: track.width * Math.min(100, Math.max(0, root.percent)) / 100
            height: 4
            radius: 2
            color: root.active ? Theme.accent : Theme.muted
        }

        Rectangle {
            x: track.width * Math.min(100, Math.max(0, root.percent)) / 100 - width / 2
            anchors.verticalCenter: parent.verticalCenter
            width: 10
            height: 10
            radius: 5
            color: Theme.foreground
        }

        MouseArea {
            id: sliderMouse
            anchors.fill: parent
            onPressed: mouse => root.moved(Math.round(100 * mouse.x / width))
            onPositionChanged: mouse => {
                if (pressed)
                    root.moved(Math.round(100 * mouse.x / width));
            }
            onWheel: wheel => root.moved(root.percent + (wheel.angleDelta.y > 0 ? 5 : -5))
        }
    }
}
