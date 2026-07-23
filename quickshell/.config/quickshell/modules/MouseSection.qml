import QtQuick
import Quickshell.Io
import qs

// Hyprland mouse sensitivity: float in [-1.0, 1.0], 0 = no modification.
// Mapped onto the slider's 0..100% range (50% = 0.0).
SliderRow {
    id: root

    readonly property real sensitivity: (percent - 50) / 50

    icon: "󰍽"

    onMoved: p => {
        percent = Math.max(0, Math.min(100, p));
        applyTimer.restart();
    }

    // read the current value on startup
    Process {
        id: getProc
        running: true
        command: ["hyprctl", "getoption", "input:sensitivity", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.pressed)
                    return;
                try {
                    const val = JSON.parse(text).float ?? 0;
                    root.percent = Math.round(val * 50 + 50);
                } catch (e) {}
            }
        }
    }

    // debounce writes while dragging
    Timer {
        id: applyTimer
        interval: 100
        onTriggered: {
            setProc.command = ["hyprctl", "keyword", "input:sensitivity", root.sensitivity.toFixed(2)];
            setProc.running = true;
        }
    }

    Process {
        id: setProc
    }
}
