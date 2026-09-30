import QtQuick
import Quickshell
import Quickshell.Io
import qs

// Night light warmth slider driving ~/.config/hypr/scripts/nightlight.sh (0% = off, 100% = 2000K).
SliderRow {
    id: root

    readonly property int neutralTemp: 6500
    readonly property int warmestTemp: 2000
    readonly property int defaultTemp: 2700
    readonly property string script: Quickshell.env("HOME") + "/.config/hypr/scripts/nightlight.sh"
    readonly property int filePercent: toPercent(parseInt(stateFile.text()) || defaultTemp)
    property int lastOnPercent: toPercent(defaultTemp)

    function toPercent(temp) {
        return Math.round(100 * (neutralTemp - temp) / (neutralTemp - warmestTemp));
    }

    function toTemp(p) {
        return Math.round(neutralTemp - p * (neutralTemp - warmestTemp) / 100);
    }

    icon: "󰖔"
    active: percent > 0
    percent: filePercent

    onFilePercentChanged: {
        if (!pressed)
            percent = filePercent;
    }

    onPercentChanged: {
        if (percent > 0)
            lastOnPercent = percent;
    }

    onMoved: p => {
        percent = Math.max(0, Math.min(100, p));
        applyTimer.restart();
    }

    onIconClicked: {
        percent = percent > 0 ? 0 : lastOnPercent;
        applyTimer.restart();
    }

    FileView {
        id: stateFile
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/nightlight"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    Timer {
        id: applyTimer
        interval: 300
        onTriggered: Quickshell.execDetached([root.script, "set", String(root.toTemp(root.percent))])
    }
}
