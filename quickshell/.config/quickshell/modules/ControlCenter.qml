import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

PanelWindow {
    id: root

    property var modelData
    screen: modelData
    visible: false

    anchors {
        top: true
        right: true
    }
    margins {
        top: 4
        right: 8
    }
    implicitWidth: 330
    implicitHeight: frame.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:controlcenter"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    // "all" shows every section; anything else shows just that one section
    property string filter: "all"

    function toggle() {
        show("all");
    }

    function show(section) {
        if (root.visible && root.filter === section) {
            root.visible = false;
            return;
        }
        root.filter = section;
        root.visible = true;
        wifiSection.refresh();
        wifiSection.rescan();
        VpnState.refresh();
    }

    // close when clicking anywhere outside the panel
    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.visible = false
    }

    // allows binding a hyprland key: qs ipc call controlcenter toggle
    IpcHandler {
        target: "controlcenter"

        function toggle(): void {
            root.toggle();
        }
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        implicitHeight: content.implicitHeight + 24
        color: Theme.background
        border.color: Theme.muted
        border.width: 1

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 8

            BrightnessSection { width: parent.width; visible: root.filter === "all" }

            CCHeader { title: "Sound"; visible: root.filter === "audio" }

            AudioSection { width: parent.width; visible: root.filter === "all" || root.filter === "audio" }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: root.filter === "all"
            }

            BluetoothSection { width: parent.width; visible: root.filter === "all" || root.filter === "bluetooth" }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: root.filter === "all"
            }

            WifiSection {
                id: wifiSection
                width: parent.width
                visible: root.filter === "all" || root.filter === "wifi"
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: root.filter === "all"
            }

            VpnSection { width: parent.width; visible: root.filter === "all" || root.filter === "vpn" }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: root.filter === "all"
            }

            PowerSection { width: parent.width; visible: root.filter === "all" }
        }
    }
}
