import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

// Dropdown with the detailed Claude usage breakdown: one gauge per limit
// window with remaining %, used % and reset countdown.
PanelWindow {
    id: root

    property var modelData
    screen: modelData
    visible: false

    property double nowMs: 0

    anchors {
        top: true
        right: true
    }
    margins {
        top: 4
        right: 8
    }
    implicitWidth: 380
    implicitHeight: frame.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:claudeusage"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function toggle() {
        visible = !visible;
        if (visible) {
            nowMs = Date.now();
            ClaudeUsageService.refresh();
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.visible = false
    }

    // bindable from hyprland: qs ipc call claudeusage toggle
    IpcHandler {
        target: "claudeusage"

        function toggle(): void {
            root.toggle();
        }
    }

    Timer {
        interval: 30000
        running: root.visible
        repeat: true
        onTriggered: root.nowMs = Date.now()
    }

    component LimitRow: Column {
        id: row

        property string label
        property var win

        readonly property real remainPct: ClaudeUsageService.remain(win)

        visible: win !== null
        width: parent.width
        spacing: 4

        Item {
            width: parent.width
            height: 18

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: row.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                color: Theme.foreground
            }

            Text {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
                text: Math.round(row.remainPct) + "% left"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.weight: Font.DemiBold
                color: ClaudeUsageService.heat(row.remainPct)
            }
        }

        Rectangle { // gauge track
            width: parent.width
            height: 8
            radius: 4
            color: Qt.rgba(1, 1, 1, 0.08)

            Rectangle {
                width: Math.round(parent.width * row.remainPct / 100)
                height: parent.height
                radius: 4
                color: ClaudeUsageService.heat(row.remainPct)
            }
        }

        Text {
            text: {
                if (!row.win)
                    return "";
                let s = "used " + Math.round(row.win.pct) + "%";
                if (row.win.resetsAt > 0)
                    s += "  ·  resets " + (row.win.resetsAt <= root.nowMs
                        ? "now"
                        : "in " + ClaudeUsageService.fmtDur((row.win.resetsAt - root.nowMs) / 1000));
                return s;
            }
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
            color: Theme.muted
        }
    }

    Rectangle {
        id: frame
        anchors.fill: parent
        implicitHeight: content.implicitHeight + 24
        color: Theme.background
        border.color: Theme.muted
        border.width: 1

        // close on escape
        focus: true
        Keys.onEscapePressed: root.visible = false

        Column {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 10

            Item {
                width: parent.width
                height: 20

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Claude Code usage"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                    color: Theme.foreground
                }

                Text {
                    anchors {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    text: "󰑐"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    color: refreshMouse.containsMouse ? Theme.accent : Theme.muted

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.nowMs = Date.now();
                            ClaudeUsageService.refresh();
                        }
                    }
                }
            }

            LimitRow {
                label: "5h session"
                win: ClaudeUsageService.fiveHour
            }

            LimitRow {
                label: "Weekly · all models"
                win: ClaudeUsageService.weekly
            }

            LimitRow {
                label: "Weekly · " + (ClaudeUsageService.scoped?.model ?? "")
                win: ClaudeUsageService.scoped
            }

            Text {
                visible: !ClaudeUsageService.hasData
                width: parent.width
                text: "No usage data yet — run Claude Code once so it can sign you in"
                wrapMode: Text.Wrap
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                color: Theme.warn
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            Text {
                text: {
                    const age = (root.nowMs - ClaudeUsageService.fetchedAt) / 1000;
                    let s = ClaudeUsageService.fetchedAt <= 0 ? "not fetched yet"
                        : age < 60 ? "updated just now"
                        : "updated " + ClaudeUsageService.fmtDur(age) + " ago";
                    if (!ClaudeUsageService.ok)
                        s += "  ·  last check failed";
                    return s;
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 3
                color: ClaudeUsageService.ok ? Theme.muted : Theme.warn
            }
        }
    }
}
