import QtQuick
import Quickshell
import Quickshell.Io
import qs

Row {
    id: root

    property int cpu: 0
    property int memPercent: 0
    property string memUsed: "0"
    property string memTotal: "0"
    property int temp: 0

    spacing: 15

    // one long-running poller for cpu / mem / temp (5s cycle, like waybar)
    Process {
        running: true
        command: ["sh", "-c", `
prev_total=0; prev_idle=0
while :; do
    read -r _ u n s i w irq sirq st _ < /proc/stat
    total=$((u + n + s + i + w + irq + sirq + st)); idle=$((i + w))
    dt=$((total - prev_total)); di=$((idle - prev_idle))
    if [ "$dt" -gt 0 ]; then cpu=$((100 * (dt - di) / dt)); else cpu=0; fi
    prev_total=$total; prev_idle=$idle
    mem=$(LC_ALL=C awk '/^MemTotal/{t=$2} /^MemAvailable/{a=$2} END{u=t-a; printf "%d %.1f %.1f", u*100/t, u/1048576, t/1048576}' /proc/meminfo)
    temp=$(cat /sys/class/thermal/thermal_zone7/temp 2>/dev/null || echo 0)
    echo "$cpu $mem $((temp / 1000))"
    sleep 5
done`]
        stdout: SplitParser {
            onRead: data => {
                const p = data.trim().split(/\s+/);
                if (p.length < 5)
                    return;
                root.cpu = parseInt(p[0]);
                root.memPercent = parseInt(p[1]);
                root.memUsed = p[2];
                root.memTotal = p[3];
                root.temp = parseInt(p[4]);
            }
        }
    }

    BarLabel {
        text: "󰘚 " + root.cpu + "%"
    }

    BarLabel {
        text: "󰍛 " + root.memPercent + "%"
    }

    BarLabel {
        text: (root.temp >= 85 ? "󰸁 " : "󰔏 ") + root.temp + "°C"
        color: root.temp >= 85 ? Theme.accent : Theme.foreground
    }
}
