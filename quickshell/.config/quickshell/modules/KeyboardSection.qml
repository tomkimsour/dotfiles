import QtQuick
import qs

Column {
    spacing: 2

    CCHeader {
        title: "Keyboard Layout"
    }

    Repeater {
        model: KeyboardLayoutState.layouts

        CCItem {
            required property var modelData
            required property int index

            icon: "󰌌"
            label: modelData.label
            highlight: index === KeyboardLayoutState.activeIndex
            onClicked: KeyboardLayoutState.select(index)
        }
    }
}
