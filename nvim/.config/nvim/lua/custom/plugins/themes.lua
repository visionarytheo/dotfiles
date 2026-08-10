local function gh(repo) return 'https://github.com/' .. repo end

-- 1. Register and add themes to the runtime path
vim.pack.add {
  gh 'ellisonleao/gruvbox.nvim',
  gh 'rose-pine/neovim',
  gh 'catppuccin/nvim',
  gh 'folke/tokyonight.nvim',
  gh 'craftzdog/solarized-osaka.nvim',
  gh 'shaunsingh/nord.nvim',
  gh 'AlexvZyl/nordic.nvim',
}

-- 3. Set the global colorscheme
vim.cmd.colorscheme 'gruvbox'
