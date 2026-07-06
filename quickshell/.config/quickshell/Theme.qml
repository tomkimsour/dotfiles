pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color background: "#041E21" // midnight
    readonly property color foreground: "#ECEEEE" // peach
    readonly property color accent: "#f97070"     // light-red
    readonly property color warn: "#EED260"       // kings-yellow
    readonly property color muted: "#889397"      // midnight-6

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int barHeight: 26
}
