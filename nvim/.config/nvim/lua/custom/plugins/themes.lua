local function gh(repo) return 'https://github.com/' .. repo end

-- 1. Register and add themes to the runtime path
vim.pack.add {
  gh 'ellisonleao/gruvbox.nvim',
  gh 'rose-pine/neovim',
  gh 'catppuccin/nvim',
  gh 'folke/tokyonight.nvim',
  gh 'craftzdog/solarized-osaka.nvim',
  gh 'shaunsingh/nord.nvim',
  gh 'dracula/vim',
  gh 'AlexvZyl/nordic.nvim',
}

-- 2. Load active theme directly from current_theme directory
local theme_file = os.getenv("HOME") .. "/.config/hypr/current_theme/nvim.lua"
if vim.fn.filereadable(theme_file) == 1 then
	dofile(theme_file)
end
