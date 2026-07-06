import QtQuick
import Quickshell
import Quickshell.Io
import qs

Column {
    id: root

    property bool radioEnabled: true
    property var networks: [] // [{ssid, signal, secured, inUse, known}]
    property string expandedSsid: ""
    property string busySsid: ""

    readonly property var signalIcons: ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

    spacing: 2

    function unesc(s) {
        return s.replace(/\\(.)/g, "$1");
    }

    function refresh() {
        listProc.running = true;
    }

    function rescan() {
        if (!scanProc.running)
            scanProc.running = true;
    }

    function activate(net, password) {
        expandedSsid = "";
        busySsid = net.ssid;
        if (net.inUse)
            actionProc.command = ["nmcli", "connection", "down", "id", net.ssid];
        else if (net.known)
            actionProc.command = ["nmcli", "connection", "up", "id", net.ssid];
        else if (password)
            actionProc.command = ["nmcli", "device", "wifi", "connect", net.ssid, "password", password];
        else
            actionProc.command = ["nmcli", "device", "wifi", "connect", net.ssid];
        actionProc.running = true;
    }

    function parse(text) {
        const known = [];
        const nets = new Map();
        let radio = false;
        for (const line of text.split("\n")) {
            if (line.startsWith("RADIO "))
                radio = line.slice(6).trim() === "enabled";
            else if (line.startsWith("KNOWN "))
                known.push(unesc(line.slice(6)));
            else if (line.startsWith("NET ")) {
                const f = line.slice(4).split(":");
                if (f.length < 4)
                    continue;
                const ssid = unesc(f.slice(3).join(":"));
                if (!ssid)
                    continue;
                const net = {
                    ssid,
                    inUse: f[0] === "*",
                    signal: parseInt(f[1]) || 0,
                    secured: f[2] !== "" && f[2] !== "--"
                };
                const prev = nets.get(ssid);
                if (!prev) {
                    nets.set(ssid, net);
                } else {
                    prev.inUse = prev.inUse || net.inUse;
                    prev.signal = Math.max(prev.signal, net.signal);
                }
            }
        }
        const arr = [...nets.values()];
        for (const n of arr)
            n.known = known.includes(n.ssid);
        arr.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal));
        radioEnabled = radio;
        networks = arr.slice(0, 8);
    }

    Process {
        id: listProc
        command: ["sh", "-c", `
echo "RADIO $(nmcli radio wifi 2>/dev/null)"
nmcli -t -f TYPE,NAME connection show 2>/dev/null | sed -n 's/^802-11-wireless:/KNOWN /p'
nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list 2>/dev/null | sed 's/^/NET /'
`]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli device wifi list --rescan yes >/dev/null 2>&1"]
        onExited: root.refresh()
    }

    Process {
        id: actionProc
        onExited: (exitCode, exitStatus) => {
            root.busySsid = "";
            root.refresh();
            if (exitCode !== 0)
                Quickshell.execDetached(["notify-send", "-u", "critical", "Wi-Fi", "Operation failed"]);
        }
    }

    CCHeader {
        title: "Wi-Fi"
        showToggle: true
        checked: root.radioEnabled
        onToggled: checked => {
            actionProc.command = ["nmcli", "radio", "wifi", checked ? "on" : "off"];
            actionProc.running = true;
        }
    }

    Repeater {
        model: root.radioEnabled ? root.networks : []

        Column {
            id: netEntry

            required property var modelData

            width: parent.width
            spacing: 2

            CCItem {
                icon: root.signalIcons[Math.min(4, Math.floor(netEntry.modelData.signal / 20))]
                label: netEntry.modelData.ssid
                highlight: netEntry.modelData.inUse
                status: root.busySsid === netEntry.modelData.ssid ? "…"
                    : netEntry.modelData.inUse ? "connected"
                    : netEntry.modelData.known ? "saved"
                    : netEntry.modelData.secured ? "󰌾" : ""
                onClicked: {
                    const net = netEntry.modelData;
                    if (net.inUse || net.known || !net.secured) {
                        root.activate(net);
                    } else if (root.expandedSsid === net.ssid) {
                        root.expandedSsid = "";
                    } else {
                        root.expandedSsid = net.ssid;
                        pwInput.text = "";
                        pwInput.forceActiveFocus();
                    }
                }
            }

            Rectangle {
                visible: root.expandedSsid === netEntry.modelData.ssid
                width: parent.width
                height: 24
                radius: 4
                color: Qt.rgba(1, 1, 1, 0.08)
                border.color: Theme.muted
                border.width: 1

                TextInput {
                    id: pwInput
                    anchors.fill: parent
                    anchors.margins: 5
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: Theme.foreground
                    echoMode: TextInput.Password
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    onAccepted: root.activate(netEntry.modelData, text)

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: pwInput.text === ""
                        text: "password, then ⏎"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        color: Theme.muted
                    }
                }
            }
        }
    }

    Text {
        visible: !root.radioEnabled
        text: "Wi-Fi is off"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        color: Theme.muted
    }
}
