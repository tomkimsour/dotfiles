import QtQuick
import Quickshell.Io
import qs

SliderRow {
    id: root

    readonly property string device: "intel_backlight"
    readonly property int filePercent: {
        const max = parseInt(maxFile.text()) || 1;
        return Math.round(100 * (parseInt(curFile.text()) || 0) / max);
    }

    icon: percent < 34 ? "󰃞" : percent < 67 ? "󰃟" : "󰃠"

    onFilePercentChanged: {
        if (!pressed)
            percent = filePercent;
    }

    onMoved: p => {
        percent = Math.max(1, Math.min(100, p));
        applyTimer.restart();
    }

    FileView {
        id: curFile
        path: "/sys/class/backlight/" + root.device + "/brightness"
    }

    FileView {
        id: maxFile
        path: "/sys/class/backlight/" + root.device + "/max_brightness"
    }

    // pick up changes made elsewhere (fn keys, etc.)
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: curFile.reload()
    }

    // debounce writes while dragging
    Timer {
        id: applyTimer
        interval: 100
        onTriggered: {
            setProc.command = ["brightnessctl", "-e4", "-n2", "set", root.percent + "%"];
            setProc.running = true;
        }
    }

    Process {
        id: setProc
        onExited: curFile.reload()
    }
}
