import QtQuick
import Quickshell
import Quickshell.Wayland
import qs

PanelWindow {
    id: root

    property var modelData
    screen: modelData

    anchors {
        top: true
        right: true
    }
    margins {
        top: 4
        right: 8
    }
    exclusiveZone: 0
    implicitWidth: 340
    implicitHeight: col.implicitHeight
    color: "transparent"
    visible: NotificationService.popups.count > 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:notifications"

    Column {
        id: col
        width: parent.width
        spacing: 0

        Repeater {
            model: NotificationService.popups

            // card inset in a padded box so the radio waves can expand past it
            Item {
                id: toast

                required property var entry

                width: parent.width
                height: card.height + 36

                Repeater {
                    model: 3

                    Rectangle {
                        id: wave

                        required property int index
                        property real progress: 0

                        anchors.centerIn: parent
                        width: card.width + progress * 36
                        height: card.height + progress * 36
                        radius: 4 + progress * 18
                        color: "transparent"
                        border.color: Theme.accent
                        border.width: 2
                        opacity: (1 - progress) * 0.7

                        SequentialAnimation {
                            id: pulse
                            running: true

                            PauseAnimation {
                                id: gap
                                duration: wave.index * 600 + Math.random() * 300
                            }

                            NumberAnimation {
                                id: expand
                                target: wave
                                property: "progress"
                                from: 0
                                to: 1
                                duration: 1200
                                easing.type: Easing.OutQuad
                            }

                            // re-roll the timing each cycle for a noisy pulse rate
                            onFinished: {
                                gap.duration = 200 + Math.random() * 900;
                                expand.duration = 1000 + Math.random() * 500;
                                pulse.restart();
                            }
                        }
                    }
                }

                NotificationCard {
                    id: card
                    anchors.centerIn: parent
                    width: parent.width - 36
                    entry: toast.entry
                    solid: true
                }

                Timer {
                    interval: 6000
                    running: true
                    onTriggered: fadeOut.start()
                }

                NumberAnimation {
                    id: fadeOut
                    target: toast
                    property: "opacity"
                    to: 0
                    duration: 500
                    onFinished: NotificationService.expirePopup(toast.entry)
                }
            }
        }
    }
}
