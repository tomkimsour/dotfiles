import QtQuick
import QtQuick.Controls.Basic as Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs

PanelWindow {
    id: root

    property var modelData
    screen: modelData
    visible: false

    // only the top edge anchored -> horizontally centered on the screen
    anchors.top: true
    margins.top: 4
    exclusiveZone: 0
    implicitWidth: 580
    implicitHeight: frame.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:centerpanel"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    property int month: 0
    property int year: 2000

    function toggle() {
        visible = !visible;
        if (visible) {
            const now = new Date();
            month = now.getMonth();
            year = now.getFullYear();
            GoogleCalendarService.fetchMonth(year, month);
            GoogleCalendarService.refreshUpcoming();
        }
    }

    function shiftMonth(delta) {
        const d = new Date(year, month + delta, 1);
        month = d.getMonth();
        year = d.getFullYear();
        GoogleCalendarService.fetchMonth(year, month);
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.visible = false
    }

    // bindable from hyprland: qs ipc call centerpanel toggle
    IpcHandler {
        target: "centerpanel"

        function toggle(): void {
            root.toggle();
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

        Row {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 12

            Column {
                id: calCol
                width: 260
                spacing: 8

                Item {
                    width: parent.width
                    height: 22

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Qt.locale().monthName(root.month) + " " + root.year
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Row {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 4

                        Repeater {
                            model: [{ label: "󰅁", delta: -1 }, { label: "󰅂", delta: 1 }]

                            Rectangle {
                                required property var modelData

                                width: 22
                                height: 22
                                radius: 4
                                color: navMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.modelData.label
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    color: Theme.foreground
                                }

                                MouseArea {
                                    id: navMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: root.shiftMonth(parent.modelData.delta)
                                }
                            }
                        }
                    }
                }

                Controls.DayOfWeekRow {
                    width: parent.width
                    locale: Qt.locale()

                    delegate: Text {
                        required property var model

                        text: model.shortName
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.muted
                    }
                }

                Controls.MonthGrid {
                    id: grid
                    width: parent.width
                    month: root.month
                    year: root.year
                    locale: Qt.locale()
                    spacing: 2

                    delegate: Item {
                        required property var model

                        readonly property var dayEvents: GoogleCalendarService.eventsOn(GoogleCalendarService.isoDate(model.date))

                        width: Math.floor((grid.availableWidth - grid.spacing * 6) / 7)
                        height: 24

                        Rectangle {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            visible: parent.model.today
                            color: Theme.accent
                        }

                        Text {
                            anchors.centerIn: parent
                            text: parent.model.day
                            horizontalAlignment: Text.AlignHCenter
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            color: parent.model.today ? Theme.background : Theme.foreground
                            opacity: parent.model.month === grid.month ? 1 : 0.3
                        }

                        Rectangle {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                                bottomMargin: 1
                            }
                            visible: parent.dayEvents.length > 0
                            width: 4
                            height: 4
                            radius: 2
                            color: parent.model.today ? Theme.background : Theme.warn
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                Column {
                    id: agendaCol
                    width: parent.width
                    spacing: 4

                    Text {
                        text: "Upcoming"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Font.DemiBold
                        color: Theme.muted
                    }

                    Repeater {
                        model: GoogleCalendarService.upcoming.slice(0, 5)

                        delegate: Row {
                            required property var modelData

                            width: agendaCol.width
                            spacing: 6

                            Text {
                                width: 44
                                text: modelData.allDay ? "all-day" : modelData.startTime
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                color: Theme.muted
                            }

                            Text {
                                width: agendaCol.width - 50
                                text: modelData.title
                                elide: Text.ElideRight
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                color: Theme.foreground
                            }
                        }
                    }

                    Text {
                        visible: GoogleCalendarService.ok && GoogleCalendarService.upcoming.length === 0
                        text: "No upcoming events"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        color: Theme.muted
                    }

                    Text {
                        visible: !GoogleCalendarService.ok
                        width: agendaCol.width
                        text: "Google Calendar not connected — run gcalcli init"
                        wrapMode: Text.Wrap
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        color: Theme.warn
                    }
                }
            }

            Rectangle {
                width: 1
                height: calCol.implicitHeight
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            Item {
                id: notifCol
                width: content.width - calCol.width - 1 - content.spacing * 2
                height: calCol.implicitHeight

                Item {
                    id: notifHeader
                    width: parent.width
                    height: 22

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Notifications"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.DemiBold
                        color: Theme.foreground
                    }

                    Row {
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 10

                        // clear all
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: NotificationService.count > 0
                            text: "󰎟"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: clearMouse.containsMouse ? Theme.accent : Theme.muted

                            MouseArea {
                                id: clearMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: NotificationService.clearAll()
                            }
                        }

                        // do not disturb
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: NotificationService.dnd ? "󰂛" : "󰂚"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: NotificationService.dnd ? Theme.accent : Theme.muted

                            MouseArea {
                                anchors.fill: parent
                                onClicked: NotificationService.dnd = !NotificationService.dnd
                            }
                        }
                    }
                }

                ListView {
                    anchors {
                        top: notifHeader.bottom
                        topMargin: 6
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    clip: true
                    spacing: 6
                    model: NotificationService.entries

                    delegate: NotificationCard {
                        required property var modelData

                        width: ListView.view.width
                        entry: modelData
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: NotificationService.count === 0
                    text: "No notifications"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    color: Theme.muted
                }
            }
        }
    }
}
