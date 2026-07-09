pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int upcomingDays: 14
    readonly property int monthPaddingDays: 7

    property bool ok: true
    property var monthEvents: ({}) // "YYYY-MM-DD" -> [{title, startTime, endTime, allDay}]
    property var upcoming: [] // [{date, startTime, endTime, allDay, title}], sorted ascending

    function pad2(n) {
        return n < 10 ? "0" + n : "" + n;
    }

    function isoDate(d) {
        return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
    }

    function eventsOn(dateStr) {
        return root.monthEvents[dateStr] || [];
    }

    function rowsFromJson(text) {
        const rows = JSON.parse(text);
        return rows.map(row => ({
            title: row.title || "(untitled)",
            date: row.time?.start_date ?? "",
            startTime: row.time?.start_time ?? "",
            endTime: row.time?.end_time ?? "",
            allDay: !row.time?.start_time
        }));
    }

    function fetchMonth(year, month) {
        const start = new Date(year, month, 1 - root.monthPaddingDays);
        const end = new Date(year, month + 1, root.monthPaddingDays);
        monthProc.command = ["gcalcli", "--nocolor", "agenda", "--json", root.isoDate(start), root.isoDate(end)];
        monthProc.running = true;
    }

    function refreshUpcoming() {
        const start = new Date();
        const end = new Date();
        end.setDate(end.getDate() + root.upcomingDays);
        upcomingProc.command = ["gcalcli", "--nocolor", "agenda", "--json", "--nostarted", root.isoDate(start), root.isoDate(end)];
        upcomingProc.running = true;
    }

    Process {
        id: monthProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const byDate = {};
                    for (const e of root.rowsFromJson(text)) {
                        if (!e.date)
                            continue;
                        if (!byDate[e.date])
                            byDate[e.date] = [];
                        byDate[e.date].push(e);
                    }
                    root.monthEvents = byDate;
                    root.ok = true;
                } catch (err) {
                    root.ok = false;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.ok = false;
        }
    }

    Process {
        id: upcomingProc
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.upcoming = root.rowsFromJson(text).sort((a, b) => (a.date + a.startTime).localeCompare(b.date + b.startTime));
                    root.ok = true;
                } catch (err) {
                    root.ok = false;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.ok = false;
        }
    }

    Timer {
        interval: 300000 // 5 min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshUpcoming()
    }
}
