import QtQuick
import qs

Column {
    spacing: 2

    CCHeader {
        title: "VPN"
    }

    Repeater {
        model: VpnState.vpns

        CCItem {
            required property var modelData

            icon: modelData.active ? "󰦝" : "󰦞"
            label: modelData.name
            highlight: modelData.active
            status: VpnState.busy === modelData.name ? "…" : modelData.active ? "connected" : ""
            onClicked: VpnState.toggle(modelData.name)
        }
    }

    Text {
        visible: VpnState.vpns.length === 0
        text: "No VPN profiles"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        color: Theme.muted
    }
}
