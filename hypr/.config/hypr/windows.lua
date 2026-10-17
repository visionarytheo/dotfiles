--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

---@diagnostic disable: undefined-global

hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- Global Window Transparency (Active: 90%, Inactive: 85%)
hl.window_rule({
	name = "global-transparency",
	match = { class = ".*" },
	opacity = "0.85 0.75",
})

-- Keep Web Browsers Opaque for accurate color/video playback
hl.window_rule({
	name = "opaque-browsers",
	match = { class = "^(google-chrome-stable|google-chrome|firefox|helium)$" },
	opacity = "1.0 1.0",
})

-- Floats
hl.window_rule({
	name = "float-iriunwebcam",
	match = { class = "iriunwebcam" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
	opacity = "1.0 1.0",
})

hl.window_rule({
	name = "float-mpv",
	match = { class = "mpv" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
	opacity = "1.0 1.0",
})

hl.window_rule({
	name = "float-pavucontrol",
	match = { class = "org.pulseaudio.pavucontrol" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
	opacity = "1.0 1.0",
})

hl.window_rule({
	name = "float-blueman",
	match = { class = ".*blueman-manager.*" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
	opacity = "1.0 1.0",
})

hl.window_rule({
	name = "nm-connection-editor",
	match = { class = "nm-connection-editor" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
})

hl.window_rule({
	name = "float-nwg-look",
	match = { class = "nwg-look" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
})

hl.window_rule({
	name = "float-hyprmod",
	match = { class = "io.github.bluemancz.hyprmod" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
})

hl.window_rule({
	name = "float-nvidia-settings",
	match = { class = "nvidia-settings" },
	float = true,
	size = "800 600", -- Width and Height in pixels
	center = true,
})
