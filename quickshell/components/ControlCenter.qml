import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ScrollView {
    id: controlScroll
    Layout.fillWidth: true
    Layout.fillHeight: true
    clip: true
    contentWidth: availableWidth

    ColumnLayout {
        width: controlScroll.availableWidth
        spacing: 8

        // Row 1: Wi-Fi & Bluetooth Cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 12
                color: "#161616"
                border.color: wifiMouse.containsMouse ? "#fabd2f" : "#3c3836"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: (barWindow.netConnected ?? false) ? "#fabd2f" : "#3c3836"

                        Text {
                            anchors.centerIn: parent
                            text: (barWindow.netType ?? "") === "wifi" ? "󰤨" : "󰈀"
                            color: (barWindow.netConnected ?? false) ? "#1d2021" : "#ebdbb2"
                            font.pixelSize: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Wi-Fi"
                            color: "#a89984"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            text: barWindow.netName ?? "Disconnected"
                            color: "#ebdbb2"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    id: wifiMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: netGuiProcess.running = true
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                radius: 12
                color: "#161616"
                border.color: btMouse.containsMouse ? "#fabd2f" : "#3c3836"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: "#3c3836"

                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            color: "#ebdbb2"
                            font.pixelSize: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Bluetooth"
                            color: "#a89984"
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Text {
                            text: "Connected"
                            color: "#ebdbb2"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                MouseArea {
                    id: btMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: btGuiProcess.running = true
                }
            }
        }

        // Row 2: Display Brightness Slider Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            radius: 12
            color: "#161616"
            border.color: "#3c3836"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰃞"
                    color: "#fabd2f"
                    font.pixelSize: 18
                }

                Slider {
                    id: brightnessSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0

                    Binding on value {
                        value: barWindow.brightnessVal ?? 0.0
                        when: !brightnessSlider.pressed
                    }

                    onMoved: {
                        barWindow.brightnessVal = value;
                        brightnessProcess.command = ["ddcutil", "setvcp", "10", Math.round(value * 100)];
                        brightnessProcess.running = true;
                    }

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: brightnessSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: "#282828"

                        Rectangle {
                            width: brightnessSlider.visualPosition * parent.width
                            height: parent.height
                            color: "#fabd2f"
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                        y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        color: brightnessSlider.pressed ? "#fe8019" : "#ebdbb2"
                        border.color: "#3c3836"
                    }
                }

                Text {
                    text: Math.round((barWindow.brightnessVal ?? 0.0) * 100) + "%"
                    color: "#a89984"
                    font.pixelSize: 11
                    Layout.preferredWidth: 32
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // Row 3: Sound Slider Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            radius: 12
            color: "#161616"
            border.color: "#3c3836"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: ((barWindow.isMuted ?? false) || (barWindow.volumeVal ?? 0.0) === 0) ? "󰝟" : ((barWindow.volumeVal ?? 0.0) < 0.5 ? "󰖀" : "󰕾")
                    color: (barWindow.isMuted ?? false) ? "#fb4934" : "#fabd2f"
                    font.pixelSize: 18

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                pavuProcess.running = true;
                            } else {
                                volumeProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
                                volumeProcess.running = true;
                                barWindow.isMuted = !(barWindow.isMuted ?? false);
                            }
                        }
                    }
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    from: 0.0
                    to: 1.0

                    Binding on value {
                        value: barWindow.volumeVal ?? 0.0
                        when: !volumeSlider.pressed
                    }

                    onMoved: {
                        barWindow.volumeVal = value;
                        volumeProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", value.toFixed(2)];
                        volumeProcess.running = true;
                    }

                    background: Rectangle {
                        x: volumeSlider.leftPadding
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: volumeSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: "#282828"

                        Rectangle {
                            width: volumeSlider.visualPosition * parent.width
                            height: parent.height
                            color: (barWindow.isMuted ?? false) ? "#928374" : "#fabd2f"
                            radius: 3
                        }
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 14
                        implicitHeight: 14
                        radius: 7
                        color: volumeSlider.pressed ? "#fe8019" : "#ebdbb2"
                        border.color: "#3c3836"
                    }
                }

                Text {
                    text: Math.round((barWindow.volumeVal ?? 0.0) * 100) + "%"
                    color: "#a89984"
                    font.pixelSize: 11
                    Layout.preferredWidth: 32
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        // Row 3.5: Embedded Media Player Card
        Rectangle {
            id: mediaCard
            Layout.fillWidth: true
            Layout.preferredHeight: (barWindow.hasActiveMedia ?? false) ? 66 : 0
            visible: barWindow.hasActiveMedia ?? false
            radius: 12
            color: "#161616"
            border.color: "#3c3836"
            border.width: 1
            clip: true

            function formatTime(secs) {
                if (isNaN(secs) || secs <= 0) return "0:00";
                var m = Math.floor(secs / 60);
                var s = Math.floor(secs % 60);
                return m + ":" + (s < 10 ? "0" : "") + s;
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 16
                        color: "#fabd2f"

                        Text {
                            anchors.centerIn: parent
                            text: "󰝚"
                            color: "#1d2021"
                            font.pixelSize: 14
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: barWindow.activePlayer ? (barWindow.activePlayer.trackTitle || "Unknown Track") : "No Track"
                            color: "#ebdbb2"
                            font.pixelSize: 11
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: barWindow.activePlayer ? (barWindow.activePlayer.trackArtist || "Unknown Artist") : ""
                            color: "#a89984"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    RowLayout {
                        spacing: 8

                        Text {
                            text: "󰒮"
                            color: "#ebdbb2"
                            font.pixelSize: 16

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (barWindow.activePlayer) {
                                        barWindow.activePlayer.previous();
                                    }
                                }
                            }
                        }

                        Text {
                            text: barWindow.activePlayer && barWindow.activePlayer.isPlaying ? "󰏤" : "󰐊"
                            color: "#fabd2f"
                            font.pixelSize: 18

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (barWindow.activePlayer) {
                                        barWindow.activePlayer.togglePlaying();
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
                                onClicked: {
                                    if (barWindow.activePlayer) {
                                        barWindow.activePlayer.next();
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: barWindow.activePlayer ? mediaCard.formatTime(barWindow.activePlayer.position) : "0:00"
                        color: "#a89984"
                        font.pixelSize: 9
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        radius: 2
                        color: "#282828"

                        property real trackLen: barWindow.activePlayer && barWindow.activePlayer.length > 0 ? barWindow.activePlayer.length : 1
                        property real trackPos: barWindow.activePlayer ? barWindow.activePlayer.position : 0

                        Rectangle {
                            width: parent.trackLen > 0 ? Math.min(parent.width, (parent.trackPos / parent.trackLen) * parent.width) : 0
                            height: parent.height
                            color: "#fabd2f"
                            radius: 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                if (barWindow.activePlayer && barWindow.activePlayer.length > 0) {
                                    var ratio = mouse.x / width;
                                    barWindow.activePlayer.position = ratio * barWindow.activePlayer.length;
                                }
                            }
                        }
                    }

                    Text {
                        text: barWindow.activePlayer ? mediaCard.formatTime(barWindow.activePlayer.length) : "0:00"
                        color: "#a89984"
                        font.pixelSize: 9
                    }
                }
            }
        }

        // Row 4: Calendar Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 185
            radius: 12
            color: "#161616"
            border.color: "#3c3836"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: Qt.formatDate(new Date(), "MMMM yyyy")
                        color: "#fabd2f"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true
                    locale: Qt.locale()
                    delegate: Text {
                        text: model.narrowSymbol
                        color: "#a89984"
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MonthGrid {
                    id: calendarGrid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    locale: Qt.locale()
                    month: new Date().getMonth()
                    year: new Date().getFullYear()

                    delegate: Text {
                        property var cellDate: model.date ?? new Date()

                        text: cellDate ? cellDate.getDate().toString() : ""
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 10

                        property bool isCurrentMonth: cellDate.getMonth() === calendarGrid.month
                        property bool isToday: {
                            var today = new Date();
                            return cellDate.getDate() === today.getDate() && 
                                   cellDate.getMonth() === today.getMonth() && 
                                   cellDate.getFullYear() === today.getFullYear();
                        }

                        color: {
                            if (!isCurrentMonth) return "#504945";
                            if (isToday) return "#1d2021";
                            return "#ebdbb2";
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            radius: 10
                            z: -1
                            color: "#fabd2f"
                            visible: parent.isCurrentMonth && parent.isToday
                        }
                    }
                }
            }
        }

        // Row 5: Notifications / Info Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            radius: 12
            color: "#161616"
            border.color: "#3c3836"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Text {
                    text: "󰂚"
                    color: "#fabd2f"
                    font.pixelSize: 18
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Notifications"
                        color: "#ebdbb2"
                        font.pixelSize: 11
                        font.bold: true
                    }

                    Text {
                        text: (barWindow.currentDate ?? "") + " • All systems nominal"
                        color: "#928374"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
