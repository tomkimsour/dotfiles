import QtQuick
import Quickshell
import "modules"

PanelWindow {
    id: root

    property var modelData
    property var cc
    property var centerPanel
    property var claudePanel
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.background

    Row { // left
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 12

        Launcher {}
        Workspaces {}
    }

    // underlay: clicking the middle of the bar (incl. the clock) opens the
    // center panel; weather/bell sit on top and keep their own click actions
    MouseArea {
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width / 3
        height: parent.height
        onClicked: root.centerPanel?.toggle()
    }

    Row { // center
        anchors.centerIn: parent
        spacing: 16

        Clock {}
        Weather {}
        Notifications { centerPanel: root.centerPanel }
    }

    Row { // right
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 15

        SysTray { bar: root }
        SysStats {}
        ClaudeUsage { panel: root.claudePanel }
        Battery {}
        BluetoothIcon { cc: root.cc }
        Network { cc: root.cc }
        Volume { cc: root.cc }
        VpnIcon { cc: root.cc }
        MenuIcon { cc: root.cc }
    }
}
