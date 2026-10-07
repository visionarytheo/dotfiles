import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland

RowLayout {
    spacing: 8

    Text {
        text: "󰣇"
        color: "#fabd2f"
        font.pixelSize: 16
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: launcherState.toggle()
        }
    }

    Rectangle { width: 1; height: 14; color: "#3c3836" }

    Row {
        spacing: 5
        Layout.alignment: Qt.AlignVCenter

        Repeater {
            model: [1, 2, 3, 4, 5]

            Rectangle {
                required property var modelData
                width: modelData === barWindow.activeWorkspaceId ? 14 : 6
                height: 6
                radius: 3
                color: modelData === barWindow.activeWorkspaceId ? "#fabd2f" : "#504945"

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + parent.modelData)
                }
            }
        }
    }

    Rectangle { width: 1; height: 14; color: "#3c3836" }

    Text {
        text: barWindow.currentTime
        color: "#fabd2f"
        font.pixelSize: 12
        font.bold: true
    }
}
