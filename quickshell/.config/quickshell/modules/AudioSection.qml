import QtQuick
import Quickshell.Services.Pipewire
import qs

Column {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    spacing: 8

    PwObjectTracker {
        objects: [root.sink, root.source].filter(Boolean)
    }

    SliderRow {
        readonly property bool muted: root.sink?.audio?.muted ?? false

        icon: muted ? "󰝟" : (percent < 34 ? "󰕿" : percent < 67 ? "󰖀" : "󰕾")
        active: !muted
        percent: Math.round((root.sink?.audio?.volume ?? 0) * 100)
        onMoved: p => {
            if (root.sink?.audio)
                root.sink.audio.volume = Math.max(0, Math.min(100, p)) / 100;
        }
        onIconClicked: {
            if (root.sink?.audio)
                root.sink.audio.muted = !muted;
        }
    }

    SliderRow {
        readonly property bool muted: root.source?.audio?.muted ?? false

        icon: muted ? "󰍭" : "󰍬"
        active: !muted
        percent: Math.round((root.source?.audio?.volume ?? 0) * 100)
        onMoved: p => {
            if (root.source?.audio)
                root.source.audio.volume = Math.max(0, Math.min(100, p)) / 100;
        }
        onIconClicked: {
            if (root.source?.audio)
                root.source.audio.muted = !muted;
        }
    }
}
