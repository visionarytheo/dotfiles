-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("mkdir -p ~/.cache/awww && awww-daemon >/dev/null 2>&1 &")
	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Amber 24")
	hl.exec_cmd("waybar")
end)
