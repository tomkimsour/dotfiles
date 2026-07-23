pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // order must match the kb_layout list in hyprland.conf
    readonly property var layouts: [
        { code: "us", label: "English (US)" },
        { code: "fr", label: "French" },
        { code: "es", label: "Spanish" }
    ]
    property int activeIndex: 0
    readonly property string activeCode: (layouts[activeIndex]?.code ?? "us").toUpperCase()

    function refresh() {
        devicesProc.running = true;
    }

    function select(index) {
        if (index === root.activeIndex)
            return;
        switchProc.command = ["hyprctl", "switchxkblayout", "current", String(index)];
        switchProc.running = true;
    }

    function next() {
        switchProc.command = ["hyprctl", "switchxkblayout", "current", "next"];
        switchProc.running = true;
    }

    Process {
        id: devicesProc
        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = JSON.parse(text);
                const kb = data.keyboards.find(k => k.main) ?? data.keyboards[0];
                if (kb)
                    root.activeIndex = kb.active_layout_index;
            }
        }
    }

    Process {
        id: switchProc
        onExited: root.refresh()
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout")
                root.refresh();
        }
    }

    Component.onCompleted: refresh()
}
