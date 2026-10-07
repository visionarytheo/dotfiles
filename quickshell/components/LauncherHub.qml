import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel
import Quickshell

ColumnLayout {
    spacing: 8

    // Tab Switcher Header
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: [
                { name: "Applications", icon: "󰍉" },
                { name: "Wallpapers", icon: "󰸉" },
                { name: "Themes", icon: "󰔎" }
            ]

            Rectangle {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                radius: 6
                color: launcherState.activeTab === index ? "#3c3836" : "#161616"
                border.color: launcherState.activeTab === index ? "#fabd2f" : "#3c3836"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6
                    Text { text: parent.parent.modelData.icon; color: "#fabd2f"; font.pixelSize: 13 }
                    Text { text: parent.parent.modelData.name; color: "#ebdbb2"; font.pixelSize: 11; font.bold: true }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherState.activeTab = parent.index
                }
            }
        }
    }

    // Tab 0: Applications
    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: launcherState.activeTab === 0
        spacing: 6

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            radius: 8
            color: "#161616"
            border.color: searchInput.activeFocus ? "#fabd2f" : "#3c3836"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text { text: "󰍉"; color: "#fabd2f"; font.pixelSize: 15 }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: "#ebdbb2"
                    font.pixelSize: 13
                    clip: true

                    Connections {
                        target: launcherState
                        function onIsOpenChanged() {
                            if (launcherState.isOpen && launcherState.activeTab === 0) {
                                searchInput.forceActiveFocus();
                            } else {
                                searchInput.text = "";
                            }
                        }
                    }

                    Text {
                        text: "Search applications..."
                        color: "#928374"
                        font.pixelSize: 13
                        visible: !parent.text && !parent.activeFocus
                    }

                    onTextChanged: appList.currentIndex = 0

                    Keys.onEscapePressed: launcherState.close()
                    Keys.onDownPressed: appList.incrementCurrentIndex()
                    Keys.onUpPressed: appList.decrementCurrentIndex()
                    Keys.onReturnPressed: {
                        var filtered = appList.model;
                        if (filtered && filtered.length > appList.currentIndex) {
                            var app = filtered[appList.currentIndex];
                            if (app) {
                                app.execute();
                                launcherState.close();
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2

            model: DesktopEntries.applications.values.filter(app => {
                if (!searchInput.text) return true;
                var query = searchInput.text.toLowerCase();
                return (app.name && app.name.toLowerCase().includes(query)) || 
                       (app.comment && app.comment.toLowerCase().includes(query));
            })

            delegate: Rectangle {
                id: appItem
                required property var modelData
                width: appList.width
                height: 34
                radius: 6
                color: ListView.isCurrentItem ? "#3c3836" : (itemMouse.containsMouse ? "#282828" : "transparent")

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        appItem.modelData.execute();
                        launcherState.close();
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 10

                    Text { text: "󰵆"; color: "#fabd2f"; font.pixelSize: 16 }

                    Text {
                        text: appItem.modelData.name || ""
                        color: "#ebdbb2"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    // Tab 1: Wallpapers (Multi-item Horizontal Carousel Row)
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: launcherState.activeTab === 1

        FolderListModel {
            id: wallpaperModel
            folder: "file://" + Quickshell.env("HOME") + "/.config/hypr/current_theme/wallpapers"
            nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
            showFiles: true
            showDirs: false
        }

        ListView {
            id: wallpaperCarousel
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            snapMode: ListView.SnapOneItem
            boundsBehavior: Flickable.StopAtBounds
            model: wallpaperModel

            delegate: Rectangle {
                required property string fileName
                required property string filePath
                
                width: 210
                height: wallpaperCarousel.height
                radius: 12
                color: "#161616"
                border.color: wallMouse.containsMouse ? "#fabd2f" : "#3c3836"
                border.width: wallMouse.containsMouse ? 2 : 1
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: filePath
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: wallMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wallpaperProcess.command = ["awww", "img", filePath, "--transition-type", "outer", "--transition-fps", "60", "--transition-step", "90"];
                        wallpaperProcess.running = true;
                        launcherState.close();
                    }
                }
            }
        }
    }

    // Tab 2: Themes (Compact Minimalist Horizontal Carousel Row)
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: launcherState.activeTab === 2

        FolderListModel {
            id: themesModel
            folder: "file://" + Quickshell.env("HOME") + "/.config/hypr/themes"
            showDirs: true
            showFiles: false
            sortField: FolderListModel.Name
        }

        ListView {
            id: themesCarousel
            anchors.fill: parent
            orientation: ListView.Horizontal
            spacing: 12
            clip: true
            snapMode: ListView.SnapOneItem
            boundsBehavior: Flickable.StopAtBounds
            model: themesModel

            delegate: Rectangle {
                required property string fileName
                required property string filePath
                
                width: 210
                height: 120
                y: (themesCarousel.height - height) / 2
                radius: 12
                color: "#161616"
                border.color: themeMouse.containsMouse ? "#fabd2f" : "#3c3836"
                border.width: themeMouse.containsMouse ? 2 : 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 65
                        radius: 8
                        color: "#282828"
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: filePath + "/preview.png"
                            fillMode: Image.PreserveAspectCrop
                            visible: status === Image.Ready
                        }

                        Row {
                            anchors.centerIn: parent
                            spacing: 5
                            visible: parent.children[0].status !== Image.Ready

                            Repeater {
                                model: ["#fabd2f", "#fb4934", "#b8bb26", "#83a598", "#d3869b"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: modelData
                                    border.color: "#1d2021"
                                    border.width: 1
                                }
                            }
                        }
                    }

                    Text {
                        text: fileName
                        color: "#ebdbb2"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    id: themeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        themeProcess.command = [
                            Quickshell.env("HOME") + "/.config/hypr/scripts/switch-theme.sh",
                            fileName
                        ];
                        themeProcess.running = true;
                        launcherState.close();
                    }
                }
            }
        }
    }
}
