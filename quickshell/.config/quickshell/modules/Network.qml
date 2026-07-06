import QtQuick
import Quickshell
import Quickshell.Io
import qs

BarLabel {
    id: root

    property var cc
    property string kind: "none" // wifi | ethernet | none
    property int strength: 0

    readonly property var wifiIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    text: kind === "ethernet" ? "󰀂"
        : kind === "wifi" ? wifiIcons[Math.min(4, Math.floor(strength / 20))]
        : "󰤮"

    Process {
        id: poller
        command: ["sh", "-c", `
t=$(nmcli -t -f TYPE,STATE dev status 2>/dev/null | awk -F: '$2 == "connected" && $1 != "loopback" { print $1; exit }')
if [ "$t" = wifi ]; then
    s=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == "*" { print $2; exit }')
    [ -n "$s" ] || s=0
    echo "wifi $s"
elif [ -n "$t" ]; then
    echo "ethernet 0"
else
    echo "none 0"
fi`]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(" ");
                root.kind = p[0];
                root.strength = parseInt(p[1]) || 0;
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: poller.running = true
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.cc?.show("wifi");
            else
                Quickshell.execDetached(["nm-connection-editor"]);
        }
    }
}
