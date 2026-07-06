import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

BarLabel {
    id: root

    property var cc

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property int volume: Math.round((sink?.audio?.volume ?? 0) * 100)

    text: muted ? "󰝟 muted"
        : (volume < 34 ? "󰕿" : volume < 67 ? "󰖀" : "󰕾") + " " + volume + "%"
    color: muted ? Theme.muted : Theme.foreground

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                root.cc?.show("audio");
            else if (root.sink?.audio)
                root.sink.audio.muted = !root.muted;
        }
        onWheel: wheel => {
            if (!root.sink?.audio)
                return;
            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.sink.audio.volume + step));
        }
    }
}
