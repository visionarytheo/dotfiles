import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick.Layouts

ShellRoot {
    PanelWindow {
        implicitHeight: 30
        color: "transparent"

        anchors {
            bottom: true
            left: true
            right: true
        }

        margins {
            bottom: 0
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: workspaceRow.width + 30
            radius: parent.height / 2
            color: "transparent"

            Row {
                id: workspaceRow
                anchors.centerIn: parent
                spacing: 15

                Repeater {
                    model: 5

                    Text {
                        // Check if the workspace exists in Hyprland's active list
                        property var ws: Hyprland.workspaces[index + 1]
                        property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)

                        text: isActive ? "●" : "•"
                        color: isActive ? "#ffffff" : (ws ? "#24e395" : "#444444")
                        
                        font {
                            pixelSize: isActive ? 8 : 8
                            bold: true
                        }
                        font.family: "SF Pro Display"
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + (index + 1))
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        implicitHeight: 30
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        margins {
            top: 5
        }

        SystemClock {
            id: clock
            precision: SystemClock.Seconds
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: contentLayout.width + (mouseArea.containsMouse ? 110 : 30)
            radius: parent.height / 2
            color: "#161616"

            Behavior on width {
                NumberAnimation {
                    duration: 200
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
            }

            Row {
                id: contentLayout
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: Qt.formatDateTime(clock.date, "hh:mm")
                    color: "#fff"
                    font.family: "SF Pro Display"
                }
            }
        }
    }
}
