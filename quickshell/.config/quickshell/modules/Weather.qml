import QtQuick
import Quickshell
import Quickshell.Io
import qs

Item {
    id: root

    property var panel

    readonly property string location: Quickshell.env("WTTR_LOCATION") || "Barcelona"
    property string condition: ""
    property string temp: ""
    property bool ok: false

    // night-vs-day icon variants are picked off the wall clock since wttr.in's
    // format string doesn't expose sunrise/sunset
    readonly property bool night: {
        const h = new Date().getHours();
        return h >= 20 || h < 7;
    }

    function iconFor(cond) {
        const c = cond.toLowerCase();
        if (c.includes("thunder"))
            return Qt.resolvedUrl("../Icons/storm.svg");
        if (/snow|sleet|blizzard|ice/.test(c))
            return Qt.resolvedUrl("../Icons/snow.svg");
        if (c.includes("partly"))
            return night ? Qt.resolvedUrl("../Icons/few-clouds-night.svg") : Qt.resolvedUrl("../Icons/few-clouds.svg");
        if (/heavy.*rain|torrential|downpour/.test(c))
            return Qt.resolvedUrl("../Icons/showers.png");
        if (/rain|drizzle|shower/.test(c))
            return Qt.resolvedUrl("../Icons/showers-scattered.svg");
        if (/fog|mist|haze/.test(c))
            return Qt.resolvedUrl("../Icons/fog.svg");
        if (/overcast|cloud/.test(c))
            return Qt.resolvedUrl("../Icons/overcast.svg");
        if (/sunny|clear/.test(c))
            return night ? Qt.resolvedUrl("../Icons/clear-night.svg") : Qt.resolvedUrl("../Icons/clear.svg");
        return Qt.resolvedUrl("../Icons/overcast.svg");
    }

    visible: ok
    width: content.width
    height: Theme.barHeight

    Row {
        id: content
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        ThemedIcon {
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.fontSize + 3
            height: Theme.fontSize + 3
            source: root.ok ? root.iconFor(root.condition) : ""
        }

        BarLabel {
            text: root.temp
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.panel?.toggle()
    }

    Process {
        id: fetcher
        command: ["curl", "-fsS", "--max-time", "10",
            "https://wttr.in/" + root.location + "?format=%C|%t"]
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = text.trim();
                if (raw === "" || /unknown|sorry|html/i.test(raw) || !raw.includes("|")) {
                    root.ok = false;
                    retryTimer.restart();
                    return;
                }
                root.condition = raw.split("|")[0].trim();
                root.temp = raw.split("|")[1].replace(/[ +]/g, "");
                root.ok = true;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.ok = false;
                retryTimer.restart();
            }
        }
    }

    Timer {
        interval: 900000 // 15 min, like waybar
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetcher.running = true
    }

    Timer {
        id: retryTimer
        interval: 120000
        onTriggered: fetcher.running = true
    }

}
