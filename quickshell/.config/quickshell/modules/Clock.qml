import Quickshell

BarLabel {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "MMM dd HH:mm")
}
