import QtQuick
import Quickshell.Wayland
import qs

BarLabel {
    readonly property string title: ToplevelManager.activeToplevel?.title ?? ""

    text: title.length > 48 ? title.substring(0, 47) + "…" : title
    color: Theme.muted
}
