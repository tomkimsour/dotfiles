pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Claude Code rate-limit windows, same data as the /usage command.
    // Each window: { pct (used %), resetsAt (ms epoch, 0 if unknown) }
    property bool ok: false
    property var fiveHour: null
    property var weekly: null
    property var scoped: null // top-model weekly cap, adds { model }
    property double fetchedAt: 0

    readonly property bool hasData: fiveHour !== null || weekly !== null || scoped !== null

    function remain(win) {
        return win ? Math.max(0, Math.min(100, 100 - win.pct)) : 0;
    }

    // traffic-light on remaining %: red ≤ 20, yellow < 50, green otherwise
    function heat(remainPct) {
        return remainPct <= 20 ? "#f97070" : remainPct < 50 ? "#ffb74d" : "#81c784";

    }

    function fmtDur(secs) {
        if (secs <= 0)
            return "now";
        const h = Math.floor(secs / 3600);
        const m = Math.floor((secs % 3600) / 60);
        if (h >= 24)
            return Math.floor(h / 24) + "d " + (h % 24) + "h";
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    function refresh() {
        fetcher.running = true;
    }

    Process {
        id: fetcher
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/claude-usage.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const win = o => (o && o.utilization != null) ? {
                        pct: o.utilization,
                        resetsAt: o.resets_at ? Date.parse(o.resets_at) : 0
                    } : null;
                    root.fiveHour = win(d.five_hour);
                    root.weekly = win(d.seven_day);
                    let scoped = null;
                    for (const l of (d.limits || [])) {
                        const model = l.scope?.model?.display_name;
                        if (l.group === "weekly" && model) {
                            scoped = {
                                pct: l.percent ?? 0,
                                resetsAt: l.resets_at ? Date.parse(l.resets_at) : 0,
                                model: model
                            };
                            break;
                        }
                    }
                    root.scoped = scoped;
                    root.fetchedAt = Date.now();
                    root.ok = true;
                } catch (err) {
                    root.ok = false;
                    retryTimer.restart();
                }
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
        interval: 120000 // 2 min, same cadence as the SwiftBar plugin
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: retryTimer
        interval: 60000
        onTriggered: root.refresh()
    }
}
