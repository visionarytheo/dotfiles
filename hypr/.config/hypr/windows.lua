--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

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
	opacity = "0.92 0.85",
})

-- Keep Web Browsers Opaque for accurate color/video playback
hl.window_rule({
	name = "opaque-browsers",
	match = { class = "^(google-chrome-stable|google-chrome|firefox)$" },
	opacity = "1.0 1.0",
})
