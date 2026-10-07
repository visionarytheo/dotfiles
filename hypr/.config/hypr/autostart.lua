-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("blueman-applet &")
	hl.exec_cmd("mkdir -p ~/.cache/awww && awww-daemon >/dev/null 2>&1 &")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Amber 24")
	hl.exec_cmd("quickshell &")
	--hl.exec_cmd("gammastep -O 5800 -g 1.0 -b 0.85 &")
	-- Clipboard history daemons
	hl.exec_cmd("wl-paste --type text --watch cliphist store &")
	hl.exec_cmd("wl-paste --type image --watch cliphist store &")

	-- Bluetooth autoconnect X8
	hl.exec_cmd("bluetoothctl connect 41:42:25:04:3E:29 &")
end)
