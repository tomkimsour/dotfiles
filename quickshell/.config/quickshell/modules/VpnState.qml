pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var vpns: [] // [{name, active}]
    property string busy: ""
    readonly property bool connected: vpns.some(v => v.active)
    readonly property string activeName: vpns.find(v => v.active)?.name ?? ""

    function refresh() {
        listProc.running = true;
    }

    function toggle(name) {
        const vpn = vpns.find(v => v.name === name);
        if (!vpn || busy !== "")
            return;
        busy = name;
        actionProc.command = ["nmcli", "connection", vpn.active ? "down" : "up", "id", name];
        actionProc.running = true;
    }

    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE,ACTIVE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = [];
                for (const line of text.split("\n")) {
                    const parts = line.split(":");
                    if (parts.length < 3)
                        continue;
                    const active = parts.pop() === "yes";
                    const type = parts.pop();
                    if (type !== "vpn" && type !== "wireguard")
                        continue;
                    found.push({ name: parts.join(":").replace(/\\(.)/g, "$1"), active });
                }
                root.vpns = found;
            }
        }
    }

    Process {
        id: actionProc
        onExited: (exitCode, exitStatus) => {
            root.busy = "";
            root.refresh();
            if (exitCode !== 0)
                Quickshell.execDetached(["notify-send", "-u", "critical", "VPN", "Operation failed"]);
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
