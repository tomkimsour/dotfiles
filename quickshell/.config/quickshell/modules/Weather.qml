import QtQuick
import Quickshell
import Quickshell.Io
import qs

BarLabel {
    id: root

    readonly property string location: Quickshell.env("WTTR_LOCATION") || "Barcelona"
    property string condition: ""
    property string temp: ""
    property bool ok: false

    function iconFor(cond) {
        const c = cond.toLowerCase();
        if (c.includes("thunder"))
            return "󰖓";
        if (/snow|sleet|blizzard|ice/.test(c))
            return "󰖘";
        if (c.includes("partly"))
            return "🌤️";
        if (/heavy.*rain|torrential|downpour/.test(c))
            return "󰖖";
        if (/rain|drizzle|shower/.test(c))
            return "󰖗";
        if (/fog|mist|haze/.test(c))
            return "󰖑";
        if (/overcast|cloud/.test(c))
            return "☁️";
        if (/sunny|clear/.test(c))
            return "☀️";
        return "󰖐";
    }

    visible: ok
    text: ok ? iconFor(condition) + " " + temp : ""

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
