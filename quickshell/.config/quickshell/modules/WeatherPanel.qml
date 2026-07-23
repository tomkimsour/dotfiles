import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts
import qs

// Dropdown with a fuller weather picture than the bar icon: feels-like temp,
// today's min/max, rain so far and sunset time, from Open-Meteo.
PanelWindow {
    id: root

    property var modelData
    screen: modelData
    visible: false

    property real jacketTemperature: 15
    readonly property string lat: Quickshell.env("WEATHER_LAT") || "41.39"
    readonly property string lon: Quickshell.env("WEATHER_LON") || "2.16"

    property int weathercode: 0
    property string temperature: "--"
    property real minTemperature: 0
    property real maxTemperature: 0
    property real rain: 0
    property real uvIndex: 0
    property string sunsetTime: ""

    readonly property string weatherCmd: "curl -fsS 'https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunset,uv_index_max,precipitation_probability_max,precipitation_sum&current=apparent_temperature&timezone=auto&forecast_days=1' | jq '.daily.uv_index_max[0], .daily.weather_code[0], .daily.temperature_2m_min[0], .daily.temperature_2m_max[0], .daily.sunset[0], .daily.precipitation_sum[0], .current.apparent_temperature'"

    readonly property var weatherIcons: [
        Qt.resolvedUrl("../Icons/clear.svg"),
        Qt.resolvedUrl("../Icons/clear-night.svg"),
        Qt.resolvedUrl("../Icons/few-clouds.svg"),
        Qt.resolvedUrl("../Icons/few-clouds-night.svg"),
        Qt.resolvedUrl("../Icons/overcast.svg"),
        Qt.resolvedUrl("../Icons/fog.svg"),
        Qt.resolvedUrl("../Icons/showers-scattered.svg"),
        Qt.resolvedUrl("../Icons/showers.png"),
        Qt.resolvedUrl("../Icons/snow.svg"),
        Qt.resolvedUrl("../Icons/storm.svg")
    ]

    function iconFor(code, sunset) {
        const hour = new Date().getHours();
        const sunsetHour = sunset ? parseInt(sunset.slice(0, 2), 10) : 20;
        const night = hour >= sunsetHour || hour <= 5;
        switch (code) {
        case 0:
            return night ? weatherIcons[1] : weatherIcons[0];
        case 1:
        case 2:
            return night ? weatherIcons[3] : weatherIcons[2];
        case 3:
            return weatherIcons[4];
        case 45:
        case 48:
            return weatherIcons[5];
        case 51:
        case 53:
        case 55:
        case 80:
        case 81:
            return weatherIcons[6];
        case 61:
        case 63:
        case 65:
        case 56:
        case 57:
        case 66:
        case 67:
        case 82:
            return weatherIcons[7];
        case 71:
        case 73:
        case 75:
        case 77:
        case 85:
        case 86:
            return weatherIcons[8];
        default:
            return weatherIcons[9];
        }
    }

    // only the top edge anchored -> horizontally centered on the screen
    anchors.top: true
    margins.top: 4
    exclusiveZone: 0
    implicitWidth: 420
    implicitHeight: frame.implicitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell:weatherpanel"
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    function toggle() {
        visible = !visible;
        if (visible)
            getWeather.running = true;
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.visible
        onCleared: root.visible = false
    }

    // bindable from hyprland: qs ipc call weatherpanel toggle
    IpcHandler {
        target: "weatherpanel"

        function toggle(): void {
            root.toggle();
        }
    }

    Process {
        id: getWeather
        command: ["sh", "-c", root.weatherCmd]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                if (lines.length < 7)
                    return;
                root.uvIndex = parseFloat(lines[0]);
                root.weathercode = parseInt(lines[1], 10);
                root.minTemperature = parseFloat(lines[2]);
                root.maxTemperature = parseFloat(lines[3]);
                root.sunsetTime = lines[4].slice(1, -1).split('T')[1];
                root.rain = parseFloat(lines[5]);
                root.temperature = lines[6];
            }
        }
    }

    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        onTriggered: getWeather.running = true
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

        RowLayout {
            id: content
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 12
            }
            spacing: 16

            ThemedIcon {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                source: root.iconFor(root.weathercode, root.sunsetTime)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: "It currently feels like " + root.temperature + "°C."
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: "It will be " + root.minTemperature + "°C to " + root.maxTemperature + "°C today. "
                        + (root.minTemperature > root.jacketTemperature ? "You won't need a jumper." : "You'll need a jumper.")
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: (root.rain > 0 ? "We've had " + root.rain + "mm rain so far." : "It won't rain today.")
                        + (root.rain > 2 ? " Bring an umbrella." : "")
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    wrapMode: Text.Wrap
                }

                Text {
                    Layout.fillWidth: true
                    text: "The sun will set at " + root.sunsetTime + "."
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
