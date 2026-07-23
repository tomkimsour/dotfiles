//@ pragma UseQApplication
import Quickshell
import "modules"

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: scope

            property var modelData

            Bar {
                modelData: scope.modelData
                cc: controlCenter
                centerPanel: centerPanel
                claudePanel: claudeUsagePanel
                weatherPanel: weatherPanel
            }

            ControlCenter {
                id: controlCenter
                modelData: scope.modelData
            }

            CenterPanel {
                id: centerPanel
                modelData: scope.modelData
            }

            ClaudeUsagePanel {
                id: claudeUsagePanel
                modelData: scope.modelData
            }

            WeatherPanel {
                id: weatherPanel
                modelData: scope.modelData
            }

            NotificationPopups {
                modelData: scope.modelData
            }
        }
    }
}
