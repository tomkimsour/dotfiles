import Quickshell.Services.UPower
import qs

BarLabel {
    readonly property var device: UPower.displayDevice
    readonly property real percent: (device?.percentage ?? 0) * 100
    readonly property bool charging: device !== null
        && (device.state === UPowerDeviceState.Charging || device.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: device !== null && device.state === UPowerDeviceState.FullyCharged

    readonly property var dischargeIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var chargeIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    visible: device?.isLaptopBattery ?? false
    text: (full ? "󰂅" : (charging ? chargeIcons : dischargeIcons)[Math.min(9, Math.floor(percent / 10))])
        + " " + Math.round(percent) + "%"
    color: !charging && percent <= 10 ? Theme.accent
        : !charging && percent <= 20 ? Theme.warn
        : Theme.foreground
}
