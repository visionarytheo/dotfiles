import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import QtQuick.Window
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Io
import "./components"

Scope {
    id: rootScope

    Process {
        id: pavuProcess
        command: ["pavucontrol"]
    }

    Process {
        id: netGuiProcess
        command: ["nm-connection-editor"]
    }

    Process {
        id: btGuiProcess
        command: ["blueman-manager"]
    }

    Process {
        id: wallpaperProcess
    }

    Process {
        id: themeProcess
    }

    Process {
        id: brightnessProcess
    }

    Process {
        id: volumeProcess
    }

    Process {
        id: brightnessCheckProcess
        command: ["sh", "-c", "/usr/bin/brightnessctl -m | awk -F',' '{print \\$4}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var pct = parseInt(data.trim());
                if (!isNaN(pct)) {
                    barWindow.brightnessVal = pct / 100.0;
                }
            }
        }
    }

    Process {
        id: volumeCheckProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line.includes("Volume:")) {
                    var parts = line.split(" ");
                    var vol = parseFloat(parts[1]);
                    if (!isNaN(vol)) {
                        barWindow.volumeVal = vol;
                    }
                    barWindow.isMuted = line.includes("[MUTED]");
                }
            }
        }
    }

    Process {
        id: netCheckProcess
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION dev 2>/dev/null | grep -E '^(ethernet|wifi):connected' | head -n1 || echo 'none:disconnected:Disconnected'"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line.length > 0) {
                    var parts = line.split(":");
                    if (parts[1] && parts[1].includes("connected")) {
                        barWindow.netType = parts[0] || "";
                        barWindow.netName = parts[2] || "Connected";
                        barWindow.netConnected = true;
                    } else {
                        barWindow.netConnected = false;
                        barWindow.netName = "Disconnected";
                        barWindow.netType = "";
                    }
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            netCheckProcess.running = false;
            netCheckProcess.running = true;
            brightnessCheckProcess.running = false;
            brightnessCheckProcess.running = true;
            volumeCheckProcess.running = false;
            volumeCheckProcess.running = true;
        }
    }

    QtObject {
        id: launcherState
        property bool isOpen: false
        property int activeTab: 0
        
        function toggle() { 
            if (!isOpen) {
                activeTab = 0;
            }
            isOpen = !isOpen; 
        }
        function close() { isOpen = false; }
    }

    IpcHandler {
        target: "launcher"
        function toggle() { launcherState.toggle(); }
        function close() { launcherState.close(); }
        function openTab(tab: int) {
            launcherState.activeTab = tab;
            launcherState.isOpen = true;
        }
    }

    PanelWindow {
        id: barWindow

        implicitWidth: island.width
        implicitHeight: island.height + 20

        anchors { top: true }

        WlrLayershell.layer: WlrLayer.Overlay
        // Grant exclusive keyboard focus when either the launcher or the control center is open/expanded
        WlrLayershell.keyboardFocus: (launcherState.isOpen || barWindow.isExpanded) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0
        
        color: "transparent"

        property var activeWorkspaceId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        property string currentTime: Qt.formatDateTime(new Date(), "HH:mm")
        property string currentDate: Qt.formatDateTime(new Date(), "dddd, MMMM d")

        // Fast dedicated timer so keyboard volume wheel updates the UI instantly
        Timer {
            interval: 400
            running: true
            repeat: true
            onTriggered: {
                volumeCheckProcess.running = false;
                volumeCheckProcess.running = true;
            }
        }

        // Slower background timer for network and brightness status
        Timer {
            interval: 5000
            running: true
            repeat: true
            onTriggered: {
                netCheckProcess.running = false;
                netCheckProcess.running = true;
                brightnessCheckProcess.running = false;
                brightnessCheckProcess.running = true;
            }
        }

        property var activePlayer: Mpris.players.values[0] ?? null
        property bool hasActiveMedia: activePlayer !== null

        property real volumeVal: 0.0
        property bool isMuted: false

        property real brightnessVal: 0.5

        property bool netConnected: false
        property string netType: ""
        property string netName: "Checking..."

        property bool isExpanded: false
        
        property int launcherWidth: 660
        property int launcherHeight: 190
        property int expandedWidth: 380
        property int compactWidth: 260
        property int controlCenterHeight: 530
        property int compactHeight: 36

        // Catch Escape keypress to collapse the island or close launcher
        FocusScope {
            anchors.fill: parent
            focus: launcherState.isOpen || barWindow.isExpanded

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    if (launcherState.isOpen) {
                        launcherState.close();
                    } else if (barWindow.isExpanded) {
                        barWindow.isExpanded = false;
                    }
                    event.accepted = true;
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: launcherState.isOpen || barWindow.isExpanded
            onClicked: {
                if (launcherState.isOpen) {
                    launcherState.close();
                } else if (barWindow.isExpanded) {
                    barWindow.isExpanded = false;
                }
            }
        }

        Rectangle {
            id: island
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter

            width: launcherState.isOpen ? barWindow.launcherWidth : (barWindow.isExpanded ? barWindow.expandedWidth : barWindow.compactWidth)
            height: launcherState.isOpen ? barWindow.launcherHeight : (barWindow.isExpanded ? barWindow.controlCenterHeight : barWindow.compactHeight)

            radius: launcherState.isOpen ? 24 : (barWindow.isExpanded ? 24 : (height / 2))
            clip: true

            color: "#1d2021"
            border.color: launcherState.isOpen ? "#fabd2f" : (barWindow.isExpanded ? "#3c3836" : "#161616")
            border.width: 1

            Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
            Behavior on radius { NumberAnimation { duration: 300 } }

            MouseArea {
                anchors.fill: parent
                enabled: !launcherState.isOpen && !barWindow.isExpanded
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    barWindow.isExpanded = true;
                }
            }

            CompactBar {
                anchors.centerIn: parent
                visible: !barWindow.isExpanded && !launcherState.isOpen
            }

            ControlCenter {
                anchors.fill: parent
                anchors.margins: 14
                visible: barWindow.isExpanded && !launcherState.isOpen
            }

            LauncherHub {
                anchors.fill: parent
                anchors.margins: 14
                visible: launcherState.isOpen
            }
        }
    }
}
