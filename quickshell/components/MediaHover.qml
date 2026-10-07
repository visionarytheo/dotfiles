import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris

RowLayout {
    spacing: 14

    Rectangle {
        Layout.preferredWidth: 64
        Layout.preferredHeight: 64
        radius: 12
        color: "#161616"
        clip: true

        Image {
            anchors.fill: parent
            source: barWindow.activePlayer ? (barWindow.activePlayer.artUrl ?? "") : ""
            fillMode: Image.PreserveAspectCrop
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            text: "󰎈"
            color: "#fabd2f"
            font.pixelSize: 22
            visible: parent.children[0].status !== Image.Ready
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 3

        Text {
            text: barWindow.activePlayer ? (barWindow.activePlayer.trackTitle || "Unknown Track") : ""
            color: "#ebdbb2"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            text: barWindow.activePlayer ? (barWindow.activePlayer.trackArtist || "Unknown Artist") : ""
            color: "#fabd2f"
            font.pixelSize: 11
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 20
            Layout.topMargin: 4

            Text {
                text: "󰒮"
                color: "#ebdbb2"
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (barWindow.activePlayer) barWindow.activePlayer.previous()
                }
            }

            Text {
                text: (barWindow.activePlayer && barWindow.activePlayer.isPlaying) ? "󰐎" : "󰐊"
                color: "#fabd2f"
                font.pixelSize: 18
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (barWindow.activePlayer) {
                            if (barWindow.activePlayer.isPlaying) {
                                barWindow.activePlayer.pause();
                            } else {
                                barWindow.activePlayer.play();
                            }
                        }
                    }
                }
            }

            Text {
                text: "󰒭"
                color: "#ebdbb2"
                font.pixelSize: 16
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (barWindow.activePlayer) barWindow.activePlayer.next()
                }
            }
        }
    }
}
