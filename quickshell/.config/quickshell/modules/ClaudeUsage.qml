import QtQuick
import qs

// Claude usage batteries: 5h session / weekly / top-model weekly, each capsule
// filled with the remaining % (number inside stays legible on any fill).
Item {
    id: root

    property var panel

    visible: ClaudeUsageService.hasData
    width: content.width
    height: Theme.barHeight

    component Capsule: Item {
        id: cap

        property real remain: 0

        readonly property int bodyW: width - 2 // capsule body, nub sits right of it
        readonly property int fillW: Math.round((bodyW - 4) * Math.max(0, Math.min(100, remain)) / 100)
        readonly property int boundary: 2 + fillW

        width: 27
        height: 14

        Rectangle { // shell
            width: cap.bodyW
            height: parent.height
            radius: 3
            color: "transparent"
            border.color: Theme.foreground
            border.width: 1
        }

        Rectangle { // terminal nub
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 6
            radius: 1
            color: Theme.foreground
        }

        Rectangle { // charge fill
            x: 2
            y: 2
            width: cap.fillW
            height: parent.height - 4
            radius: 1.5
            color: ClaudeUsageService.heat(cap.remain)
        }

        // remaining % — dark over the bright fill, light over the empty part
        Item {
            width: cap.boundary
            height: parent.height
            clip: true

            Text {
                width: cap.bodyW
                height: cap.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Math.round(cap.remain)
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                color: Theme.background
            }
        }

        Item {
            x: cap.boundary
            width: cap.bodyW - cap.boundary
            height: parent.height
            clip: true

            Text {
                x: -cap.boundary
                width: cap.bodyW
                height: cap.height
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Math.round(cap.remain)
                font.family: Theme.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                color: Theme.foreground
            }
        }
    }

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        opacity: ClaudeUsageService.ok ? 1 : 0.55 // dimmed = last fetch failed, data is stale

        BarLabel {
            text: "C"
        }

        Capsule {
            anchors.verticalCenter: parent.verticalCenter
            visible: ClaudeUsageService.fiveHour !== null
            remain: ClaudeUsageService.remain(ClaudeUsageService.fiveHour)
        }

        Capsule {
            anchors.verticalCenter: parent.verticalCenter
            visible: ClaudeUsageService.weekly !== null
            remain: ClaudeUsageService.remain(ClaudeUsageService.weekly)
        }

        Capsule {
            anchors.verticalCenter: parent.verticalCenter
            visible: ClaudeUsageService.scoped !== null
            remain: ClaudeUsageService.remain(ClaudeUsageService.scoped)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.panel?.toggle()
    }
}
