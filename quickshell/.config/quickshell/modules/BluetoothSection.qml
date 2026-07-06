import QtQuick
import Quickshell.Bluetooth
import qs

Column {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    // paired/trusted devices always; unpaired ones only while scanning
    readonly property var deviceList: [...Bluetooth.devices.values]
        .filter(d => d.deviceName && (d.paired || d.trusted || d.connected || (adapter?.discovering ?? false)))
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.deviceName.localeCompare(b.deviceName))
        .slice(0, 8)

    spacing: 2

    CCHeader {
        title: "Bluetooth"
        showToggle: true
        checked: root.enabled
        onToggled: checked => {
            if (root.adapter)
                root.adapter.enabled = checked;
        }
    }

    Repeater {
        model: root.enabled ? root.deviceList : []

        CCItem {
            required property var modelData

            icon: modelData.connected ? "󰂱" : "󰂯"
            label: modelData.deviceName
            highlight: modelData.connected
            status: modelData.connected
                ? (modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : "connected")
                : (modelData.paired ? "" : "new")
            onClicked: {
                if (!modelData.paired) {
                    modelData.trusted = true;
                    modelData.pair();
                } else {
                    modelData.connected = !modelData.connected;
                }
            }
        }
    }

    CCItem {
        visible: root.enabled
        icon: ""
        label: (root.adapter?.discovering ?? false) ? "Scanning…  (click to stop)" : "Scan for devices"
        status: ""
        onClicked: {
            if (root.adapter)
                root.adapter.discovering = !root.adapter.discovering;
        }
    }

    Text {
        visible: !root.enabled
        text: "Bluetooth is off"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        color: Theme.muted
    }
}
