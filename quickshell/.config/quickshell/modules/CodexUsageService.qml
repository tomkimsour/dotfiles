pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Codex CLI rate-limit windows, same data as the /status command.
    // Each window: { pct (used %), resetsAt (ms epoch, 0 if unknown) }
    property bool ok: false
    property var fiveHour: null
    property var weekly: null
    property var scoped: null // model-specific cap, adds { model }
    property double fetchedAt: 0

    readonly property bool hasData: fiveHour !== null || weekly !== null || scoped !== null

    function remain(win) {
        return ClaudeUsageService.remain(win);
    }

    function heat(remainPct) {
        return ClaudeUsageService.heat(remainPct);
    }

    function fmtDur(secs) {
        return ClaudeUsageService.fmtDur(secs);
    }

    function refresh() {
        fetcher.running = true;
    }

    Process {
        id: fetcher
        command: [Quickshell.env("HOME") + "/.config/quickshell/scripts/codex-usage.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const win = o => (o && o.used_percent != null) ? {
                        pct: o.used_percent,
                        resetsAt: o.reset_at ? o.reset_at * 1000 : 0
                    } : null;
                    root.fiveHour = win(d.rate_limit?.primary_window);
                    root.weekly = win(d.rate_limit?.secondary_window);
                    let scoped = null;
                    for (const l of (d.additional_rate_limits || [])) {
                        const w = win(l.rate_limit?.primary_window);
                        if (w) {
                            w.model = l.normal_model_slug || l.limit_name || "model";
                            scoped = w;
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
        interval: 120000
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
