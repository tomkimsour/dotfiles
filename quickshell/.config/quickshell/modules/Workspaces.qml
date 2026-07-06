import QtQuick
import Quickshell.Hyprland
import qs

Row {
    spacing: 3

    Repeater {
        model: 10

        BarLabel {
            id: ws

            required property int index
            readonly property int wsId: index + 1
            readonly property var workspace: Hyprland.workspaces.values.find(w => w.id === ws.wsId) ?? null
            readonly property bool isActive: (Hyprland.focusedWorkspace?.id ?? -1) === wsId

            // workspaces 1-4 are persistent, others only shown while they exist
            visible: workspace !== null || wsId <= 4
            width: 15
            horizontalAlignment: Text.AlignHCenter
            text: isActive ? "󱓻" : (wsId === 10 ? "0" : String(wsId))
            color: isActive ? Theme.accent : Theme.foreground
            opacity: workspace !== null ? 1 : 0.5

            MouseArea {
                anchors.fill: parent
                onClicked: Hyprland.dispatch("workspace " + ws.wsId)
            }
        }
    }
}
