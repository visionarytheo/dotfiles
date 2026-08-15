vim.o.background = "dark"

local status, gruvbox = pcall(require, "gruvbox")
if status then
	gruvbox.setup({
		terminal_colors = true,
		contrast = "hard",
		transparent_mode = false,
	})
end

vim.cmd.colorscheme("gruvbox")
