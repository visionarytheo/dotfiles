-------------------
---- AUTOSTART ----
-------------------

---@diagnostic disable: undefined-global

hl.on("hyprland.start", function()
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("blueman-applet &")
	hl.exec_cmd("mkdir -p ~/.cache/awww && awww-daemon >/dev/null 2>&1 &")
	hl.exec_cmd("waybar &")
	hl.exec_cmd("hyprsunset -t 6800  &")
	hl.exec_cmd("sleep 3 && hyprctl hyprsunset gamma 85")

	-- Clipboard history daemons
	hl.exec_cmd("wl-paste --type text --watch cliphist store &")
	hl.exec_cmd("wl-paste --type image --watch cliphist store &")

	-- Bluetooth autoconnect X8
	hl.exec_cmd("bluetoothctl connect 41:42:25:04:3E:29 &")
end)
